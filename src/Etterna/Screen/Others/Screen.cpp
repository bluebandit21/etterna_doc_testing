#include "Etterna/Globals/global.h"
#include "Etterna/Actor/Base/ActorUtil.h"
#include "Etterna/Models/Misc/InputEventPlus.h"
#include "Etterna/Singletons/InputMapper.h"
#include "Etterna/Singletons/PrefsManager.h"
#include "Core/Services/Locator.hpp"
#include "Core/Platform/Platform.hpp"
#include "Screen.h"
#include "Etterna/Singletons/ScreenManager.h"
#include "RageUtil/Misc/RageInput.h"
#include "Etterna/Singletons/ThemeManager.h"

#include <tuple>
#include <algorithm>
#include <functional>

using std::make_tuple;
using std::tuple;

#define NEXT_SCREEN THEME->GetMetric(m_sName, "NextScreen")
#define PREV_SCREEN THEME->GetMetric(m_sName, "PrevScreen")
#define PREPARE_SCREENS THEME->GetMetric(m_sName, "PrepareScreens")
#define PERSIST_SCREENS THEME->GetMetric(m_sName, "PersistScreens")
#define GROUPED_SCREENS THEME->GetMetric(m_sName, "GroupedScreens")

static const char* ScreenTypeNames[] = {
	"Attract", "GameMenu", "Gameplay", "Evaluation", "SystemMenu",
};
XToString(ScreenType);
LuaXType(ScreenType);

void
Screen::InitScreen(Screen* pScreen)
{
	pScreen->Init();
}

Screen::~Screen()
{
	// unregister the periodic functions
	auto* L = LUA->Get();
	for (auto& dfunc : delayedPeriodicFunctions) {
		auto id = std::get<3>(dfunc);
		luaL_unref(L, LUA_REGISTRYINDEX, id);
	}
	delayedFunctions.clear();
	delayedPeriodicFunctions.clear();
	delayedPeriodicFunctionIdsToDelete.clear();
	LUA->Release(L);
};

bool
Screen::SortMessagesByDelayRemaining(const Screen::QueuedScreenMessage& m1,
									 const Screen::QueuedScreenMessage& m2)
{
	return m1.fDelayRemaining < m2.fDelayRemaining;
}

void
Screen::Init()
{
	ALLOW_OPERATOR_MENU_BUTTON.Load(m_sName, "AllowOperatorMenuButton");
	HANDLE_BACK_BUTTON.Load(m_sName, "HandleBackButton");
	REPEAT_RATE.Load(m_sName, "RepeatRate");
	REPEAT_DELAY.Load(m_sName, "RepeatDelay");

	Core::Platform::setCursorVisible(true);

	delayedFunctions.clear();
	delayedPeriodicFunctionIdsToDelete.clear();

	m_Codes.Load(m_sName);

	SetFOV(0);

	m_smSendOnPop = SM_None;
	m_bRunning = false;

	m_CallingInputCallbacks = false;

	ActorUtil::LoadAllCommandsFromName(*this, m_sName, "Screen");

	PlayCommandNoRecurse(Message("Init"));

	std::vector<std::string> asList;
	split(PREPARE_SCREENS, ",", asList);
	for (auto& i : asList) {
		Locator::getLogger()->info(
		  "Screen \"{}\" preparing \"{}\"", m_sName.c_str(), i.c_str());
		SCREENMAN->PrepareScreen(i);
	}

	asList.clear();
	split(GROUPED_SCREENS, ",", asList);
	for (auto& i : asList)
		SCREENMAN->GroupScreen(i);

	asList.clear();
	split(PERSIST_SCREENS, ",", asList);
	for (auto& i : asList)
		SCREENMAN->PersistantScreen(i);
}

