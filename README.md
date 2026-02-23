# Badge of Justice Tracker

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/NigelStruble/BadgeTracker/releases)
[![WoW](https://img.shields.io/badge/WoW-TBC%20Classic%20Anniversary-orange.svg)](https://worldofwarcraft.blizzard.com/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A comprehensive World of Warcraft TBC Classic Anniversary addon that helps you track Badge of Justice boss kills and loot collection across all heroic dungeons and raids.

> **Never miss a badge again!** Get visual and audio alerts when bosses die, track your party's loot status, and automatically reset with your heroic lockouts.

## 📸 Screenshots

<!-- Add your screenshots here -->
<!-- Example:
![Tracker Window](screenshots/tracker-window.png)
*The main tracker window showing your daily progress*

![Minimap Icon](screenshots/minimap-icon.png)
*Convenient minimap button for quick access*

![Boss Kill Alert](screenshots/alert.png)
*Visual alert when a boss is killed*

![Tooltip](screenshots/tooltip.png)
*Tooltip showing which party members haven't looted*
-->

## ✨ Features

### 🎯 Core Functionality
- **Automatic Boss Detection**: Instantly detects when you kill any heroic dungeon boss
- **Smart Loot Tracking**: Monitors badge pickups for you and all party/raid members
- **Visual & Audio Alerts**: Impossible-to-miss notifications when bosses die
- **Party Awareness**: See which party members still need to loot their badges
- **Region-Independent**: Works perfectly on US, EU, and Asian servers

### 📊 Tracking Interface
- **Clean 2-Column Layout**: All dungeons organized and easy to scan
- **Color-Coded Status**:
  - 🔘 **Gray**: Not yet killed
  - ⚠️ **Orange [!]**: Killed but not looted
  - ✅ **Green [X]**: Killed and looted
- **Interactive Tooltips**: Hover for detailed party loot status
- **Daily Summary**: Quick overview of kills and loots at the top

### 🔄 Smart Reset System
- **Automatic Daily Reset**: Syncs with your actual heroic lockout times
- **Weekly Raid Tracking**: Separate tracking for Karazhan
- **Persistent Data**: Tracks across logins and /reloads
- **Manual Override**: Reset anytime with confirmation dialog

### 🗺️ Minimap Integration
- **Draggable Icon**: Position it anywhere around your minimap
- **Left-Click**: Open/close tracker
- **Right-Click**: Quick reset with confirmation
- **Hover Tooltip**: See your daily summary without opening the window
- **Toggle Visibility**: Show/hide the icon as needed

## 📦 Installation

### Manual Installation
1. Download the [latest release](https://github.com/NigelStruble/BadgeTracker/releases)
2. Extract the `BadgeTracker` folder
3. Place it in your WoW addons directory:
   - **Windows**: `C:\Program Files (x86)\World of Warcraft\_classic_\Interface\AddOns\`
   - **Mac**: `/Applications/World of Warcraft/_classic_/Interface/AddOns/`
4. Restart WoW or type `/reload` in-game

### First Time Setup
1. Look for the Badge of Justice icon on your minimap
2. Left-click to open the tracker
3. Run some heroic dungeons!
4. The addon will automatically start tracking your kills and loots

## 🎮 Usage Guide

### Commands
- `/badge` or `/badgetracker` - Open/close the tracker window

### Minimap Button
- **Left-Click**: Toggle tracker window
- **Right-Click**: Reset tracking (with confirmation)
- **Drag**: Reposition around minimap
- **Hover**: View daily summary

### Understanding the Display

The tracker shows all heroic dungeons with their bosses:

| Icon | Status | Meaning |
|------|--------|---------|
| Gray text | Not killed | Haven't killed this boss today |
| 🟠 `[!]` | Killed, not looted | Boss is dead but you haven't looted your badge |
| 🟢 `[X]` | Completed | Boss killed and badge looted |

### In-Game Tooltips

When you kill a boss and mouseover their corpse, you'll see:
- Badge of Justice loot reminder
- Which party members haven't looted yet
- "Everyone looted!" when all badges are collected

### Alerts

When killing a boss, you'll get:
- 🎯 **Raid Warning**: Center-screen alert
- 💬 **Chat Message**: Reminder in your chat log  
- 🔊 **Sound Effect**: Audio notification

Special alerts for:
- **Nazan**: Reminds you to loot the Reinforced Fel Iron Chest
- **Chess Event**: Reminds you to loot the Dust Covered Chest

## 🏰 Content Tracked

### Heroic Dungeons (Daily Reset)
- ✅ **Hellfire Citadel**: Ramparts, Blood Furnace, Shattered Halls
- ✅ **Coilfang Reservoir**: Slave Pens, Underbog, Steamvault  
- ✅ **Auchindoun**: Mana-Tombs, Crypts, Sethekk Halls, Shadow Labyrinth
- ✅ **Tempest Keep**: Mechanar, Botanica, Arcatraz
- ✅ **Caverns of Time**: Old Hillsbrad, Black Morass
- ✅ **Magisters' Terrace**: (Phase 5+)

### Raids (Weekly Reset)
- ✅ **Karazhan**: All 10 bosses including Chess Event and Opera variations
  - Auto-enables when badges start dropping

### Special Encounters
- **Bonus Bosses**: Yor, Anzu, Shattered Hand Executioner
- **Chest Loots**: Nazan (Reinforced Fel Iron Chest), Chess Event (Dust Covered Chest)
- **Opera Variations**: Wizard of Oz (Crone), Red Riding Hood (Big Bad Wolf), Romeo & Juliet (Romulo & Julianne)
- **Faction Validation**: Chess Event only counts when the correct king is defeated

## ⚙️ Technical Details

### System Requirements
- **WoW Version**: TBC Classic Anniversary (2.5.5+)
- **Interface**: 20505
- **Dependencies**: None (includes LibStub and LibDBIcon)

### How It Works
- Monitors `COMBAT_LOG_EVENT_UNFILTERED` for boss deaths
- Parses `CHAT_MSG_LOOT` for badge pickups
- Uses actual instance lockout times for resets (difficulty ID 174 for heroics)
- Stores data per-character using `SavedVariablesPerCharacter`

### Data Storage
All tracking data is saved per-character and persists across sessions. The addon automatically:
- Resets when your heroic lockouts expire
- Tracks separately for daily (dungeons) and weekly (raids)
- Updates in real-time as you kill bosses and loot badges

## 🔧 Troubleshooting

### Addon Not Working?
1. ✅ Enable the addon in character select screen
2. ✅ Make sure you're in a **heroic** dungeon (normal mode won't track)
3. ✅ Type `/reload` to reload your UI
4. ✅ Check for Lua errors (install BugSack to see them)

### Reset Not Working?
- The addon resets automatically when your lockouts expire
- If you want to reset manually, use the reset button or right-click the minimap icon
- Make sure you have at least one heroic lockout for automatic resets to work

### Minimap Icon Missing?
- Check the checkbox at the top-right of the tracker window
- The icon may be hidden behind other minimap elements - try dragging them

### Boss Not Detected?
- Ensure you're in heroic mode (not normal)
- Some bosses have special requirements (e.g., Chess Event must win with correct faction)
- Check that you're in a supported dungeon

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Ways to Help
- 🐛 Report bugs in [Issues](https://github.com/NigelStruble/BadgeTracker/issues)
- 💡 Suggest features
- 📝 Improve documentation  
- 🔧 Submit pull requests
- ⭐ Star the repository if you find it useful!

## 📋 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed version history.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

- Created for the WoW TBC Classic Anniversary community
- Built with [LibStub](https://www.wowace.com/projects/libstub) and [LibDBIcon-1.0](https://www.wowace.com/projects/libdbicon-1-0)
- Special thanks to all contributors and testers

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/NigelStruble/BadgeTracker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/NigelStruble/BadgeTracker/discussions)

---

**Happy badge farming!** 🎮✨

*Don't forget to star ⭐ the repository if you find this addon useful!*
