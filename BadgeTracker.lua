-- BadgeTracker: Tracks Badge of Justice boss kills and loot
BadgeTracker = {}

-- Badge of Justice item ID
local BADGE_OF_JUSTICE_ID = 29434

-- Detect current phase based on what content is available
function BadgeTracker:DetectPhase()
    -- Simple check: If we have any saved instance data for Magisters' Terrace, we're in Phase 5+
    -- Otherwise, assume Phase 1 (which includes all base heroic dungeons)
    
    local numSavedInstances = GetNumSavedInstances()
    for i = 1, numSavedInstances do
        local name = GetSavedInstanceInfo(i)
        if name and string.find(name, "Magisters") then
            return 5
        end
    end
    
    -- Default to showing all base heroic dungeons
    -- We'll default to phase 1 which is safe - it just won't show MGT until phase 5
    return 1
end

-- Database of heroic dungeon bosses that drop Badges of Justice
-- Phase 1: All heroic dungeons
local BADGE_BOSSES_PHASE1 = {
    ["Hellfire Citadel: Hellfire Ramparts"] = {
        "Watchkeeper Gargolmar",
        "Omor the Unscarred",
        "Nazan"  -- Badge drops from Reinforced Fel Iron Chest after Nazan dies
    },
    ["Hellfire Citadel: The Blood Furnace"] = {
        "The Maker",
        "Broggok",
        "Keli'dan the Breaker"
    },
    ["Hellfire Citadel: The Shattered Halls"] = {
        "Grand Warlock Nethekurse",
        "Blood Guard Porung",
        "Warbringer O'mrogg",
        "Warchief Kargath Bladefist",
        "Shattered Hand Executioner"
    },
    ["Coilfang Reservoir: The Slave Pens"] = {
        "Mennu the Betrayer",
        "Rokmar the Crackler",
        "Quagmirran"
    },
    ["Coilfang Reservoir: The Underbog"] = {
        "Hungarfen",
        "Ghaz'an",
        "Swamplord Musel'ek",
        "The Black Stalker"
    },
    ["Coilfang Reservoir: The Steamvault"] = {
        "Hydromancer Thespia",
        "Mekgineer Steamrigger",
        "Warlord Kalithresh"
    },
    ["Auchindoun: Mana-Tombs"] = {
        "Pandemonius",
        "Tavarok",
        "Yor",
        "Nexus-Prince Shaffar"
    },
    ["Auchindoun: Auchenai Crypts"] = {
        "Shirrak the Dead Watcher",
        "Exarch Maladaar"
    },
    ["Auchindoun: Sethekk Halls"] = {
        "Darkweaver Syth",
        "Anzu",
        "Talon King Ikiss"
    },
    ["Auchindoun: Shadow Labyrinth"] = {
        "Ambassador Hellmaw",
        "Blackheart the Inciter",
        "Grandmaster Vorpil",
        "Murmur"
    },
    ["Tempest Keep: The Mechanar"] = {
        "Gatewatcher Gyro-Kill",
        "Gatewatcher Iron-Hand",
        "Mechano-Lord Capacitus",
        "Nethermancer Sepethrea",
        "Pathaleon the Calculator"
    },
    ["Tempest Keep: The Botanica"] = {
        "Commander Sarannis",
        "High Botanist Freywinn",
        "Thorngrin the Tender",
        "Laj",
        "Warp Splinter"
    },
    ["Tempest Keep: The Arcatraz"] = {
        "Zereketh the Unbound",
        "Dalliah the Doomsayer",
        "Wrath-Scryer Soccothrates",
        "Harbinger Skyriss"
    },
    ["Caverns of Time: Old Hillsbrad Foothills"] = {
        "Lieutenant Drake",
        "Captain Skarloc",
        "Epoch Hunter"
    },
    ["Caverns of Time: The Black Morass"] = {
        "Chrono Lord Deja",
        "Temporus",
        "Aeonus"
    }
}

