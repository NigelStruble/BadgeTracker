# Changelog

All notable changes to Badge Tracker will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-22

### Added
#### Core Features
- **Automatic Boss Detection**: Tracks all heroic dungeon boss kills that drop Badge of Justice
- **Loot Tracking**: Monitors badge pickups for the player and all party/raid members
- **Visual Alerts**: Raid warning and chat messages when bosses are killed
- **Audio Alerts**: Sound notification on boss kills
- **Minimap Button**: Draggable minimap icon with LibDBIcon integration
  - Left-click to open/close tracker
  - Right-click to reset (with confirmation)
  - Tooltip showing daily summary

#### User Interface
- **2-Column Grid Layout**: Displays all dungeons and bosses in an organized view
- **Status Indicators**: 
  - Gray text: Not killed
  - Orange `[!]`: Killed but not looted
  - Green `[X]`: Killed and looted
- **Tooltips**: Hover over killed bosses to see which party members haven't looted
- **Summary Display**: Shows total kills and loots at the top
- **Minimap Toggle**: Checkbox to show/hide minimap button
- **Manual Reset**: Button to clear daily tracking with confirmation dialog

#### In-Game Tooltips
- **Boss Mouseover**: Displays loot status when hovering over boss corpses in-game
- **Party Status**: Shows which party members haven't looted their badge yet
- **Duplicate Prevention**: Prevents tooltip from being added multiple times

#### Reset System
- **Automatic Daily Reset**: Resets based on actual heroic lockout expiration times
- **Region-Independent**: Works correctly across all regions (US, EU, Asia)
- **Persistent Tracking**: Preserves data across logins until actual reset time
- **Weekly Reset**: Separate tracking for weekly raid lockouts
- **Smart Fallback**: Uses date-based reset when no lockouts are present
- **Reset Messages**: Notifications when daily/weekly resets occur

#### Content Coverage
- **All Heroic Dungeons**: Tracks all 16 TBC heroic dungeons
- **Bonus Bosses**: Includes Yor, Anzu, and Shattered Hand Executioner
- **Special Encounters**: 
  - Nazan (Reinforced Fel Iron Chest)
  - Chess Event (Dust Covered Chest, faction-specific validation)
  - Opera Event (all three variations: Crone, Big Bad Wolf, Romulo & Julianne)
- **Karazhan Support**: Weekly tracking for all 10 Karazhan bosses
  - Auto-enables when badges start dropping from Kara
  - Separate weekly lockout tracking
- **Magisters' Terrace**: Phase 5 content auto-detection

#### Technical Implementation
- **TBC Anniversary Support**: Uses difficulty ID 174 for heroic dungeons
- **Raid Detection**: Uses difficulty IDs 175/176 for 10/25-man raids
- **Per-Character Data**: SavedVariablesPerCharacter for individual tracking
- **Party/Raid Member Tracking**: Handles both 5-man and 10-man groups
- **Timestamp-Based Loot**: Assigns loots to most recently killed boss
- **Faction Validation**: Prevents Chess Event tracking on failure
- **Phase Detection**: Automatically enables Magisters' Terrace in Phase 5

### Technical Details
#### Difficulty IDs (TBC Anniversary)
- Heroic Dungeons: 174
- 10-man Raids: 175
- 25-man Raids: 176

#### Events Used
- `COMBAT_LOG_EVENT_UNFILTERED`: Boss kill detection
- `CHAT_MSG_LOOT`: Badge loot detection
- `PLAYER_LOGIN`: Initialization and reset checking

#### Saved Variables Structure
```lua
BadgeTrackerDB = {
    dailyKills = {},              -- Daily heroic dungeon tracking
    weeklyKills = {},             -- Weekly raid tracking
    nextDailyResetTime = nil,     -- Unix timestamp of next daily reset
    nextWeeklyResetTime = nil,    -- Unix timestamp of next weekly reset
    lastResetDate = "YYYY-MM-DD", -- Fallback date-based reset
    karazhanBadgesEnabled = false,-- Auto-enables when Kara badges drop
    minimap = {
        hide = false,
        minimapPos = 225
    }
}
```

#### Libraries Used
- **LibStub**: Library versioning
- **LibDBIcon-1.0**: Minimap button management

### Fixed
- **Reset Time Persistence**: Fixed SavedVariables not persisting nil values
- **Early Reset Prevention**: Prevents tracking from resetting on every login
- **Lockout Expiration**: Correctly handles when all lockouts have expired
- **Party Member Detection**: Fixed GetNumGroupMembers() usage for TBC Anniversary
- **Loot Assignment**: Prevents loot from being assigned to wrong boss
- **Duplicate Tooltips**: Fixed tooltip information appearing twice
- **Combat Lockdown**: Close button works during combat
- **Column Layout**: Fixed Karazhan overlapping with other dungeons in UI

### Performance Improvements
- **Lockout-Based Resets**: Changed from time-based to lockout-existence-based reset detection
  - Only resets when lockouts are actually gone, not based on stored timestamps
  - Eliminates early reset bugs caused by time comparison edge cases
- **Efficient Timer Scheduling**: Replaced OnUpdate frame polling with C_Timer.NewTimer()
  - Changed from 60+ FPS frame checking to one-time callback execution
  - Schedules timer for exact lockout expiry + 10 second buffer
  - Zero CPU overhead between resets
- **Smart Rescheduling**: Timer updates when new lockouts are acquired

### Known Limitations
- Cannot track bosses in raids with instanceType other than "party" (5-man)
- Karazhan tracking requires manual enabling (first badge loot)
- Phase detection for MGT is basic (checks for saved instance)

### Credits
Created for the WoW TBC Classic Anniversary community. Special thanks to all the testers who helped identify edge cases and improve the addon during development.

---

## Future Roadmap

### Potential Features
- Support for additional raids when badges are added (SSC, TK, BT, Hyjal, Sunwell)
- Statistics tracking (total badges earned, badges per dungeon)
- Weekly summary reports
- Export functionality for tracking across characters
- Integration with guild management tools