void
Screen::BeginScreen()
{
	m_bRunning = true;
	m_bFirstUpdate = true;

	/* Screens set these when they determine their next screen dynamically.
	 * Reset them here, so a reused screen doesn't inherit these from the last
	 * time it was used. */
	m_sNextScreen = std::string();

	m_fLockInputSecs = 0;

	this->RunCommands(THEME->GetMetricA(m_sName, "ScreenOnCommand"));

	if (m_fLockInputSecs == 0)
		m_fLockInputSecs = 0.0001f; // always lock for a tiny amount of time so
									// that we throw away any queued inputs
									// during the load.

	this->PlayCommand("Begin");
}

void
Screen::EndScreen()
{
	this->PlayCommand("End");
	m_bRunning = false;
}

void
Screen::UpdateTimedFunctions(float fDeltaTime)
{
	for (auto& delayedF : delayedFunctions) {
		delayedF.second -= fDeltaTime;
		if (delayedF.second <= 0) {
			delayedF.first();
		}
	}
	// Doing this in place did weird things
	delayedFunctions.erase(
	  std::remove_if(delayedFunctions.begin(),
					 delayedFunctions.end(),
					 [](std::pair<std::function<void()>, float>& x) {
						 return x.second <= 0;
					 }),
	  delayedFunctions.end());
	if (!delayedPeriodicFunctionIdsToDelete.empty()) {
		auto* L = LUA->Get();
		for (auto id : delayedPeriodicFunctionIdsToDelete) {
			luaL_unref(L, LUA_REGISTRYINDEX, id);
			auto& vec = this->delayedPeriodicFunctions;
			vec.erase(
			  std::remove_if(
				vec.begin(),
				vec.end(),
				[id](tuple<std::function<void()>, float, float, int>& x) {
					return std::get<3>(x) == id;
				}),
			  vec.end());
		}
		LUA->Release(L);
		delayedPeriodicFunctionIdsToDelete.clear();
	}
	for (auto& delayedF : delayedPeriodicFunctions) {
		std::get<1>(delayedF) -= fDeltaTime;
		if (std::get<1>(delayedF) <= 0) {
			std::get<0>(delayedF)();
			std::get<1>(delayedF) = std::get<2>(delayedF);
		}
	}
}

void
Screen::Update(float fDeltaTime)
{
	// Do this here so even with 0 time it runs on the next frame
	UpdateTimedFunctions(fDeltaTime);

	ActorFrame::Update(fDeltaTime);

	m_fLockInputSecs = std::max(0.F, m_fLockInputSecs - fDeltaTime);

	/* We need to ensure two things:
	 * 1. Messages must be sent in the order of delay. If two messages are sent
	 *    simultaneously, one with a .001 delay and another with a .002 delay,
	 *    the .001 delay message must be sent first.
	 * 2. Messages to be delivered simultaneously must be sent in the order
	 * queued.
	 *
	 * Sort by time to ensure #1; use a stable sort to ensure #2. */
	stable_sort(m_QueuedMessages.begin(),
				m_QueuedMessages.end(),
				SortMessagesByDelayRemaining);

	// Update the times of queued ScreenMessages.
	for (auto& m_QueuedMessage : m_QueuedMessages) {
		/* Hack:
		 * If we simply subtract time and then send messages, we have a problem.
		 * Messages are queued to arrive at specific times, and those times line
		 * up with things like tweens finishing. If we send the message at the
		 * exact time given, then it'll be on the same cycle that would be
		 * rendering the last frame of a tween (such as an object going off the
		 * screen). However, when we send the message, we're likely to set up a
		 * new screen, which causes everything to stop in place; this results in
		 * actors occasionally not quite finishing their tweens. Let's delay all
		 * messages that have a non-zero time an extra frame. */
		if (m_QueuedMessage.fDelayRemaining > 0.0001f) {
			m_QueuedMessage.fDelayRemaining -= fDeltaTime;
			m_QueuedMessage.fDelayRemaining =
			  std::max(m_QueuedMessage.fDelayRemaining, 0.0001f);
		} else {
			m_QueuedMessage.fDelayRemaining -= fDeltaTime;
		}
	}

	/* Now dispatch messages. If the number of messages on the queue changes
	 * within HandleScreenMessage, someone cleared messages on the queue. This
	 * means we have no idea where 'i' is, so start over. Since we applied time
	 * already, this won't cause messages to be mistimed. */
	for (unsigned i = 0; i < m_QueuedMessages.size(); i++) {
		if (m_QueuedMessages[i].fDelayRemaining > 0.0f)
			continue; /* not yet */

		// Remove the message from the list.
		const ScreenMessage SM = m_QueuedMessages[i].SM;
		m_QueuedMessages.erase(m_QueuedMessages.begin() + i);
		i--;

		unsigned iSize = m_QueuedMessages.size();

		// send this sucker!
		Locator::getLogger()->trace(
		  "ScreenMessage({})",
		  ScreenMessageHelpers::ScreenMessageToString(SM).c_str());
		this->HandleScreenMessage(SM);

		// If the size changed, start over.
		if (iSize != m_QueuedMessages.size())
			i = 0;
	}
}