-- Phase 5 adds Magisters' Terrace
local BADGE_BOSSES_PHASE5 = {
    ["Magisters' Terrace"] = {
        "Selin Fireheart",
        "Vexallus",
        "Priestess Delrissa",
        "Kael'thas Sunstrider"
    }
}

-- Raids that drop badges (weekly reset)
-- Phase 4+: Karazhan starts dropping badges
local BADGE_RAIDS_PHASE4 = {
    ["Karazhan"] = {
        "Attumen the Huntsman",
        "Moroes",
        "Maiden of Virtue",
        "The Crone",  -- Opera Event - Wizard of Oz
        "The Big Bad Wolf",  -- Opera Event - Red Riding Hood
        "Romulo and Julianne",  -- Opera Event - Romeo and Juliet
        "The Curator",
        "Shade of Aran",
        "Terestian Illhoof",
        "Netherspite",
        "King Llane",  -- Chess Event - Alliance victory
        "Warchief Blackhand",  -- Chess Event - Horde victory
        "Prince Malchezaar"
    }
}

-- Get the appropriate badge boss list based on current phase
function BadgeTracker:GetBadgeBosses()
    if not self.cachedPhase then
        self.cachedPhase = self:DetectPhase()
    end
    
    local bosses = {}
    
    -- Copy Phase 1 dungeons (always available)
    for dungeon, bosslist in pairs(BADGE_BOSSES_PHASE1) do
        bosses[dungeon] = bosslist
    end
    
    -- Add Karazhan if badges have been enabled (someone has looted one)
    if BadgeTrackerDB.karazhanBadgesEnabled then
        for raid, bosslist in pairs(BADGE_RAIDS_PHASE4) do
            bosses[raid] = bosslist
        end
    end
    
    -- Add Phase 5 content if available
    if self.cachedPhase >= 5 then
        for dungeon, bosslist in pairs(BADGE_BOSSES_PHASE5) do
            bosses[dungeon] = bosslist
        end
    end
    
    return bosses
end

-- Wrapper to maintain backward compatibility
local function GetBadgeBosses()
    return BadgeTracker:GetBadgeBosses()
end

-- Initialize saved variables
function BadgeTracker:OnLoad()
    if not BadgeTrackerDB then
        BadgeTrackerDB = {
            dailyKills = {},
            weeklyKills = {},
            lastResetDate = date("%Y-%m-%d"),
            nextDailyResetTime = nil,
            nextWeeklyResetTime = nil,
            karazhanBadgesEnabled = false,  -- Will be set to true when first badge is looted
            minimap = {
                hide = false,
                minimapPos = 225
            }
        }
    end
    
    -- Migrate old nextResetTime to nextDailyResetTime
    if BadgeTrackerDB.nextResetTime then
        BadgeTrackerDB.nextDailyResetTime = BadgeTrackerDB.nextResetTime
        BadgeTrackerDB.nextResetTime = nil
    end
    
    -- Ensure minimap settings exist
    if not BadgeTrackerDB.minimap then
        BadgeTrackerDB.minimap = {
            hide = false,
            minimapPos = 225
        }
    end
    
    -- Ensure tables exist (but don't overwrite!)
    if not BadgeTrackerDB.weeklyKills then
        BadgeTrackerDB.weeklyKills = {}
    end
    if not BadgeTrackerDB.dailyKills then
        BadgeTrackerDB.dailyKills = {}
    end
    if BadgeTrackerDB.karazhanBadgesEnabled == nil then
        BadgeTrackerDB.karazhanBadgesEnabled = false
    end
    
    -- Note: nextDailyResetTime and nextWeeklyResetTime can be nil - that's okay!
    -- They will be set when we first run a dungeon/raid
    
    -- Check if we need to reset daily data
    self:CheckDailyReset()
    
    -- Register events
    self:RegisterEvents()
    
    -- Setup minimap button
    self:SetupMinimapButton()
    
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00BadgeTracker loaded! Type /badge to open the tracker.|r")
end

-- Register necessary events
function BadgeTracker:RegisterEvents()
    self.frame = CreateFrame("Frame")
    self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.frame:RegisterEvent("CHAT_MSG_LOOT")
    self.frame:RegisterEvent("PLAYER_LOGIN")
    
    self.frame:SetScript("OnEvent", function(frame, event, ...)
        if event == "PLAYER_LOGIN" then
            BadgeTracker:OnLoad()
        elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local success, err = pcall(BadgeTracker.OnCombatLogEvent, BadgeTracker, ...)
            if not success then
                DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[BadgeTracker Error]|r " .. tostring(err))
            end
        elseif event == "CHAT_MSG_LOOT" then
            local message = select(1, ...)
            local success, err = pcall(BadgeTracker.OnLootMsg, BadgeTracker, message)
            if not success then
                DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[BadgeTracker Error]|r " .. tostring(err))
            end
        end
    end)
    
    -- Hook the tooltip to add info when mousing over units
    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        BadgeTracker:OnTooltipSetUnit(tooltip)
    end)
    
    -- Clear the modification flag when tooltip is cleared
    GameTooltip:HookScript("OnTooltipCleared", function(tooltip)
        tooltip.badgeTrackerModified = false
    end)
    
    GameTooltip:HookScript("OnHide", function(tooltip)
        tooltip.badgeTrackerModified = false
    end)
