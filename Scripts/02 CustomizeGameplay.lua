local keymode
local allowedCustomization
local usingReverse

MovableValues = {}

local function loadValuesTable()
	allowedCustomization = playerConfig:get_data().CustomizeGameplay
	usingReverse = GAMESTATE:GetPlayerState():GetCurrentPlayerOptions():UsingReverse()
	MovableValues.JudgmentX = playerConfig:get_data().GameplayXYCoordinates[keymode].JudgmentX
	MovableValues.JudgmentY = playerConfig:get_data().GameplayXYCoordinates[keymode].JudgmentY
	MovableValues.JudgmentZoom = playerConfig:get_data().GameplaySizes[keymode].JudgmentZoom
	MovableValues.ComboX = playerConfig:get_data().GameplayXYCoordinates[keymode].ComboX
	MovableValues.ComboY = playerConfig:get_data().GameplayXYCoordinates[keymode].ComboY
	MovableValues.ComboZoom = playerConfig:get_data().GameplaySizes[keymode].ComboZoom
	MovableValues.ErrorBarX = playerConfig:get_data().GameplayXYCoordinates[keymode].ErrorBarX
	MovableValues.ErrorBarY = playerConfig:get_data().GameplayXYCoordinates[keymode].ErrorBarY
	MovableValues.ErrorBarWidth = playerConfig:get_data().GameplaySizes[keymode].ErrorBarWidth
	MovableValues.ErrorBarHeight = playerConfig:get_data().GameplaySizes[keymode].ErrorBarHeight
	MovableValues.TargetTrackerX = playerConfig:get_data().GameplayXYCoordinates[keymode].TargetTrackerX
	MovableValues.TargetTrackerY = playerConfig:get_data().GameplayXYCoordinates[keymode].TargetTrackerY
	MovableValues.TargetTrackerZoom = playerConfig:get_data().GameplaySizes[keymode].TargetTrackerZoom
	MovableValues.FullProgressBarX = playerConfig:get_data().GameplayXYCoordinates[keymode].FullProgressBarX
	MovableValues.FullProgressBarY = playerConfig:get_data().GameplayXYCoordinates[keymode].FullProgressBarY
	MovableValues.FullProgressBarWidth = playerConfig:get_data().GameplaySizes[keymode].FullProgressBarWidth
	MovableValues.FullProgressBarHeight = playerConfig:get_data().GameplaySizes[keymode].FullProgressBarHeight
	MovableValues.MiniProgressBarX = playerConfig:get_data().GameplayXYCoordinates[keymode].MiniProgressBarX
	MovableValues.MiniProgressBarY = playerConfig:get_data().GameplayXYCoordinates[keymode].MiniProgressBarY
	MovableValues.DisplayPercentX = playerConfig:get_data().GameplayXYCoordinates[keymode].DisplayPercentX
	MovableValues.DisplayPercentY = playerConfig:get_data().GameplayXYCoordinates[keymode].DisplayPercentY
	MovableValues.DisplayPercentZoom = playerConfig:get_data().GameplaySizes[keymode].DisplayPercentZoom
	MovableValues.DisplayMeanX = playerConfig:get_data().GameplayXYCoordinates[keymode].DisplayMeanX
	MovableValues.DisplayMeanY = playerConfig:get_data().GameplayXYCoordinates[keymode].DisplayMeanY
	MovableValues.DisplayMeanZoom = playerConfig:get_data().GameplaySizes[keymode].DisplayMeanZoom
	MovableValues.NoteFieldX = playerConfig:get_data().GameplayXYCoordinates[keymode].NoteFieldX
	MovableValues.NoteFieldY = playerConfig:get_data().GameplayXYCoordinates[keymode].NoteFieldY
	MovableValues.NoteFieldWidth = playerConfig:get_data().GameplaySizes[keymode].NoteFieldWidth
	MovableValues.NoteFieldHeight = playerConfig:get_data().GameplaySizes[keymode].NoteFieldHeight
	MovableValues.NoteFieldSpacing = playerConfig:get_data().GameplaySizes[keymode].NoteFieldSpacing
	MovableValues.JudgeCounterX = playerConfig:get_data().GameplayXYCoordinates[keymode].JudgeCounterX
	MovableValues.JudgeCounterY = playerConfig:get_data().GameplayXYCoordinates[keymode].JudgeCounterY
	MovableValues.ReplayButtonsX = playerConfig:get_data().GameplayXYCoordinates[keymode].ReplayButtonsX
	MovableValues.ReplayButtonsY = playerConfig:get_data().GameplayXYCoordinates[keymode].ReplayButtonsY
	MovableValues.ReplayButtonsSpacing = playerConfig:get_data().GameplaySizes[keymode].ReplayButtonsSpacing
	MovableValues.ReplayButtonsZoom = playerConfig:get_data().GameplaySizes[keymode].ReplayButtonsZoom
	MovableValues.NPSGraphX = playerConfig:get_data().GameplayXYCoordinates[keymode].NPSGraphX
	MovableValues.NPSGraphY = playerConfig:get_data().GameplayXYCoordinates[keymode].NPSGraphY
	MovableValues.NPSGraphWidth = playerConfig:get_data().GameplaySizes[keymode].NPSGraphWidth
	MovableValues.NPSGraphHeight = playerConfig:get_data().GameplaySizes[keymode].NPSGraphHeight
	MovableValues.NPSDisplayX = playerConfig:get_data().GameplayXYCoordinates[keymode].NPSDisplayX
	MovableValues.NPSDisplayY = playerConfig:get_data().GameplayXYCoordinates[keymode].NPSDisplayY
	MovableValues.NPSDisplayZoom = playerConfig:get_data().GameplaySizes[keymode].NPSDisplayZoom
	MovableValues.LeaderboardX = playerConfig:get_data().GameplayXYCoordinates[keymode].LeaderboardX
	MovableValues.LeaderboardY = playerConfig:get_data().GameplayXYCoordinates[keymode].LeaderboardY
	MovableValues.LeaderboardSpacing = playerConfig:get_data().GameplaySizes[keymode].LeaderboardSpacing
	MovableValues.LeaderboardWidth = playerConfig:get_data().GameplaySizes[keymode].LeaderboardWidth
	MovableValues.LeaderboardHeight = playerConfig:get_data().GameplaySizes[keymode].LeaderboardHeight
	MovableValues.LifeP1X = playerConfig:get_data().GameplayXYCoordinates[keymode].LifeP1X
	MovableValues.LifeP1Y = playerConfig:get_data().GameplayXYCoordinates[keymode].LifeP1Y
	MovableValues.LifeP1Rotation = playerConfig:get_data().GameplayXYCoordinates[keymode].LifeP1Rotation
	MovableValues.LifeP1Width = playerConfig:get_data().GameplaySizes[keymode].LifeP1Width
	MovableValues.LifeP1Height = playerConfig:get_data().GameplaySizes[keymode].LifeP1Height
	MovableValues.PracticeCDGraphX = playerConfig:get_data().GameplayXYCoordinates[keymode].PracticeCDGraphX
	MovableValues.PracticeCDGraphY = playerConfig:get_data().GameplayXYCoordinates[keymode].PracticeCDGraphY
	MovableValues.PracticeCDGraphHeight = playerConfig:get_data().GameplaySizes[keymode].PracticeCDGraphHeight
	MovableValues.PracticeCDGraphWidth = playerConfig:get_data().GameplaySizes[keymode].PracticeCDGraphWidth
	MovableValues.BPMTextX = playerConfig:get_data().GameplayXYCoordinates[keymode].BPMTextX
	MovableValues.BPMTextY = playerConfig:get_data().GameplayXYCoordinates[keymode].BPMTextY
	MovableValues.BPMTextZoom = playerConfig:get_data().GameplaySizes[keymode].BPMTextZoom
	MovableValues.MusicRateX = playerConfig:get_data().GameplayXYCoordinates[keymode].MusicRateX
	MovableValues.MusicRateY = playerConfig:get_data().GameplayXYCoordinates[keymode].MusicRateY
	MovableValues.MusicRateZoom = playerConfig:get_data().GameplaySizes[keymode].MusicRateZoom
	MovableValues.PlayerInfoX = playerConfig:get_data().GameplayXYCoordinates[keymode].PlayerInfoX
	MovableValues.PlayerInfoY = playerConfig:get_data().GameplayXYCoordinates[keymode].PlayerInfoY
	MovableValues.PlayerInfoZoom = playerConfig:get_data().GameplaySizes[keymode].PlayerInfoZoom