/* Returns true if the input was handled, or false if not handled.  For
 * overlays, this determines whether the event will be propagated to lower
 * screens (i.e. it propagates from an overlay only when this returns false). */
bool
Screen::Input(const InputEventPlus& input)
{
	Message msg("");
	if (m_Codes.InputMessage(input, msg)) {
		this->HandleMessage(msg);
		return true;
	}

	// Don't send release messages with the default handler.
	switch (input.type) {
		case IET_FIRST_PRESS:
		case IET_REPEAT:
			break; // OK
		default:
			return false; // don't care
	}
	if (input.type == IET_FIRST_PRESS) {
		// Always broadcast mouse input so themers can grab it. -aj
		if (input.DeviceI == DeviceInput(DEVICE_MOUSE, MOUSE_LEFT))
			MESSAGEMAN->Broadcast(Message_LeftClick);
		if (input.DeviceI == DeviceInput(DEVICE_MOUSE, MOUSE_RIGHT))
			MESSAGEMAN->Broadcast(Message_RightClick);
		if (input.DeviceI == DeviceInput(DEVICE_MOUSE, MOUSE_MIDDLE))
			MESSAGEMAN->Broadcast(Message_MiddleClick);
		// Can't do MouseWheelUp and MouseWheelDown at the same time. -aj
		if (input.DeviceI == DeviceInput(DEVICE_MOUSE, MOUSE_WHEELUP))
			MESSAGEMAN->Broadcast(Message_MouseWheelUp);
		else if (input.DeviceI == DeviceInput(DEVICE_MOUSE, MOUSE_WHEELDOWN))
			MESSAGEMAN->Broadcast(Message_MouseWheelDown);
	}

	// default input handler used by most menus
	switch (input.MenuI) {
		case GAME_BUTTON_MENUUP:
			return this->MenuUp(input);
		case GAME_BUTTON_MENUDOWN:
			return this->MenuDown(input);
		case GAME_BUTTON_MENULEFT:
			return this->MenuLeft(input);
		case GAME_BUTTON_MENURIGHT:
			return this->MenuRight(input);
		case GAME_BUTTON_BACK:
			// Only go back on first press.  If somebody is backing out of the
			// options screen, they might still be holding it when select music
			// appears, and accidentally back out of that too. -Kyz
			if (input.type == IET_FIRST_PRESS) {
				if (HANDLE_BACK_BUTTON)
					return this->MenuBack(input);
			}
			return false;
		case GAME_BUTTON_START:
			return this->MenuStart(input);
		case GAME_BUTTON_SELECT:
			return this->MenuSelect(input);
		case GAME_BUTTON_COIN:
			return this->MenuCoin(input);
		default:
			return false;
	}
}