end

-- Check if we need to reset data (based on lockout resets)
function BadgeTracker:CheckDailyReset()
    -- Handle both daily (heroic dungeons) and weekly (raids) resets
    local numSavedInstances = GetNumSavedInstances()
    local dailyResetTime = nil
    local weeklyResetTime = nil
    
    for i = 1, numSavedInstances do
        local name, id, reset, difficulty, locked = GetSavedInstanceInfo(i)
        
        if reset and reset > 0 then
            local absoluteResetTime = time() + reset
            
            -- Heroic dungeons (difficulty 174) - daily reset
            if difficulty == 174 then
                if not dailyResetTime then
                    dailyResetTime = absoluteResetTime
                end
            -- Raids (difficulty 175 for 10-man, 176 for 25-man) - weekly reset
            elseif difficulty == 175 or difficulty == 176 then
                if not weeklyResetTime then
                    weeklyResetTime = absoluteResetTime
                end
            end
        end
        
        -- Break if we found both
        if dailyResetTime and weeklyResetTime then
            break
        end
    end
    
    -- Handle daily reset (heroic dungeons)
    if dailyResetTime then
        local shouldReset = false
        
        if not BadgeTrackerDB.nextDailyResetTime then
            BadgeTrackerDB.nextDailyResetTime = dailyResetTime
            -- Never reset when setting the time for the first time
            shouldReset = false
        elseif time() >= BadgeTrackerDB.nextDailyResetTime then
            -- Stored time has passed - lockouts have reset
            shouldReset = true
            BadgeTrackerDB.nextDailyResetTime = dailyResetTime
        else
            -- Keep whichever reset time is sooner
            if dailyResetTime < BadgeTrackerDB.nextDailyResetTime then
                BadgeTrackerDB.nextDailyResetTime = dailyResetTime
            end
        end
        
        if shouldReset then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BadgeTracker]|r Daily heroic dungeons have reset!")
            BadgeTrackerDB.dailyKills = {}
        end
    else
        -- If we have a stored reset time, check if it has passed
        if BadgeTrackerDB.nextDailyResetTime then
            if time() >= BadgeTrackerDB.nextDailyResetTime then
                DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BadgeTracker]|r Daily heroic dungeons have reset!")
                BadgeTrackerDB.dailyKills = {}
                BadgeTrackerDB.nextDailyResetTime = nil
            end
        else
            -- No stored time and no lockouts - use date-based fallback
            local currentDate = date("%Y-%m-%d")
            if not BadgeTrackerDB.lastResetDate or BadgeTrackerDB.lastResetDate ~= currentDate then
                BadgeTrackerDB.dailyKills = {}
                BadgeTrackerDB.lastResetDate = currentDate
                BadgeTrackerDB.nextDailyResetTime = nil
            end
        end
    end
    
    -- Handle weekly reset (raids)
    if weeklyResetTime then
        if not BadgeTrackerDB.nextWeeklyResetTime then
            BadgeTrackerDB.nextWeeklyResetTime = weeklyResetTime
        elseif time() >= BadgeTrackerDB.nextWeeklyResetTime then
            DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BadgeTracker]|r Weekly raids have reset!")
            BadgeTrackerDB.weeklyKills = {}
            BadgeTrackerDB.nextWeeklyResetTime = weeklyResetTime
        else
            -- Keep whichever reset time is sooner
            if weeklyResetTime < BadgeTrackerDB.nextWeeklyResetTime then
                BadgeTrackerDB.nextWeeklyResetTime = weeklyResetTime
            end
        end
    end