end

-- registry for elements which are able to be modified in customizegameplay
local customizeGameplayElements = {}
local storedStateForUndoAction = {}
local selectedElementActor = nil
function registerActorToCustomizeGameplayUI(elementFrame, layer)
	customizeGameplayElements[#customizeGameplayElements+1] = elementFrame

	if allowedCustomization then
		elementFrame:AddChildFromPath(THEME:GetPathG("", "elementborder"))
		if layer ~= nil then
			elementFrame:GetChild("BorderContainer"):RunCommandsRecursively(
				function(self)
					local cmd = function(shelf)
						shelf:z(layer)
					end
					self:addcommand("SetUpFinished", cmd)
				end)
		end
	end
end

function getCustomizeGameplayElements()
	return customizeGameplayElements
end

function getCoordinatesForElementName(name)
	local xv = playerConfig:get_data().GameplayXYCoordinates[keymode][name .. "X"]
	local yv = playerConfig:get_data().GameplayXYCoordinates[keymode][name .. "Y"]
	local rotZv = playerConfig:get_data().GameplayXYCoordinates[keymode][name .. "Rotation"]
	
	return {
		x = xv,
		y = yv,
		rotation = rotZv,
	}
end

function getSizesForElementName(name)
	local zoom = playerConfig:get_data().GameplaySizes[keymode][name .. "Zoom"]
	local width = playerConfig:get_data().GameplaySizes[keymode][name .. "Width"]
	local height = playerConfig:get_data().GameplaySizes[keymode][name .. "Height"]
	local spacing = playerConfig:get_data().GameplaySizes[keymode][name .. "Spacing"]

	return {
		zoom = zoom,
		width = width,
		height = height,
		spacing = spacing,
	}
end

function elementHasAnyMovableCoordinates(name)
	return playerConfig:get_data().GameplayXYCoordinates[keymode][name .. "X"] ~= nil or playerConfig:get_data().GameplayXYCoordinates[keymode][name .. "Y"]
end

-- store the current state of the element for an undo action later
-- if necessary
function setStoredStateForUndoAction(name)
	storedStateForUndoAction.coords = getCoordinatesForElementName(name)
	storedStateForUndoAction.sizes = getSizesForElementName(name)
	storedStateForUndoAction.name = name
	storedStateForUndoAction.actor = selectedElementActor
end

function getStoredStateForUndoAction()
	return storedStateForUndoAction
end

-- execute an undo action
function resetElementUsingStoredState()
	local coord = storedStateForUndoAction.coords
	local size = storedStateForUndoAction.sizes
	if storedStateForUndoAction.name == nil or storedStateForUndoAction.actor == nil then
		return
	end
	local name = storedStateForUndoAction.name
	local actor = storedStateForUndoAction.actor

	if coord ~= nil then
		if coord.x ~= nil then
			local tname = name .. "X"
			local v = coord.x
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = v
			MovableValues[tname] = v
		end
		if coord.y ~= nil then
			local tname = name .. "Y"
			local v = coord.y
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = v
			MovableValues[tname] = v
		end
		if coord.rotation ~= nil then
			local tname = name .. "Rotation"
			local v = coord.rotation
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = v
			MovableValues[tname] = v
		end
	end
	if size ~= nil then
		if size.zoom ~= nil then
			local tname = name .. "Zoom"
			local v = size.zoom
			playerConfig:get_data().GameplaySizes[keymode][tname] = v
			MovableValues[tname] = v
		end
		if size.width ~= nil then
			local tname = name .. "Width"
			local v = size.width
			playerConfig:get_data().GameplaySizes[keymode][tname] = v
			MovableValues[tname] = v
		end
		if size.height ~= nil then
			local tname = name .. "Height"
			local v = size.height
			playerConfig:get_data().GameplaySizes[keymode][tname] = v
			MovableValues[tname] = v
		end
		if size.spacing ~= nil then
			local tname = name .. "Spacing"
			local v = size.spacing
			playerConfig:get_data().GameplaySizes[keymode][tname] = v
			MovableValues[tname] = v
		end
	end
	-- tell everything to update MovableValues (lazy)
	MESSAGEMAN:Broadcast("SetUpMovableValues")

	playerConfig:set_dirty()
	-- alert ui of update
	MESSAGEMAN:Broadcast("CustomizeGameplayElementUndo", {name=name})
end

-- reset an element to its default state
-- this leverages the storedStateForUndoAction
-- as such, you need to setStoredStateForUndoAction first
-- which basically means you utilized setSelectedCustomizeGameplayElementActorByName
-- (an element must be first selected to be reset to default.)
function resetElementToDefault()
	local coord = storedStateForUndoAction.coords
	local size = storedStateForUndoAction.sizes
	if storedStateForUndoAction.name == nil or storedStateForUndoAction.actor == nil then
		return
	end
	local name = storedStateForUndoAction.name
	local actor = storedStateForUndoAction.actor

	if coord ~= nil then
		if coord.x ~= nil then
			local tname = name .. "X"
			local default = getDefaultGameplayCoordinate(tname)
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = default
			MovableValues[tname] = default
		end
		if coord.y ~= nil then
			local tname = name .. "Y"
			local default = getDefaultGameplayCoordinate(tname)
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = default
			MovableValues[tname] = default
		end
		if coord.rotation ~= nil then
			local tname = name .. "Rotation"
			local default = getDefaultGameplayCoordinate(tname)
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = default
			MovableValues[tname] = default
		end
	end
	if size ~= nil then
		if size.zoom ~= nil then
			local tname = name .. "Zoom"
			local default = getDefaultGameplaySize(tname)
			playerConfig:get_data().GameplaySizes[keymode][tname] = default
			MovableValues[tname] = default
		end
		if size.width ~= nil then
			local tname = name .. "Width"
			local default = getDefaultGameplaySize(tname)
			playerConfig:get_data().GameplaySizes[keymode][tname] = default
			MovableValues[tname] = default
		end
		if size.height ~= nil then
			local tname = name .. "Height"
			local default = getDefaultGameplaySize(tname)
			playerConfig:get_data().GameplaySizes[keymode][tname] = default
			MovableValues[tname] = default
		end
		if size.spacing ~= nil then
			local tname = name .. "Spacing"
			local default = getDefaultGameplaySize(tname)
			playerConfig:get_data().GameplaySizes[keymode][tname] = default
			MovableValues[tname] = default
		end
	end
	-- tell everything to update MovableValues (lazy)
	MESSAGEMAN:Broadcast("SetUpMovableValues")

	playerConfig:set_dirty()
	-- alert ui of update
	MESSAGEMAN:Broadcast("CustomizeGameplayElementDefaulted", {name=name})
end

function setSelectedCustomizeGameplayElementActorByName(elementName)
	local index = 0
	local elementActor = nil
	for i, e in ipairs(customizeGameplayElements) do
		if e:GetName() == elementName then
			index = i
			elementActor = e
			break
		end
	end

	-- element found, set up things
	if elementActor ~= nil then
		selectedElementActor = elementActor
		MESSAGEMAN:Broadcast("CustomizeGameplayElementSelected", {name=elementName})
	end
	return elementHasAnyMovableCoordinates(elementName)
end

function getSelectedCustomizeGameplayMovableActor()
	return selectedElementActor
end

-- set the new XY coordinates of an element using the DIFFERENCE from before it was changed and the new value
-- mostly just meant to be used with the mouse dragging functionality
function setSelectedCustomizeGameplayElementActorPosition(differenceX, differenceY)
	if selectedElementActor ~= nil then
		local name = selectedElementActor:GetName()
		local xv = playerConfig:get_data().GameplayXYCoordinates[keymode][name .. "X"]
		local yv = playerConfig:get_data().GameplayXYCoordinates[keymode][name .. "Y"]

		if xv ~= nil then
			local tname = name .. "X"
			local v = xv + differenceX
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = v
			MovableValues[tname] = v
		end
		if yv ~= nil then
			local tname = name .. "Y"
			local v = yv + differenceY
			playerConfig:get_data().GameplayXYCoordinates[keymode][tname] = v
			MovableValues[tname] = v
		end
		playerConfig:set_dirty()
		MESSAGEMAN:Broadcast("CustomizeGameplayElementMoved", {name=name})
	end
end

local function updateCustomizeGameplayTables(tname, increment, tableName)
	if selectedElementActor ~= nil then
		local beforeVal = playerConfig:get_data()[tableName][keymode][tname]
		if beforeVal ~= nil then
			playerConfig:get_data()[tableName][keymode][tname] = beforeVal + increment
			MovableValues[tname] = beforeVal + increment
			playerConfig:set_dirty()
			-- tell everything to update MovableValues (lazy)
			MESSAGEMAN:Broadcast("SetUpMovableValues")
			MESSAGEMAN:Broadcast("CustomizeGameplayElementMoved", {name=selectedElementActor:GetName()})
		end
	end
end

-- set any GameplayXYCoordinates value using an increment of the existing value
function updateGameplayCoordinate(tname, increment)
	updateCustomizeGameplayTables(tname, increment, "GameplayXYCoordinates")
end

-- set any GameplaySizes value using an increment of the existing value
function updateGameplaySize(tname, increment)
	updateCustomizeGameplayTables(tname, increment, "GameplaySizes")
end

function unsetMovableKeymode()
	MovableValues = {}
	customizeGameplayElements = {}
end

function setMovableKeymode(key)
	keymode = key
	customizeGameplayElements = {}
	loadValuesTable()
end

local Round = notShit.round
local Floor = notShit.floor
local queuecommand = Actor.queuecommand
local playcommand = Actor.queuecommand
local settext = BitmapText.settext

local propsFunctions = {
	X = Actor.x,
	Y = Actor.y,
	Zoom = Actor.zoom,
	Height = Actor.zoomtoheight,
	Width = Actor.zoomtowidth,
	AddX = Actor.addx,
	AddY = Actor.addy,
	Rotation = Actor.rotationz,
}

Movable = {
	message = {},
	current = "None",
	pressed = false,
	DeviceButton_1 = {
		name = "Judge",
		textHeader = "Judgment Label Position:",
		element = {},
		children = {"Judgment", "Border"},
		properties = {"X", "Y"},
		propertyOffsets = nil,	-- manual offsets for stuff hardcoded to be relative to center and maybe other things (init in wifejudgmentspotting)
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_2 = {	-- note: there's almost certainly an update function associated with this that is doing things we aren't aware of
		name = "Judge",
		textHeader = "Judgment Label Size:",
		element = {},
		children = {"Judgment"},
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		noBorder = true,
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},
	DeviceButton_3 = {
		name = "Combo",
		textHeader = "Combo Position:",
		element = {},
		children = {"Label", "Number", "Border"},
		properties = {"X", "Y"},
		propertyOffsets = nil,
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_4 = {	-- combo and label are 2 text objects, 1 right aligned and 1 left, this makes border resizing desync from the text sometimes
		name = "Combo",	-- i really dont want to deal with this right now -mina
		textHeader = "Combo Size:",
		element = {},
		children = {"Label", "Number"},
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		noBorder = true,
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},
	DeviceButton_5 = {
		name = "ErrorBar",
		textHeader = "Error Bar Position:",
		element = {}, -- initialized later
		properties = {"X", "Y"},
		children = {"Center", "WeightedBar", "Border"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_6 = {
		name = "ErrorBar",
		textHeader = "Error Bar Size:",
		element = {},
		properties = {"Width", "Height"},
		children = {"Center", "WeightedBar"},
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			property = "Height",
			inc = 1
		},
		DeviceButton_down = {
			property = "Height",
			inc = -1
		},
		DeviceButton_left = {
			property = "Width",
			inc = -10
		},
		DeviceButton_right = {
			property = "Width",
			inc = 10
		}
	},
	DeviceButton_7 = {
		name = "TargetTracker",
		textHeader = "Goal Tracker Position:",
		element = {},
		properties = {"X", "Y"},
		-- no children so the changes are applied to the element itself
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_8 = {
		name = "TargetTracker",
		textHeader = "Goal Tracker Size:",
		element = {},
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},
	DeviceButton_9 = {
		name = "FullProgressBar",
		textHeader = "Full Progress Bar Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -3
		},
		DeviceButton_down = {
			property = "Y",
			inc = 3
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_0 = {
		name = "FullProgressBar",
		textHeader = "Full Progress Bar Size:",
		element = {},
		properties = {"Width", "Height"},
		elementTree = "GameplaySizes",
		noBorder = true,
		DeviceButton_up = {
			property = "Height",
			inc = 0.1
		},
		DeviceButton_down = {
			property = "Height",
			inc = -0.1
		},
		DeviceButton_left = {
			property = "Width",
			inc = -0.01
		},
		DeviceButton_right = {
			property = "Width",
			inc = 0.01
		}
	},
	DeviceButton_q = {
		name = "MiniProgressBar",
		textHeader = "Mini Progress Bar Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_w = {
		name = "DisplayPercent",
		textHeader = "Current Percent Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_e = {
		name = "DisplayPercent",
		textHeader = "Current Percent Size:",
		element = {},
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},
	DeviceButton_r = {
		name = "NoteField",
		textHeader = "NoteField Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		noBorder = true,
		DeviceButton_up = {
			notefieldY = true,
			property = "AddY",
			inc = -3
		},
		DeviceButton_down = {
			notefieldY = true,
			property = "AddY",
			inc = 3
		},
		DeviceButton_left = {
			property = "AddX",
			inc = -3
		},
		DeviceButton_right = {
			property = "AddX",
			inc = 3
		}
	},
	DeviceButton_t = {
		name = "NoteField",
		textHeader = "NoteField Size:",
		element = {},
		elementList = true, -- god bless the notefield
		properties = {"Width", "Height"},
		elementTree = "GameplaySizes",
		noBorder = true,
		DeviceButton_up = {
			property = "Height",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Height",
			inc = -0.01
		},
		DeviceButton_left = {
			property = "Width",
			inc = -0.01
		},
		DeviceButton_right = {
			property = "Width",
			inc = 0.01
		}
	},
	DeviceButton_y = {
		name = "NPSDisplay",
		textHeader = "NPS Display Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_u = {
		name = "NPSDisplay",
		textHeader = "NPS Display Size:",
		element = {},
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},
	DeviceButton_i = {
		name = "NPSGraph",
		textHeader = "NPS Graph Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_o = {
		name = "NPSGraph",
		textHeader = "NPS Graph Size:",
		element = {},
		properties = {"Width", "Height"},
		noBorder = true,
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			property = "Height",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Height",
			inc = -0.01
		},
		DeviceButton_left = {
			property = "Width",
			inc = -0.01
		},
		DeviceButton_right = {
			property = "Width",
			inc = 0.01
		}
	},
	DeviceButton_p = {
		name = "JudgeCounter",
		textHeader = "Judge Counter Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -3
		},
		DeviceButton_down = {
			property = "Y",
			inc = 3
		},
		DeviceButton_left = {
			property = "X",
			inc = -3
		},
		DeviceButton_right = {
			property = "X",
			inc = 3
		}
	},
	DeviceButton_a = {
		name = "Leaderboard",
		textHeader = "Leaderboard Position:",
		properties = {"X", "Y"},
		element = {},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -3
		},
		DeviceButton_down = {
			property = "Y",
			inc = 3
		},
		DeviceButton_left = {
			property = "X",
			inc = -3
		},
		DeviceButton_right = {
			property = "X",
			inc = 3
		}
	},
	DeviceButton_s = {
		name = "Leaderboard",
		textHeader = "Leaderboard Size:",
		properties = {"Width", "Height"},
		element = {},
		elementTree = "GameplaySizes",
		noBorder = true,
		DeviceButton_up = {
			property = "Height",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Height",
			inc = -0.01
		},
		DeviceButton_left = {
			property = "Width",
			inc = -0.01
		},
		DeviceButton_right = {
			property = "Width",
			inc = 0.01
		}
	},
	DeviceButton_d = {
		name = "Leaderboard",
		textHeader = "Leaderboard Spacing:",
		properties = {"Spacing"},
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			arbitraryInc = true,
			property = "Spacing",
			inc = -0.3
		},
		DeviceButton_down = {
			arbitraryInc = true,
			property = "Spacing",
			inc = 0.3
		},
	},
	DeviceButton_f = {
		name = "ReplayButtons",
		textHeader = "Replay Buttons Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		condition = false,
		DeviceButton_up = {
			property = "Y",
			inc = -3
		},
		DeviceButton_down = {
			property = "Y",
			inc = 3
		},
		DeviceButton_left = {
			property = "X",
			inc = -3
		},
		DeviceButton_right = {
			property = "X",
			inc = 3
		}
	},--[[
	DeviceButton_g = {
		name = "ReplayButtons",
		textHeader = "Replay Buttons Size:",
		element = {},
		noBorder = true,
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		condition = false,
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},]]
	DeviceButton_h = {
		name = "ReplayButtons",
		textHeader = "Replay Buttons Spacing:",
		properties = {"Spacing"},
		elementTree = "GameplaySizes",
		condition = false,
		DeviceButton_up = {
			arbitraryInc = true,
			property = "Spacing",
			inc = -0.5
		},
		DeviceButton_down = {
			arbitraryInc = true,
			property = "Spacing",
			inc = 0.5
		},
	},
	DeviceButton_j = {
		name = "LifeP1",
		textHeader = "Lifebar Position:",
		element = {},
		properties = {"X", "Y"},
		-- propertyOffsets = {"178", "10"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -3
		},
		DeviceButton_down = {
			property = "Y",
			inc = 3
		},
		DeviceButton_left = {
			property = "X",
			inc = -3
		},
		DeviceButton_right = {
			property = "X",
			inc = 3
		}
	},
	DeviceButton_k = {
		name = "LifeP1",
		textHeader = "Lifebar Size:",
		properties = {"Width", "Height"},
		element = {},
		elementTree = "GameplaySizes",
		noBorder = true,
		DeviceButton_up = {
			property = "Height",
			inc = 0.1
		},
		DeviceButton_down = {
			property = "Height",
			inc = -0.1
		},
		DeviceButton_left = {
			property = "Width",
			inc = -0.01
		},
		DeviceButton_right = {
			property = "Width",
			inc = 0.01
		}
	},
	DeviceButton_l = {
		name = "LifeP1",
		textHeader = "Lifebar Rotation:",
		properties = {"Rotation"},
		element = {},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Rotation",
			inc = -1
		},
		DeviceButton_down = {
			property = "Rotation",
			inc = 1
		},
	},
	DeviceButton_z = {
		name = "PracticeCDGraph",
		textHeader = "Chord Density Graph Position:",
		properties = {"X","Y"},
		element = {},
		elementTree = "GameplayXYCoordinates",
		propertyOffsets = nil,
		DeviceButton_up = {
			property = "Y",
			inc = -3
		},
		DeviceButton_down = {
			property = "Y",
			inc = 3
		},
		DeviceButton_left = {
			property = "X",
			inc = -3
		},
		DeviceButton_right = {
			property = "X",
			inc = 3
		}
	},
	--[[DeviceButton_x = {
		name = "PracticeCDGraph",
		textHeader = "Chord Density Graph Size:",
		properties = {"Width", "Height"},
		element = {},
		elementTree = "GameplaySizes",
		propertyOffsets = nil,
		DeviceButton_up = {
			property = "Height",
			inc = 0.1
		},
		DeviceButton_down = {
			property = "Height",
			inc = -0.1
		},
		DeviceButton_left = {
			property = "Width",
			inc = -0.01
		},
		DeviceButton_right = {
			property = "Width",
			inc = 0.01
		}
	},]]
	DeviceButton_x = {
		name = "BPMText",
		textHeader = "BPM Text Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_c = {
		name = "BPMText",
		textHeader = "BPM Text Size:",
		element = {},
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},
	DeviceButton_v = {
		name = "MusicRate",
		textHeader = "Music Rate Position:",
		element = {},
		properties = {"X", "Y"},
		elementTree = "GameplayXYCoordinates",
		DeviceButton_up = {
			property = "Y",
			inc = -5
		},
		DeviceButton_down = {
			property = "Y",
			inc = 5
		},
		DeviceButton_left = {
			property = "X",
			inc = -5
		},
		DeviceButton_right = {
			property = "X",
			inc = 5
		}
	},
	DeviceButton_b = {
		name = "MusicRate",
		textHeader = "Music Rate Size:",
		element = {},
		properties = {"Zoom"},
		elementTree = "GameplaySizes",
		DeviceButton_up = {
			property = "Zoom",
			inc = 0.01
		},
		DeviceButton_down = {
			property = "Zoom",
			inc = -0.01
		}
	},
	DeviceButton_n = {
		name = "NoteField",
		textHeader = "NoteField Columns:",
		properties = {"Spacing"},
		elementTree = "GameplaySizes",
		noBorder = true,
		DeviceButton_up = {
			arbitraryInc = true,
			property = "Spacing",
			inc = 1
		},
		DeviceButton_down = {
			arbitraryInc = true,
			property = "Spacing",
			inc = -1
		},
	},
}

local function updatetext(button)
	local text = {Movable[button].textHeader}
	for _, prop in ipairs(Movable[button].properties) do
		local fullProp = Movable[button].name .. prop
		text[#text + 1] = prop .. ": " .. MovableValues[fullProp]
	end
	Movable.message:settext(table.concat(text, "\n"))
	Movable.message:visible(Movable.pressed)
end

function MovableInput(event)
	if SCREENMAN:GetTopScreen():GetName() == "ScreenGameplaySyncMachine" then return end
	if getAutoplay() ~= 0 then
		-- this will eat any other mouse input than a right click (toggle)
		-- so we don't have to worry about anything weird happening with the ersatz inputs -mina
		if event.DeviceInput.is_mouse then	
			if event.DeviceInput.button == "DeviceButton_right mouse button" then
				Movable.current = "None"
				Movable.pressed = false
				Movable.message:visible(Movable.pressed)
			end
			return 
		end

		local button = event.DeviceInput.button	
		event.hellothisismouse = event.hellothisismouse and true or false -- so that's why bools kept getting set to nil -mina
		local notReleased = not (event.type == "InputEventType_Release")
		-- changed to toggle rather than hold down -mina
		if (Movable[button] and Movable[button].condition and notReleased) or event.hellothisismouse then
			Movable.pressed = not Movable.pressed or event.hellothisismouse	-- this stuff is getting pretty hacky now -mina
			if Movable.current ~= event.DeviceInput.button and not event.hellothisismouse then
				Movable.pressed = true	-- allow toggling using the kb to directly move to a different key rather than forcing an untoggle first -mina
			end
			Movable.current = button
			if not Movable.pressed then 
				Movable.current = "None"
			end
			updatetext(button)	-- this will only update the text when the toggles occur
		end
		
		local current = Movable[Movable.current]

		-- left/right move along the x axis and up/down along the y; set them directly here -mina
		if event.hellothisismouse then
			if event.axis == "x" then
				button = "DeviceButton_left"
			else
				button = "DeviceButton_up"
			end
			Movable.pressed = true	-- we need to do this or the mouse input facsimile will toggle on when moving x, and off when moving y
		end
		
		if Movable.pressed and current[button] and current.condition and notReleased and current.external == nil then
			local curKey = current[button]
			local keyProperty = curKey.property
			local prop = current.name .. string.gsub(keyProperty, "Add", "")
			local newVal

			-- directly set newval if we're using the mouse -mina
			if event.hellothisismouse then
				newVal = event.val
			else
				newVal = MovableValues[prop] + (curKey.inc * ((curKey.notefieldY and not usingReverse) and -1 or 1))
			end
			
			MovableValues[prop] = newVal
			if curKey.arbitraryFunction then
				if curKey.arbitraryInc then
					curKey.arbitraryFunction(curKey.inc)
				else
					curKey.arbitraryFunction(newVal)
				end
			elseif current.children then
				for _, attribute in ipairs(current.children) do
					propsFunctions[curKey.property](current.element[attribute], newVal)
				end
			elseif current.elementList then
				for _, elem in ipairs(current.element) do
					propsFunctions[keyProperty](elem, newVal)
				end
			elseif keyProperty == "AddX" or keyProperty == "AddY" then
				propsFunctions[keyProperty](current.element, curKey.inc)
			else
				propsFunctions[keyProperty](current.element, newVal)
			end

			if not current.noBorder then
				local border = Movable[Movable.current]["Border"]
				if keyProperty == "Height" or keyProperty == "Width" or keyProperty == "Zoom" then
					border:playcommand("Change" .. keyProperty, {val = newVal} )
				end
			end

			if not event.hellothisismouse then
				updatetext(Movable.current)	-- updates text when keyboard movements are made (mouse already updated)
			end
			playerConfig:get_data()[current.elementTree][keymode][prop] = newVal
			playerConfig:set_dirty()
			-- commented this to save I/O time and reduce lag
			-- just make sure to call this somewhere else to make sure stuff saves.
			-- (like when the screen changes....)
			--playerConfig:save()
		end
	end
	return false
end