void
Screen::HandleScreenMessage(const ScreenMessage& SM)
{
	if (SM == SM_GoToNextScreen || SM == SM_GoToPrevScreen) {
		if (SCREENMAN->IsStackedScreen(this))
			SCREENMAN->PopTopScreen(m_smSendOnPop);
		else {
			std::string ToScreen =
			  (SM == SM_GoToNextScreen ? GetNextScreenName() : GetPrevScreen());
			if (ToScreen == "") {
				LuaHelpers::ReportScriptError(
				  "Error:  Tried to go to empty screen.");
			} else {
				SCREENMAN->SetNewScreen(ToScreen);
			}
		}
	} else if (SM == SM_GainFocus) {
		if (REPEAT_RATE != -1.0f)
			INPUTFILTER->SetRepeatRate(REPEAT_RATE);
		if (REPEAT_DELAY != -1.0f)
			INPUTFILTER->SetRepeatDelay(REPEAT_DELAY);
	} else if (SM == SM_LoseFocus) {
		INPUTFILTER->ResetRepeatRate();
	}
}

std::string
Screen::GetNextScreenName() const
{
	if (!m_sNextScreen.empty())
		return m_sNextScreen;
	return NEXT_SCREEN;
}

void
Screen::SetNextScreenName(std::string const& name)
{
	m_sNextScreen = name;
}

void
Screen::SetPrevScreenName(std::string const& name)
{
	m_sPrevScreen = name;
}

std::string
Screen::GetPrevScreen() const
{
	if (!m_sPrevScreen.empty())
		return m_sPrevScreen;
	return PREV_SCREEN;
}

void
Screen::PostScreenMessage(const ScreenMessage& SM, float fDelay)
{
	ASSERT(fDelay >= 0.0);

	QueuedScreenMessage QSM;
	QSM.SM = SM;
	QSM.fDelayRemaining = fDelay;
	m_QueuedMessages.push_back(QSM);
}

void
Screen::ClearMessageQueue()
{
	m_QueuedMessages.clear();
}

void
Screen::ClearMessageQueue(const ScreenMessage& SM)
{
	for (int i = m_QueuedMessages.size() - 1; i >= 0; i--)
		if (m_QueuedMessages[i].SM == SM)
			m_QueuedMessages.erase(m_QueuedMessages.begin() + i);
}