end

-- Handle combat log events to detect boss kills
function BadgeTracker:OnCombatLogEvent(...)
    local timestamp, eventType, _, sourceGUID, sourceName, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
    
    if eventType == "UNIT_DIED" then
        -- Check if we're in a dungeon instance
        local inInstance, instanceType = IsInInstance()
        if not inInstance or instanceType ~= "party" then
            return
        end
        
        -- Check if current instance is heroic
        local name, instanceType, difficulty, difficultyName = GetInstanceInfo()
        
        -- difficultyName should be "Heroic" for heroic dungeons
        if difficultyName ~= "Heroic" then
            return
        end
        
        -- Check if the dead unit is a badge boss
        local BADGE_BOSSES = BadgeTracker:GetBadgeBosses()
        for dungeon, bosses in pairs(BADGE_BOSSES) do
            for _, bossName in ipairs(bosses) do
                if destName == bossName then
                    -- Special check for Chess Event - must be correct faction
                    if bossName == "King Llane" or bossName == "Warchief Blackhand" then
                        local playerFaction = UnitFactionGroup("player")
                        -- Alliance should kill Warchief Blackhand, Horde should kill King Llane
                        if (playerFaction == "Alliance" and bossName == "King Llane") or
                           (playerFaction == "Horde" and bossName == "Warchief Blackhand") then
                            -- Wrong boss died, chess event failed
                            DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BadgeTracker]|r Chess Event failed - wrong king defeated!")
                            return
                        end
                    end
                    
                    self:OnBossKilled(dungeon, bossName)
                    return
                end
            end
        end
    end
end

-- Handle boss kill
function BadgeTracker:OnBossKilled(dungeon, bossName)
    self:CheckDailyReset()
    
    -- Check if this is a Karazhan boss - if so, enable Karazhan badge tracking
    if BADGE_RAIDS_PHASE4[dungeon] and not BadgeTrackerDB.karazhanBadgesEnabled then
        BadgeTrackerDB.karazhanBadgesEnabled = true
        DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BadgeTracker]|r Karazhan is now dropping Badges of Justice! Tracking enabled.")
    end
    
    -- Determine if this is a raid (weekly) or dungeon (daily)
    local isRaid = BADGE_RAIDS_PHASE4[dungeon] ~= nil
    local killsTable = isRaid and BadgeTrackerDB.weeklyKills or BadgeTrackerDB.dailyKills
    
    if not killsTable[dungeon] then
        killsTable[dungeon] = {}
    end
    
    if not killsTable[dungeon][bossName] then
        -- Get current party/raid member names
        local partyMembers = {}
        local playerName = (UnitName("player"))
        if playerName then
            table.insert(partyMembers, playerName)
        end
        
        -- Get party/raid members
        local numMembers = GetNumGroupMembers() or 0
        if numMembers > 0 then
            for i = 1, numMembers - 1 do
                local unitPrefix = (numMembers > 5) and "raid" or "party"
                local name = (UnitName(unitPrefix..i))
                if name then
                    table.insert(partyMembers, name)
                end
            end
        end
        
        killsTable[dungeon][bossName] = {
            killed = true,
            looted = false,
            partyMembers = partyMembers,
            whoLooted = {},
            killTime = time()
        }
        
        -- Alert player to loot badge
        local alertMessage = "Boss killed! Don't forget to loot your Badge of Justice!"
        if bossName == "Nazan" then
            alertMessage = "Nazan killed! Loot the Reinforced Fel Iron Chest for your Badge of Justice!"
        elseif bossName == "King Llane" or bossName == "Warchief Blackhand" then
            alertMessage = "Chess Event complete! Loot the Dust Covered Chest for your Badge of Justice!"
        end
        
        RaidNotice_AddMessage(RaidWarningFrame, alertMessage, ChatTypeInfo["RAID_WARNING"])
        
        local chatMessage = bossName .. " killed! Remember to loot your Badge of Justice!"
        if bossName == "Nazan" then
            chatMessage = bossName .. " killed! Remember to loot the chest for your Badge of Justice!"
        elseif bossName == "King Llane" or bossName == "Warchief Blackhand" then
            chatMessage = "Chess Event complete! Remember to loot the Dust Covered Chest for your Badge of Justice!"
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BadgeTracker]|r " .. chatMessage)
        
        -- Play sound alert
        PlaySound(8959)
        
        -- Update UI if it's open
        if BadgeTracker.mainFrame and BadgeTracker.mainFrame:IsShown() then
            BadgeTracker:UpdateUI()
        end
    end
