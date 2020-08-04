--[[
	Note: This is still a WIP
	Feel free to contribute to it
--]]
local split = function(t, x)
    local t1, t2 = {}, {}
    local idx = nil
    -- Used to simulate a for break
    local aux = function()
        for i, v in ipairs(t) do
            if v == x then
                idx = t[i + 1] and i + 1 or nil
                return
            end
            t1[i] = v
        end
    end
    aux()
    while idx ~= nil do
        t2[#t2 + 1] = t[idx]
        idx = t[idx + 1] and idx + 1 or nil
    end
    return t1, t2
end

local findKeyOf = function(t, x)
    for k, v in pairs(t) do
        if v == x then
            return k
        end
    end
end

local clamp = function(x, l, u)
    if x < l then return l end
    if x > u then return u end
    return x
end

local find = function(t, x)
    local k = findKeyOf(t, x)
    return k and t[k] or nil
end

local concat = function(...)
    local arg = {...}
    local t = {}
    for i = 1, #arg do
        for i, v in ipairs(arg[i]) do
            t[#t + 1] = v
        end
    end
    return t
end
local Wheel = {}
local function fillNilTableFieldsFrom(table1, defaultTable)
    for key, value in pairs(defaultTable) do
        if table1[key] == nil then
            table1[key] = defaultTable[key]
        end
    end
end

local function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

local function print(x)
    SCREENMAN:SystemMessage(dump(x))
end

local function getIndexCircularly(table, idx)
    if idx <= 0 then
        return getIndexCircularly(table, idx + #table)
    elseif idx > #table then
        return getIndexCircularly(table, idx - #table)
    end
    return idx
end

-- false if outside of a group
-- true if inside a group
-- toggles within the move function
-- becomes false if all groups are closed
local crossedGroupBorder = false
local diffSelection = 1 -- index of the selected chart

Wheel.mt = {
    move = function(whee, num)
        if whee.moveInterval then
            SCREENMAN:GetTopScreen():clearInterval(whee.moveInterval)
        end
        if num == 0 then
            whee.moveInterval = nil
            return
        end
        whee.floatingOffset = num
        local interval = whee.pollingSeconds / 60
        whee.index = getIndexCircularly(whee.items, whee.index + num)
        whee.moveInterval =
            SCREENMAN:GetTopScreen():setInterval(
            function()
                whee.floatingOffset = whee.floatingOffset - num / (whee.pollingSeconds / interval)
                if num < 0 and whee.floatingOffset >= 0 or num > 0 and whee.floatingOffset <= 0 then
                    SCREENMAN:GetTopScreen():clearInterval(whee.moveInterval)
                    whee.moveInterval = nil
                    whee.floatingOffset = 0
                end
                whee:update()
            end,
            interval
        )

        SOUND:StopMusic()

        -- update Gamestate current song
        -- subtract 1 because the getCurrentItem follows that behavior
        local currentItem = whee:getItem(whee.index - 1)
        if currentItem.GetDisplayMainTitle then
            -- currentItem is a SONG
            GAMESTATE:SetCurrentSong(currentItem)

            -- setting diff stuff
            local stepslist = currentItem:GetChartsOfCurrentGameMode()
            if #stepslist == 0 then
                -- this scenario should be impossible but lets prepare for the case
                diffSelection = 1
                GAMESTATE:SetCurrentSteps(PLAYER_1, nil)
            else
                local prefdiff = GAMESTATE:GetPreferredDifficulty()
                diffSelection = clamp(diffSelection, 1, #stepslist)
                for i = 1,#stepslist do
                    if stepslist[i]:GetDifficulty() == prefdiff then
                        diffSelection = i
                        break
                    end
                end
                GAMESTATE:SetPreferredDifficulty(PLAYER_1, stepslist[diffSelection]:GetDifficulty())
                GAMESTATE:SetCurrentSteps(PLAYER_1, stepslist[diffSelection])
            end

            if whee.group and not crossedGroupBorder then
                crossedGroupBorder = not crossedGroupBorder
                -- header wheelitem behavior stuff
                whee.frameUpdater(whee.frames[1], whee.group, 0)
                whee.frames[1].sticky = true
                whee.frames[1]:playcommand("HeaderOn", {offsetFromCenter = -math.ceil(whee.count / 2)})

                MESSAGEMAN:Broadcast("ScrolledIntoGroup", {group = whee.group})
            end
        else
            -- currentItem is a GROUP
            GAMESTATE:SetCurrentSong(nil)
            GAMESTATE:SetCurrentSteps(PLAYER_1, nil)
            if whee.group and crossedGroupBorder then
                crossedGroupBorder = not crossedGroupBorder
                -- header wheelitem behavior stuff
                whee.frames[1].sticky = false
                whee.frameUpdater(whee.frames[1], whee:getItem(whee.index - math.ceil(whee.count / 2)), 0)
                whee.frames[1]:playcommand("HeaderOff")

                MESSAGEMAN:Broadcast("ScrolledOutOfGroup", {group = whee.group})
            end
        end
        
    end,
    getItem = function(whee, idx)
        return whee.items[getIndexCircularly(whee.items, idx)]
        -- For some reason i have to +1 here
    end,
    getCurrentItem = function(whee)
        -- subtract 1 because i wanted to move the select index up by 1
        return whee:getItem(whee.index - 1)
    end,
    getFrame = function(whee, idx)
        return whee.frames[getIndexCircularly(whee.frames, idx)]
        -- For some reason i have to +1 here
    end,
    getCurrentFrame = function(whee)
        -- subtract 1 because i wanted to move the select index up by 1
        return whee:getFrame(whee.index - 1)
    end,
    update = function(whee)
        local numFrames = #(whee.frames)
        local idx = whee.index
        idx = idx - math.ceil(numFrames / 2)
        for i, frame in ipairs(whee.frames) do
            local offset = i - math.ceil(numFrames / 2) + whee.floatingOffset
            whee.frameTransformer(frame, offset - 1, i, whee.count)
            whee.frameUpdater(frame, whee:getItem(idx), offset)
            idx = idx + 1
        end

        -- the wheel has settled
        if whee.floatingOffset == 0 and not whee.settled then
            MESSAGEMAN:Broadcast("WheelSettled", {song = GAMESTATE:GetCurrentSong(), group = whee.group})
            whee.settled = true
            local top = SCREENMAN:GetTopScreen()
            -- only for ScreenSelectMusic
            if top.PlayCurrentSongSampleMusic then
                if GAMESTATE:GetCurrentSong() ~= nil then
                    -- currentItem should be a song
                    top:PlayCurrentSongSampleMusic(false)
                end
            end
        end
        if whee.floatingOffset ~= 0 then
            whee.settled = false
        end
    end,
    rebuildFrames = function(whee, newIndex)
        whee.items = whee.itemsGetter()
        if whee.sort then
            table.sort(whee.items, whee.sort)
        end
        if not whee.index then
            whee.index = newIndex or whee.startIndex
        end
        whee:update()
    end
}

Wheel.defaultParams = {
    itemsGetter = function()
        -- Should return an array table of elements for the wheel
        -- This is a function so it can be delayed, and rebuilt
        --  with different items using this function
        return SONGMAN:GetAllSongs()
    end,
    count = 20,
    frameBuilder = function()
        return LoadFont("Common Normal") .. {}
    end,
    frameUpdater = function(frame, item) -- Update an frame created with frameBuilder with an item
        frame:settext(item:GetMainTitle())
    end,
    x = 0,
    y = 0,
    highlightBuilder = function()
        return Def.ActorFrame {}
    end,
    buildOnInit = true, -- Build wheel in InitCommand (Will be empty until rebuilt otherwise)
    frameTransformer = function(frame, offsetFromCenter, index, total) -- Handle frame positioning
        frame:y(offsetFromCenter * 30)
    end,
    startIndex = 1,
    speed = 15,
    onSelection = nil, -- function(item)
    sort = nil -- function(a,b) return boolean end
}
function Wheel:new(params)
    params = params or {}
    fillNilTableFieldsFrom(params, Wheel.defaultParams)
    local whee = Def.ActorFrame {}
    setmetatable(whee, {__index = Wheel.mt})
    crossedGroupBorder = false -- reset default
    diffSelection = 1 -- reset default
    whee.settled = false -- leaving this false causes 1 settle message on init
    whee.itemsGetter = params.itemsGetter
    whee.count = params.count
    whee.sort = params.sort
    whee.startIndex = params.startIndex
    whee.frameUpdater = params.frameUpdater
    whee.floatingOffset = 0
    whee.buildOnInit = params.buildOnInit
    whee.frameTransformer = params.frameTransformer
    whee.index = whee.startIndex
    whee.onSelection = params.onSelection
    whee.pollingSeconds = 1 / params.speed
    whee.x = params.x
    whee.y = params.y
    whee.moveHeight = 10
    whee.items = {}
    whee.BeginCommand = function(self)
        local interval = nil
        SCREENMAN:GetTopScreen():AddInputCallback(
            function(event)
                local gameButton = event.button
                local key = event.DeviceInput.button
                local left = gameButton == "MenuLeft" or key == "DeviceButton_left"
                local enter = gameButton == "Start" or key == "DeviceButton_enter"
                local right = gameButton == "MenuRight" or key == "DeviceButton_right"
                local exit = gameButton == "Back" or key == "DeviceButton_escape"
                if left or right then
                    if event.type == "InputEventType_FirstPress" then
                        if interval then
                            SCREENMAN:GetTopScreen():clearInterval(interval)
                        end
                        whee:move(right and 1 or -1)
                        interval =
                            SCREENMAN:GetTopScreen():setInterval(
                            function()
                                whee:move(right and 1 or -1)
                            end,
                            whee.pollingSeconds
                        )
                    elseif event.type == "InputEventType_Release" then
                        if interval then
                            SCREENMAN:GetTopScreen():clearInterval(interval)
                            interval = nil
                        end
                    end
                elseif enter then
                    if event.type == "InputEventType_FirstPress" then
                        whee.onSelection(whee:getCurrentFrame(), whee:getCurrentItem())
                    end
                elseif exit then
                    if event.type == "InputEventType_FirstPress" then
                        SCREENMAN:set_input_redirected(PLAYER_1, false)
                        SCREENMAN:GetTopScreen():Cancel()
                    end
                end
                return false
            end
        )
        SCREENMAN:GetTopScreen():setTimeout(
            function()
                if params.buildOnInit then
                    whee:rebuildFrames()
                end
            end,
            0.1
        )
    end
    whee.InitCommand = function(self)
        whee.actor = self
        local interval = false
        self:x(whee.x):y(whee.y)
    end
    whee.frames = {}
    for i = 1, (params.count) do
        local frame =
            params.frameBuilder() ..
            {
                InitCommand = function(self)
                    whee.frames[i] = self
                end
            }
        whee[#whee + 1] = frame
    end
    whee[#whee + 1] =
        params.highlightBuilder() ..
        {
            InitCommand = function(self)
                whee.highlight = self
            end
        }
    return whee
end
MusicWheel = {}
MusicWheel.defaultParams = {
    songActorBuilder = function()
        local s
        s =
            Def.ActorFrame {
            InitCommand = function(self)
                s.actor = self
            end,
            LoadFont("Common Normal") ..
                {
                    BeginCommand = function(self)
                        s.actor.fontActor = self
                    end
                }
        }
        return s
    end,
    groupActorBuilder = function()
        local g
        g =
            Def.ActorFrame {
            InitCommand = function(self)
                g.actor = self
            end,
            LoadFont("Common Normal") ..
                {
                    BeginCommand = function(self)
                        g.actor.fontActor = self
                    end
                }
        }
        return g
    end,
    songActorUpdater = function(self, song)
        (self.fontActor):settext(song:GetMainTitle())
    end,
    groupActorUpdater = function(self, packName)
        (self.fontActor):settext(packName)
    end,
    highlightBuilder = nil,
    frameTransformer = nil --function(frame, offsetFromCenter, index, total) -- Handle frame positioning
}

function MusicWheel:new(params)
    local noOverrideFrameBuilder = false
    local noOverrideFrameUpdater = false
    params = params or {}
    if params.frameBuilder ~= nil then
        noOverrideFrameBuilder = true
    end
    if params.frameUpdater ~= nil then
        noOverrideFrameUpdater = true
    end
    fillNilTableFieldsFrom(params, MusicWheel.defaultParams)
    local groupActorBuilder = params.groupActorBuilder
    local songActorBuilder = params.songActorBuilder
    local songActorUpdater = params.songActorUpdater
    local groupActorUpdater = params.groupActorUpdater
    
    -- Cache all pack counts
    local packCounts = SONGMAN:GetSongGroupNames()
    local function packCounter()
        for i, song in ipairs(SONGMAN:GetAllSongs()) do
            local pack = song:GetGroupName()
            local x = packCounts[pack]
            packCounts[pack] = x and x + 1 or 1
        end
    end
    packCounter()

    local w
    w =
        Wheel:new {
        count = params.count,
        frameTransformer = params.frameTransformer,
        x = params.x,
        highlightBuilder = params.highlightBuilder,
        y = params.y,
        frameBuilder = noOverrideFrameBuilder and params.frameBuilder or function()
            local x
            x =
                Def.ActorFrame {
                InitCommand = function(self)
                    x.actor = self
                end,
                groupActorBuilder() ..
                    {
                        BeginCommand = function(self)
                            x.actor.g = self
                        end
                    },
                songActorBuilder() ..
                    {
                        BeginCommand = function(self)
                            x.actor.s = self
                        end
                    }
            }
            return x
        end,
        frameUpdater = noOverrideFrameUpdater and params.frameUpdater or function(frame, songOrPack)
            if songOrPack.GetAllSteps then -- song
                -- Update songActor and make group actor invis
                local s = frame.s
                s:visible(true)
                local g = (frame.g)
                g:visible(false)
                songActorUpdater(s, songOrPack)
            else
                --update group actor and make song actor invis
                local s = frame.s
                s:visible(false)
                local g = (frame.g)
                g:visible(true)
                groupActorUpdater(g, songOrPack, packCounts[songOrPack])
            end
        end,
        onSelection = function(frame, songOrPack)
            if songOrPack.GetAllSteps then -- song
                crossedGroupBorder = true
                -- Start song
                -- TODO: Add C++
                -- SCREENMAN:GetTopScreen():StartSong(songOrPack)
                -- steps???
                MESSAGEMAN:Broadcast("SelectedSong")
            else
                local group = songOrPack
                if w.group and w.group == group then -- close pack
                    crossedGroupBorder = false
                    w.group = nil
                    local newItems = SONGMAN:GetSongGroupNames()
                    -- adding 1 here for a hack, prevent index from moving weirdly when opening pack
                    w.index = findKeyOf(newItems, group) + 1
                    w.itemsGetter = function()
                        return newItems
                    end

                    -- unset sticky for the header item
                    -- dont have to update the sticky bool
                    local replacinggroup = w:getItem(w.index - math.ceil(#w.frames / 2))
                    groupActorUpdater(w.frames[1].g, replacinggroup, packCounts[replacinggroup])
                    MESSAGEMAN:Broadcast("ClosedGroup", {group = group})
                else -- open pack
                    crossedGroupBorder = false
                    w.group = group
                    local groups = SONGMAN:GetSongGroupNames()
                    local g1, g2 = split(groups, group)
                    local newItems = concat(g1, {group}, SONGMAN:GetSongsInGroup(group), g2)
                    -- adding 1 here for a hack, prevent index from moving weirdly when opening pack
                    w.index = findKeyOf(newItems, group) + 1
                    w.itemsGetter = function()
                        return newItems
                    end

                    -- force update the header item
                    -- dont have to update the sticky bool
                    groupActorUpdater(w.frames[1].g, group, packCounts[group])
                    crossedGroupBorder = true
                    MESSAGEMAN:Broadcast("OpenedGroup", {group = group})
                end
                w:rebuildFrames()
            end
        end,
        itemsGetter = function()
            local groups = SONGMAN:GetSongGroupNames()
            table.sort(
                groups,
                function(a, b)
                    return a < b
                end
            )
            return groups
        end
    }
    return w
end

local function GetMetric(a, b)
    return THEME:GetMetric(a, b)
end
local function LegacyParams()
    local function SelectMusicWheelMetric(key)
        return GetMetric("ScreenSelectMusic", "MusicWheel" .. key)
    end
    local function MusicWheelMetric(key)
        return GetMetric("MusicWheel", key)
    end
    local function TextBannerMetric(key)
        return GetMetric("TextBanner", key)
    end
    local function MusicWheelItemMetric(key)
        return GetMetric("MusicWheelItem", key)
    end
    local wheelItemTypes = {
        "Custom",
        "Mode",
        "Portal",
        "Random",
        "Roulette",
        "SectionExpanded",
        "SectionCollapsed",
        "Song",
        "Sort"
    }
    local function loadGraphicFile(filename)
        return LoadActor(THEME:GetPathG("", filename))
    end
    local function loadMusicWheelThingActor(thing)
        return loadGraphicFile("MusicWheel " .. thing)
    end
    local function loadMusicWheelItemThingActor(thing)
        return loadGraphicFile("MusicWheelItem " .. thing)
    end
    local function loadMusicWheelItemTypePartLegacyActor(type, part)
        local str = type .. part
        return loadMusicWheelItemThingActor(type .. " " .. part .. "Part") ..
            {
                OnCommand = MusicWheelItemMetric(str .. "OnCommand"),
                InitCommand = function(self)
                    self:xy(MusicWheelItemMetric(str .. "X"), MusicWheelItemMetric(str .. "Y"))
                    self:playcommand("On")
                end
            }
    end
    local function loadMusicWheelItemTypeFontLegacyActor(type)
        return LoadFont("Common Normal") ..
            {
                Name = type,
                OnCommand = MusicWheelItemMetric(type .. "OnCommand"),
                InitCommand = function(self)
                    self:xy(MusicWheelItemMetric(type .. "X"), MusicWheelItemMetric(type .. "Y"))
                    self:playcommand("On")
                end
            }
    end
    local params = {}
    params.x = tonumber(SelectMusicWheelMetric("X")) - SCREEN_WIDTH / 2
    params.y = tonumber(SelectMusicWheelMetric("Y"))
    params.frameTransformer = MusicWheelMetric("ItemTransformFunction")
    params.count = MusicWheelMetric("NumWheelItems")
    --[[
    params.actorBuilders = {}
    for i = 1, #wheelItemTypes do
        local type = wheelItemTypes[i]
        params.actorBuilders[type] = constF(loadMusicWheelItemTypeLegacyActor(type))
    end
    -- TODO: grades isnt an item of params????
    params.actorBuilders.grades = constF(loadMusicWheelItemThingActor("grades"))
    params.actorBuilders.highlight = constF(loadGraphicFile("highlight"))
    ]]
    local TextBannerFont = function(type, t)
        return LoadFont("Common Normal") ..
            {
                BeginCommand = function(self)
                    (t.actor)[type] = self
                    self:playcommand("On")
                end,
                OnCommand = TextBannerMetric(type .. "OnCommand")
            }
    end
    params.songActorBuilder = function()
        local x = {}
        local t =
            Def.ActorFrame {
            InitCommand = function(self)
                x.actor = self
            end,
            Def.ActorFrame {
                InitCommand = function(self)
                    self:xy(MusicWheelItemMetric("SongNameX"), MusicWheelItemMetric("SongNameY"))
                end,
                OnCommand = MusicWheelItemMetric("SongNameOnCommand"),
                TextBannerFont("Title", x),
                TextBannerFont("Subtitle", x),
                TextBannerFont("Artist", x)
            },
            loadMusicWheelItemThingActor("grades") ..
                {
                    BeginCommand = function(self)
                        self:xy(MusicWheelItemMetric("GradeP1X"), MusicWheelItemMetric("GradeP1Y"))
                        x.actor.grades = self
                    end
                }
        }
        return t
    end
    params.groupActorBuilder = function()
        local g
        g =
            Def.ActorFrame {
            InitCommand = function(self)
                g.actor = self
            end
        }
        --[[
        for i, v in pairs(wheelItemTypes) do
            if v ~= "Song" then
                g[#g + 1] =
                    loadMusicWheelItemTypeFontLegacyActor(v) ..
                    {
                        BeginCommand = function(self)
                            g.actor[v] = self
                        end
                    }
            end
        end
        --]]
        g[#g + 1] =
            loadMusicWheelItemTypeFontLegacyActor("SectionCollapsed") ..
            {
                BeginCommand = function(self)
                    g.actor.SectionCollapsed = self
                end
            }
        g[#g + 1] =
            LoadFont("Common Normal") ..
            {
                Name = "SectionCount",
                OnCommand = MusicWheelItemMetric("SectionCountOnCommand"),
                BeginCommand = function(self)
                    self:xy(MusicWheelItemMetric("SectionCountX"), MusicWheelItemMetric("SectionCountY"))
                    self:playcommand("On")
                    g.actor.sectionCount = self
                end
            }
        return g
    end
    params.songActorUpdater = function(self, song)
        self.Title:settext(song:GetDisplayMainTitle())
        self.Subtitle:settext(song:GetDisplaySubTitle())
        self.Artist:settext(song:GetDisplayArtist())
        self:diffuse(SONGMAN:GetSongColor(song))
        -- TODO: grade params
        self.grades:playcommand(
            "SetGrade",
            {
                Grade = nil, --"Grade_None"
                Difficulty = "Beginner",
                HasGoal = false,
                Favorited = song:IsFavorited(),
                PermaMirror = false,
                PlayerNumber = PLAYER_1
            }
        )
    end
    params.groupActorUpdater = function(self, packName, count)
        self.SectionCollapsed:settext(packName)
        self.SectionCollapsed:diffuse(SONGMAN:GetSongGroupColor(packName))
        self.sectionCount:settext(tostring(count))
    end
    params.highlightBuilder = function()
        return loadMusicWheelThingActor("highlight")
    end
    return params
end

function MusicWheel:Legacy()
    return MusicWheel:new(LegacyParams())
end