bool
Screen::PassInputToLua(const InputEventPlus& input)
{
	if (m_InputCallbacks.empty() || m_fLockInputSecs > 0.0f ||
		!AllowCallbackInput()) {
		return false;
	}
	m_CallingInputCallbacks = true;
	bool handled = false;
	Lua* L = LUA->Get();

	std::chrono::duration<float> timeDelta =
	  std::chrono::steady_clock::now() - input.DeviceI.ts;
	float inputAgo = timeDelta.count();

	// Construct the table once, and reuse it.
	lua_createtable(L, 0, 7);
	{ // This block is meant to improve clarity.  A subtable is created for
		// storing the DeviceInput member.
		lua_createtable(L, 0, 8);
		Enum::Push(L, input.DeviceI.device);
		lua_setfield(L, -2, "device");
		Enum::Push(L, input.DeviceI.button);
		lua_setfield(L, -2, "button");
		lua_pushnumber(L, input.DeviceI.level);
		lua_setfield(L, -2, "level");
		lua_pushinteger(L, input.DeviceI.z);
		lua_setfield(L, -2, "z");
		lua_pushboolean(L, input.DeviceI.bDown);
		lua_setfield(L, -2, "down");
		lua_pushnumber(L, inputAgo);
		lua_setfield(L, -2, "ago");
		lua_pushboolean(L, input.DeviceI.IsJoystick());
		lua_setfield(L, -2, "is_joystick");
		lua_pushboolean(L, input.DeviceI.IsMouse());
		lua_setfield(L, -2, "is_mouse");
	}
	lua_setfield(L, -2, "DeviceInput");
	Enum::Push(L, input.GameI.controller);
	lua_setfield(L, -2, "controller");
	LuaHelpers::Push(
	  L, GameButtonToString(INPUTMAPPER->GetInputScheme(), input.GameI.button));
	lua_setfield(L, -2, "button");
	Enum::Push(L, input.type);
	lua_setfield(L, -2, "type");
	char s[MB_LEN_MAX];
	wctomb(s, INPUTMAN->DeviceInputToChar(input.DeviceI, true));
	LuaHelpers::Push(L, std::string(1, s[0]));
	lua_setfield(L, -2, "char");
	char snm[MB_LEN_MAX];
	wctomb(snm, INPUTMAN->DeviceInputToChar(input.DeviceI, false));
	LuaHelpers::Push(L, std::string(1, snm[0]));
	lua_setfield(L, -2, "charNoModifiers");
	LuaHelpers::Push(
	  L, GameButtonToString(INPUTMAPPER->GetInputScheme(), input.MenuI));
	lua_setfield(L, -2, "GameButton");
	Enum::Push(L, input.pn);
	lua_setfield(L, -2, "PlayerNumber");
	Enum::Push(L, input.mp);
	lua_setfield(L, -2, "MultiPlayer");
	for (auto k : orderedcallbacks) {
		if (handled)
			break;
		m_InputCallbacks[k].PushSelf(L);
		lua_pushvalue(L, -2);
		std::string error = "Error running input callback: ";
		LuaHelpers::RunScriptOnStack(L, error, 1, 1, true);
		handled = lua_toboolean(L, -1);
		lua_pop(L, 1);
	}
	lua_pop(L, 1);
	LUA->Release(L);
	m_CallingInputCallbacks = false;
	if (!m_DelayedCallbackRemovals.empty()) {
		for (auto& m_DelayedCallbackRemoval : m_DelayedCallbackRemovals) {
			InternalRemoveCallback(m_DelayedCallbackRemoval);
		}
	}
	return handled;
}

void
Screen::SetTimeout(const std::function<void()>& f, float ms)
{
	delayedFunctions.emplace_back(make_pair(f, ms));
	return;
}

void
Screen::SetInterval(const std::function<void()>& f, float ms, int id)
{
	delayedPeriodicFunctions.emplace_back(make_tuple(f, ms, ms, id));
	return;
}

void
Screen::AddInputCallbackFromStack(lua_State* L)
{
	callback_key_t key = lua_topointer(L, 1);
	m_InputCallbacks[key] = LuaReference(L);
	orderedcallbacks.push_back(key);
}

void
Screen::RemoveInputCallback(lua_State* L)
{
	callback_key_t key = lua_topointer(L, 1);
	if (m_CallingInputCallbacks) {
		m_DelayedCallbackRemovals.push_back(key);
	} else {
		InternalRemoveCallback(key);
	}
}

void
Screen::InternalRemoveCallback(callback_key_t key)
{
	std::map<callback_key_t, LuaReference>::iterator iter =
	  m_InputCallbacks.find(key);
	if (iter != m_InputCallbacks.end()) {
		m_InputCallbacks.erase(iter);
	}
}

// lua start
#include "Etterna/Models/Lua/LuaBinding.h"

/** @brief Allow Lua to have access to the Screen. */
class LunaScreen : public Luna<Screen>
{
  public:
	static int GetNextScreenName(T* p, lua_State* L)
	{
		lua_pushstring(L, p->GetNextScreenName().c_str());
		return 1;
	}
	static int SetNextScreenName(T* p, lua_State* L)
	{
		p->SetNextScreenName(SArg(1));
		COMMON_RETURN_SELF;
	}
	static int GetPrevScreenName(T* p, lua_State* L)
	{
		lua_pushstring(L, p->GetPrevScreen().c_str());
		return 1;
	}
	static int SetPrevScreenName(T* p, lua_State* L)
	{
		p->SetPrevScreenName(SArg(1));
		COMMON_RETURN_SELF;
	}
	static int lockinput(T* p, lua_State* L)
	{
		p->SetLockInputSecs(FArg(1));
		COMMON_RETURN_SELF;
	}
	DEFINE_METHOD(GetScreenType, GetScreenType())