end

-- Get all kills (combines daily and weekly)
function BadgeTracker:GetAllKills()
    local allKills = {}
    
    -- Add daily kills
    for dungeon, bosses in pairs(BadgeTrackerDB.dailyKills) do
        allKills[dungeon] = bosses
    end
    
    -- Add weekly kills
    for raid, bosses in pairs(BadgeTrackerDB.weeklyKills) do
        allKills[raid] = bosses
    end
    
    return allKills
end

-- Handle loot messages to detect badge pickup
function BadgeTracker:OnLootMsg(message)
    -- Check if the message contains Badge of Justice
    if string.find(message, "Badge of Justice") then
        local looterName = nil
        
        -- Debug: print the message to see format
        -- DEFAULT_CHAT_FRAME:AddMessage("BadgeTracker Debug: " .. message)
        
        -- Try to extract the player name from the loot message
        -- Format: "PlayerName receives loot: [Badge of Justice]." or "You receive loot: [Badge of Justice]."
        
        if string.find(message, "^You receive") then
            looterName = (UnitName("player"))
        else
            -- Extract name from "PlayerName receives loot:"
            looterName = string.match(message, "^(.+) receives loot:")
        end
        
        -- DEFAULT_CHAT_FRAME:AddMessage("[BadgeTracker Debug] Extracted name: " .. tostring(looterName))
        
        if looterName then
            -- Find the most recently killed boss where this person hasn't looted yet
            local BADGE_BOSSES = BadgeTracker:GetBadgeBosses()
            local allKills = BadgeTracker:GetAllKills()
            local mostRecentBoss = nil
            local mostRecentTime = 0
            local mostRecentDungeon = nil
            
            for dungeon, bosses in pairs(BADGE_BOSSES) do
                if allKills[dungeon] then
                    for bossName, data in pairs(allKills[dungeon]) do
                        if data.killed then
                            -- Initialize whoLooted if it doesn't exist (backwards compatibility)
                            if not data.whoLooted then
                                data.whoLooted = {}
                            end
                            
                            -- Initialize killTime if it doesn't exist (backwards compatibility)
                            if not data.killTime then
                                data.killTime = 0
                            end
                            
                            -- Check if this person hasn't looted from this boss and it's more recent
                            if not data.whoLooted[looterName] and data.killTime > mostRecentTime then
                                mostRecentBoss = bossName
                                mostRecentTime = data.killTime
                                mostRecentDungeon = dungeon
                            end
                        end
                    end
                end
            end
            
            -- If we found a recent boss kill, assign the loot to it
            if mostRecentBoss and mostRecentDungeon then
                local data = allKills[mostRecentDungeon][mostRecentBoss]
                
                -- DEFAULT_CHAT_FRAME:AddMessage("[BadgeTracker Debug] Party members for " .. mostRecentBoss .. ": " .. (data.partyMembers and table.concat(data.partyMembers, ", ") or "none"))
                -- DEFAULT_CHAT_FRAME:AddMessage("[BadgeTracker Debug] Marking " .. looterName .. " as looted from " .. mostRecentBoss)
                
                data.whoLooted[looterName] = true
                
                -- If it's the player, mark as looted
                if looterName == (UnitName("player")) then
                    data.looted = true
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[BadgeTracker]|r Badge looted from " .. mostRecentBoss .. "!")
                end
                
                -- Update UI if it's open
                if BadgeTracker.mainFrame and BadgeTracker.mainFrame:IsShown() then
                    BadgeTracker:UpdateUI()
                end
            end
        end
    end
