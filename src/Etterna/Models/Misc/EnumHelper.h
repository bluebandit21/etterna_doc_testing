#ifndef ENUM_HELPER_H
#define ENUM_HELPER_H

#include "Etterna/Models/Lua/LuaReference.h"
#include <memory>

#include "lua.hpp"

/** @brief A general foreach loop for enumerators, going up to a max value. */
#define FOREACH_ENUM_N(e, max, var)                                            \
	for (e var = (e)0; (var) < (max); enum_add<e>((var), +1))
/** @brief A general foreach loop for enumerators. */
#define FOREACH_ENUM(e, var)                                                   \
	for (e var = (e)0; (var) < NUM_##e; enum_add<e>((var), +1))

int
CheckEnum(lua_State* L,
		  LuaReference& table,
		  int iPos,
		  int iInvalid,
		  const char* szType,
		  bool bAllowInvalid,
		  bool bAllowAnything = false);

template<typename T>
struct EnumTraits
{
	static LuaReference StringToEnum;
	static LuaReference EnumToString;
	static T Invalid;
	static const char* szName;
};
template<typename T>
LuaReference EnumTraits<T>::StringToEnum;
template<typename T>
LuaReference EnumTraits<T>::EnumToString;
/** @brief Lua helpers for Enumerators. */
namespace Enum {
template<typename T>
static T
Check(lua_State* L,
	  int iPos,
	  bool bAllowInvalid = false,
	  bool bAllowAnything = false)
{
	return (T)CheckEnum(L,
						EnumTraits<T>::StringToEnum,
						iPos,
						EnumTraits<T>::Invalid,
						EnumTraits<T>::szName,
						bAllowInvalid,
						bAllowAnything);
}
template<typename T>
static void
Push(lua_State* L, T iVal)
{
	/* Enum_Invalid values are nil in Lua. */
	if (iVal == EnumTraits<T>::Invalid) {
		lua_pushnil(L);
		return;
	}

	/* Look up the string value. */
	EnumTraits<T>::EnumToString.PushSelf(L);
	lua_rawgeti(L, -1, iVal + 1);
	lua_remove(L, -2);
}

void
SetMetatable(lua_State* L,
			 LuaReference& EnumTable,
			 LuaReference& EnumIndexTable,
			 const char* szName);
};

const std::string&
EnumToString(int iVal,
			 int iMax,
			 const char** szNameArray,
			 unique_ptr<std::string>* pNameCache); // XToString helper

#define XToString(X)                                                           \
                                                                               \
	const std::string& X##ToString(X x);                                           \
                                                                               \
	COMPILE_ASSERT(NUM_##X == ARRAYLEN(X##Names));                             \
                                                                               \
	const std::string& X##ToString(X x)                                            \
                                                                               \
	{                                                                          \
		static unique_ptr<std::string> as_##X##Name[NUM_##X + 2];                  \
		return EnumToString(x, NUM_##X, X##Names, as_##X##Name);               \
	}                                                                          \
                                                                               \
	namespace StringConversion {                                               \
	template<>                                                                 \
	std::string ToString<X>(const X& value)                                        \
	{                                                                          \
		return X##ToString(value);                                             \
	}                                                                          \
	}

#define XToLocalizedString(X)                                                  \
                                                                               \
	const std::string& X##ToLocalizedString(X x);                                  \
                                                                               \
	const std::string& X##ToLocalizedString(X x)                                   \
                                                                               \
	{                                                                          \
		static unique_ptr<LocalizedString> g_##X##Name[NUM_##X];               \
		if (g_##X##Name[0].get() == NULL) {                                    \
			for (unsigned i = 0; i < NUM_##X; ++i) {                           \
				unique_ptr<LocalizedString> ap(                                \
				  new LocalizedString(#X, X##ToString((X)i)));                 \
				g_##X##Name[i] = std::move(ap);                                \
			}                                                                  \
		}                                                                      \
		return g_##X##Name[x]->GetValue();                                     \
	}

#define StringToX(X)                                                           \
                                                                               \
	X StringTo##X(const std::string&);                                             \
                                                                               \
	X StringTo##X(const std::string& s)                                            \
                                                                               \
	{                                                                          \
		for (unsigned i = 0; i < ARRAYLEN(X##Names); ++i)                      \
			if (!CompareNoCaseLUL(s, X##Names[i]))                                 \
				return (X)i;                                                   \
		return X##_Invalid;                                                    \
	}                                                                          \
                                                                               \
	namespace StringConversion                                                 \
                                                                               \
	{                                                                          \
	template<>                                                                 \
	bool FromString<X>(const std::string& sValue, X& out)                          \
	{                                                                          \
		out = StringTo##X(sValue);                                             \
		return out != X##_Invalid;                                             \
	}                                                                          \
	}

// currently unused
#define LuaDeclareType(X)

#define LuaXType(X)                                                            \
                                                                               \
	template struct EnumTraits<X>;                                             \
                                                                               \
	static void Lua##X(lua_State* L)                                           \
                                                                               \
	{                                                                          \
		lua_newtable(L);                                                       \
		FOREACH_ENUM(X, i)                                                     \
		{                                                                      \
			std::string s = X##ToString(i);                                        \
			lua_pushstring(L, ((#X "_") + s).c_str());                                   \
			lua_rawseti(L, -2, i + 1); /* 1-based */                           \
		}                                                                      \
		EnumTraits<X>::EnumToString.SetFromStack(L);                           \
		EnumTraits<X>::EnumToString.PushSelf(L);                               \
		lua_setglobal(L, #X);                                                  \
		lua_newtable(L);                                                       \
		FOREACH_ENUM(X, i)                                                     \
		{                                                                      \
			std::string s = X##ToString(i);                                        \
			lua_pushstring(L, ((#X "_") + s).c_str());                                   \
			lua_pushnumber(L, i); /* 0-based */                                \
			lua_rawset(L, -3);                                                 \
			/* Compatibility with old, case-insensitive values */              \
			s = make_lower(s);                                                     \
			lua_pushstring(L, s.c_str());                                              \
			lua_pushnumber(L, i); /* 0-based */                                \
			lua_rawset(L, -3);                                                 \
			/* Compatibility with old, raw values */                           \
			lua_pushnumber(L, i);                                              \
			lua_rawseti(L, -2, i);                                             \
		}                                                                      \
		EnumTraits<X>::StringToEnum.SetFromStack(L);                           \
		EnumTraits<X>::StringToEnum.PushSelf(L);                               \
		Enum::SetMetatable(                                                    \
		  L, EnumTraits<X>::EnumToString, EnumTraits<X>::StringToEnum, #X);    \
	}                                                                          \
                                                                               \
	REGISTER_WITH_LUA_FUNCTION(Lua##X);                                        \
                                                                               \
	template<>                                                                 \
	X EnumTraits<X>::Invalid = X##_Invalid;                                    \
                                                                               \
	template<>                                                                 \
	const char* EnumTraits<X>::szName = #X;                                    \
                                                                               \
	namespace LuaHelpers                                                       \
                                                                               \
	{                                                                          \
	template<>                                                                 \
	bool FromStack<X>(lua_State * L, X& Object, int iOffset)                   \
	{                                                                          \
		Object = Enum::Check<X>(L, iOffset, true);                             \
		return Object != EnumTraits<X>::Invalid;                               \
	}                                                                          \
	}                                                                          \
                                                                               \
	namespace LuaHelpers                                                       \
                                                                               \
	{                                                                          \
	template<>                                                                 \
	void Push<X>(lua_State * L, const X& Object)                               \
	{                                                                          \
		Enum::Push<X>(L, Object);                                              \
	}                                                                          \
	}

#endif