	static int PostScreenMessage(T* p, lua_State* L)
	{
		std::string sMessage = SArg(1);
		ScreenMessage SM = ScreenMessageHelpers::ToScreenMessage(sMessage);
		p->PostScreenMessage(SM, static_cast<float>(IArg(2)));
		COMMON_RETURN_SELF;
	}

	static int AddInputCallback(T* p, lua_State* L)
	{
		if (!lua_isfunction(L, 1)) {
			luaL_error(L, "Input callback must be a function.");
		}
		p->AddInputCallbackFromStack(L);
		COMMON_RETURN_SELF;
	}

	static int RemoveInputCallback(T* p, lua_State* L)
	{
		if (!lua_isfunction(L, 1)) {
			luaL_error(L, "Input callback must be a function.");
		}
		p->RemoveInputCallback(L);
		COMMON_RETURN_SELF;
	}
	static int setTimeout(T* p, lua_State* L)
	{
		auto f = GetFuncArg(1, L);
		std::function<void()> execF = [f]() {
			Lua* L = LUA->Get();
			f.PushSelf(L);
			if (!lua_isnil(L, -1)) {
				std::string Error = "Error running Screen Timeout Function: ";
				LuaHelpers::RunScriptOnStack(
				  L, Error, 0, 0, true); // 1 args, 0 results
			}
			LUA->Release(L);
		};
		p->SetTimeout(execF, FArg(2));
		COMMON_RETURN_SELF;
	}
	static int setInterval(T* p, lua_State* L)
	{
		lua_pushvalue(L, 1);
		auto f = luaL_ref(L, LUA_REGISTRYINDEX);
		std::function<void()> execF = [f]() {
			Lua* L = LUA->Get();
			lua_rawgeti(L, LUA_REGISTRYINDEX, f);
			if (!lua_isnil(L, -1)) {
				std::string Error = "Error running Screen Interval Function: ";
				LuaHelpers::RunScriptOnStack(
				  L, Error, 0, 0, true); // 0 args, 0 results
			}
			LUA->Release(L);
		};
		p->SetInterval(execF, FArg(2), f);
		lua_pushnumber(L, f);
		return 1;
	}
	static int clearInterval(T* p, lua_State* L)
	{
		int r = IArg(1);
		auto& vec = p->delayedPeriodicFunctions;
		auto it =
		  find_if(vec.begin(),
				  vec.end(),
				  [r](tuple<std::function<void()>, float, float, int>& x) {
					  return std::get<3>(x) == r;
				  });
		if (it != vec.end()) {
			p->delayedPeriodicFunctionIdsToDelete.emplace_back(r);
		} else {
			LuaHelpers::ReportScriptError(
			  "Interval function not found (When trying to clearInterval() )");
		}
		return 0;
	}
	static int IsPreviewNoteFieldActive(T* p, lua_State* L)
	{
		lua_pushboolean(L, p->b_PreviewNoteFieldIsActive);
		return 1;
	}

	LunaScreen()
	{
		ADD_METHOD(setInterval);
		ADD_METHOD(setTimeout);
		ADD_METHOD(clearInterval);
		ADD_METHOD(GetNextScreenName);
		ADD_METHOD(SetNextScreenName);
		ADD_METHOD(GetPrevScreenName);
		ADD_METHOD(SetPrevScreenName);
		ADD_METHOD(PostScreenMessage);
		ADD_METHOD(lockinput);
		ADD_METHOD(GetScreenType);
		ADD_METHOD(AddInputCallback);
		ADD_METHOD(RemoveInputCallback);
		ADD_METHOD(IsPreviewNoteFieldActive);
	}
};

LUA_REGISTER_DERIVED_CLASS(Screen, ActorFrame)
// lua end

REGISTER_SCREEN_CLASS(Screen);