end

-- Create the main UI frame
function BadgeTracker:CreateUI()
    if self.mainFrame then
        return
    end
    
    -- Main frame
    local frame = CreateFrame("Frame", "BadgeTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(600, 550)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    
    -- Override the close button to work in combat
    if frame.CloseButton then
        frame.CloseButton:SetScript("OnClick", function()
            frame:Hide()
        end)
    end
    
    -- Title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("Badge of Justice Tracker")
    
    -- Summary at the top (below title)
    frame.summary = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.summary:SetPoint("TOPLEFT", 12, -25)
    frame.summary:SetText("Today: 0 killed, 0 looted")
    
    -- Create minimap toggle checkbox at the top right
    local minimapCheckbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    minimapCheckbox:SetPoint("TOPRIGHT", -35, -23)
    minimapCheckbox:SetSize(20, 20)
    minimapCheckbox:SetChecked(not BadgeTrackerDB.minimap.hide)
    
    local minimapLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    minimapLabel:SetPoint("RIGHT", minimapCheckbox, "LEFT", -2, 0)
    minimapLabel:SetText("Minimap")
    
    minimapCheckbox:SetScript("OnClick", function(self)
        local LDB = LibStub:GetLibrary("LibDBIcon-1.0", true)
        if not LDB then return end
        
        if self:GetChecked() then
            BadgeTrackerDB.minimap.hide = false
            LDB:Show("BadgeTracker")
        else
            BadgeTrackerDB.minimap.hide = true
            LDB:Hide("BadgeTracker")
        end
    end)
    
    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "BadgeTrackerScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -45)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)
    
    -- Content frame
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(550, 600)
    content:EnableMouse(false)  -- Don't block mouse events, let them pass through to children
    scrollFrame:SetScrollChild(content)
    
    frame.content = content
    self.mainFrame = frame
    
    -- Create reset button
    local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetButton:SetSize(100, 25)
    resetButton:SetPoint("BOTTOM", 0, 10)
    resetButton:SetText("Reset Daily")
    resetButton:SetScript("OnClick", function()
        StaticPopup_Show("BADGETRACKER_RESET_CONFIRM")
    end)
    
    self:UpdateUI()
end

-- Update the UI with current data
function BadgeTracker:UpdateUI()
    if not self.mainFrame then
        return
    end
    
    local content = self.mainFrame.content
    
    -- Clear existing elements properly
    local children = {content:GetChildren()}
    for _, child in ipairs(children) do
        child:Hide()
    end
    
    -- Clear font strings
    local regions = {content:GetRegions()}
    for _, region in ipairs(regions) do
        if region:GetObjectType() == "FontString" then
            region:Hide()
        end
    end
    
    local totalKilled = 0
    local totalLooted = 0
    
    local BADGE_BOSSES = BadgeTracker:GetBadgeBosses()
    local allKills = BadgeTracker:GetAllKills()
    
    -- Sort dungeons alphabetically
    local sortedDungeons = {}
    for dungeon in pairs(BADGE_BOSSES) do
        table.insert(sortedDungeons, dungeon)
    end
    table.sort(sortedDungeons)
    
    -- Calculate grid layout - 2 columns
    local col1X = 10
    local col2X = 290
    local col1Y = -10
    local col2Y = -10
    local column = 1
    
    -- Display each dungeon and its bosses in a grid
    for _, dungeon in ipairs(sortedDungeons) do
        local xOffset = (column == 1) and col1X or col2X
        local yOffset = (column == 1) and col1Y or col2Y
        
        -- Dungeon header
        local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", xOffset, yOffset)
        header:SetText(dungeon)
        header:SetTextColor(1, 0.82, 0)
        header:SetWidth(270)
        header:SetJustifyH("LEFT")
        
        local headerYOffset = yOffset - 20
        
        -- Boss list
        for _, bossName in ipairs(BADGE_BOSSES[dungeon]) do
            local killed = false
            local looted = false
            
            if allKills[dungeon] and allKills[dungeon][bossName] then
                killed = allKills[dungeon][bossName].killed
                looted = allKills[dungeon][bossName].looted
                
                if killed then
                    totalKilled = totalKilled + 1
                end
                if looted then
                    totalLooted = totalLooted + 1
                end
            end
            
            local bossText = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            bossText:SetPoint("TOPLEFT", xOffset + 10, headerYOffset)
            bossText:SetWidth(260)
            bossText:SetJustifyH("LEFT")
            
            local statusIcon = ""
            local color = {0.5, 0.5, 0.5}
            
            if looted then
                statusIcon = "[X] "
                color = {0, 1, 0}
            elseif killed then
                statusIcon = "[!] "
                color = {1, 0.5, 0}
            end
            
            bossText:SetText(statusIcon .. bossName)
            bossText:SetTextColor(color[1], color[2], color[3])
            
            -- Add tooltip for killed bosses in the tracker window
            if killed then
                local currentDungeon = dungeon
                local currentBoss = bossName
                
                local tooltipButton = CreateFrame("Button", nil, content)
                tooltipButton:SetPoint("TOPLEFT", xOffset + 10, headerYOffset)
                tooltipButton:SetSize(260, 16)
                tooltipButton:EnableMouse(true)
                
                tooltipButton:SetScript("OnEnter", function(self)
                    local allKills = BadgeTracker:GetAllKills()
                    local data = allKills[currentDungeon] and allKills[currentDungeon][currentBoss]
                    if data then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetText(currentBoss, 1, 1, 1)
                        
                        if data.partyMembers and #data.partyMembers > 0 then
                            local notLooted = {}
                            for _, memberName in ipairs(data.partyMembers) do
                                if not data.whoLooted or not data.whoLooted[memberName] then
                                    table.insert(notLooted, memberName)
                                end
                            end
                            
                            if #notLooted > 0 then
                                GameTooltip:AddLine(" ")
                                GameTooltip:AddLine("Haven't looted:", 1, 0.5, 0)
                                for _, name in ipairs(notLooted) do
                                    GameTooltip:AddLine("  " .. name, 1, 0.3, 0.3)
                                end
                            else
                                GameTooltip:AddLine(" ")
                                GameTooltip:AddLine("Everyone looted!", 0, 1, 0)
                            end
                        end
                        
                        GameTooltip:Show()
                    end
                end)
                
                tooltipButton:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)
            end
            
            headerYOffset = headerYOffset - 16
        end
        
        -- Calculate space needed for this dungeon
        local dungeonHeight = math.abs(headerYOffset - yOffset) + 10
        
        -- Update the appropriate column's Y position and switch columns
        if column == 1 then
            col1Y = headerYOffset - 20  -- Increased spacing
            column = 2
        else
            col2Y = headerYOffset - 20  -- Increased spacing
            column = 1
        end
    end
    
    -- Update summary
    local phaseText = "Phase " .. (self.cachedPhase or 1)
    self.mainFrame.summary:SetText(string.format("%s | Today: %d killed, %d looted", phaseText, totalKilled, totalLooted))
end

-- Setup minimap button
function BadgeTracker:SetupMinimapButton()
    local LDB = LibStub:GetLibrary("LibDBIcon-1.0", true)
    if not LDB then return end
    
    local minimapButton = {
        type = "data source",
        icon = "Interface\\Icons\\Spell_Holy_ChampionsBond",
        OnClick = function(self, button)
            if button == "LeftButton" then
                BadgeTracker:ToggleUI()
            elseif button == "RightButton" then
                -- Right click to show reset confirmation
                StaticPopup_Show("BADGETRACKER_RESET_CONFIRM")
            end
        end,
        OnTooltipShow = function(tooltip)
            if not tooltip or not tooltip.AddLine then return end
            tooltip:AddLine("Badge of Justice Tracker")
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffeda55fLeft-click|r to open tracker", 0.2, 1, 0.2)
            tooltip:AddLine("|cffeda55fRight-click|r to reset daily", 0.2, 1, 0.2)
            
            -- Show today's count
            local totalKilled = 0
            local totalLooted = 0
            for dungeon, bosses in pairs(BadgeTrackerDB.dailyKills) do
                for bossName, data in pairs(bosses) do
                    if data.killed then totalKilled = totalKilled + 1 end
                    if data.looted then totalLooted = totalLooted + 1 end
                end
            end
            tooltip:AddLine(" ")
            tooltip:AddLine(string.format("Today: %d killed, %d looted", totalKilled, totalLooted), 1, 1, 1)
        end,
    }
    
    LDB:Register("BadgeTracker", minimapButton, BadgeTrackerDB.minimap)
end

-- Handle tooltip updates when mousing over units
function BadgeTracker:OnTooltipSetUnit(tooltip)
    -- Check if we've already modified this tooltip
    if tooltip.badgeTrackerModified then return end
    
    local unitName = (UnitName("mouseover"))
    if not unitName then return end
    
    local BADGE_BOSSES = BadgeTracker:GetBadgeBosses()
    local allKills = BadgeTracker:GetAllKills()
    
    -- Check if this unit is a badge boss and if it's been killed
    for dungeon, bosses in pairs(BADGE_BOSSES) do
        for _, bossName in ipairs(bosses) do
            if unitName == bossName then
                local data = allKills[dungeon] and allKills[dungeon][bossName]
                if data and data.killed and data.partyMembers and #data.partyMembers > 0 then
                    -- Mark this tooltip as modified
                    tooltip.badgeTrackerModified = true
                    
                    -- Add info about who hasn't looted
                    local notLooted = {}
                    for _, memberName in ipairs(data.partyMembers) do
                        if not data.whoLooted or not data.whoLooted[memberName] then
                            table.insert(notLooted, memberName)
                        end
                    end
                    
                    if #notLooted > 0 then
                        tooltip:AddLine(" ")
                        tooltip:AddLine("|cffff6600Badge of Justice - Haven't looted:|r")
                        for _, name in ipairs(notLooted) do
                            tooltip:AddLine("  " .. name, 1, 0.3, 0.3)
                        end
                    else
                        tooltip:AddLine(" ")
                        tooltip:AddLine("|cff00ff00Badge of Justice - Everyone looted!|r")
                    end
                end
                return
            end
        end
    end
end

-- Toggle UI visibility
function BadgeTracker:ToggleUI()
    if not self.mainFrame then
        self:CreateUI()
        self.mainFrame:Show()
        return
    end
    
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    else
        self:UpdateUI()
        self.mainFrame:Show()
    end
end

-- Slash command
SLASH_BADGE1 = "/badge"
SLASH_BADGE2 = "/badgetracker"
SlashCmdList["BADGE"] = function(msg)
    BadgeTracker:ToggleUI()
end

-- Create confirmation dialog for reset
StaticPopupDialogs["BADGETRACKER_RESET_CONFIRM"] = {
    text = "Are you sure you want to reset your daily Badge of Justice tracking?\n\nThis will clear all boss kills and loots for today.\n\n(The tracker automatically resets when your heroic lockouts reset)",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        BadgeTrackerDB.dailyKills = {}
        BadgeTrackerDB.weeklyKills = {}
        if BadgeTracker.mainFrame and BadgeTracker.mainFrame:IsShown() then
            BadgeTracker:UpdateUI()
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cffff6600[BadgeTracker]|r Tracking reset!")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Initialize on load
BadgeTracker:RegisterEvents()
