# 🎮 Avoid Bubble

A cross-platform bullet hell survival game built with Flutter and Flame engine. Survive as long as possible while avoiding various bullet patterns in this challenging arcade-style game!

[![Flutter](https://img.shields.io/badge/Flutter-3.24.x-blue.svg)](https://flutter.dev/)
[![Flame](https://img.shields.io/badge/Flame-1.30.1-orange.svg)](https://flame-engine.org/)

## ✨ Features

- 🎯 **3-Stage Bullet Pattern System** - Escalating difficulty with targeted, directional, and linear bullet patterns
- 📊 **Statistics Tracking** - Real-time performance monitoring with grade system (S/A/B/C/D/F)
- 🏆 **Online Ranking System** - Global leaderboards
- 🌍 **Internationalization** - Full support for Korean and English languages
- 🎮 **Multi-Platform Support** - Android, iOS, Web responsive scaling

## 🎮 How to Play

### Controls

- **Movement**: WASD keys or Arrow keys (keyboard) / Joystick controls (mobile)
- **Restart**: R key (during game or after game over)
- **Menu**: ESC key

### Objective

Survive as long as possible while avoiding various bullet patterns!

### Grading System

- **S Grade**: 300+ seconds (5+ minutes) 🏆
- **A Grade**: 200-299 seconds (3-5 minutes) 🥇
- **B Grade**: 150-199 seconds (2.5-3 minutes) 🥈
- **C Grade**: 100-149 seconds (1.5-2.5 minutes) 🥉
- **D Grade**: 50-99 seconds (1-1.5 minutes) 📜
- **F Grade**: Under 50 seconds 😵

## 🚀 Quick Start

### Prerequisites

- Flutter 3.24.x or later
- Dart SDK
- For mobile: Android Studio / Xcode
- For desktop: Platform-specific build tools

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/username/avoid_bubble.git
   cd avoid_bubble
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the game**

   ```bash
   # Web
   scripts/run_chrome_dev.sh

   # Mobile
   flutter run             # Connected device
   ```

## 🏗️ Build & Deploy

### Local Build

```bash
# Web
flutter build web --release

# Android
flutter build apk --release

```

### itch.io Deployment

#### Manual Deploy

```bash
# Quick manual deployment
./scripts/deploy-itch.sh
```

### CI/CD Pipeline

This project uses **tag-based deployment** with GitHub Actions:

- **Tag-based Deployment**: Auto-deploy when version tags (v1.0.0) are pushed
- **Version Synchronization**: Automatic pubspec.yaml version updates
- **Semantic Versioning**: Full support for major.minor.patch versioning

## 🛠️ Architecture

```
lib/
├── main.dart                 # App entry point
├── game/
│   ├── avoid_bubble_game.dart # Core Flame game
│   └── game_state.dart       # Game state
├── screens/
│   ├── start_screen.dart     # Main menu
│   ├── settings_screen.dart  # Configuration UI
│   └── game_over_screen.dart # Results screen
├── component/
│   ├── player.dart          # Player Flame
│   └── bullet.dart          # Bullet Flame
├── models/
│   ├── game_settings.dart   # Configuration model
│   ├── game_stats.dart      # Statistics tracking
│   ├── player_model.dart    # Player logic
│   └── bullet_model.dart    # Bullet patterns & physics
├── services/
│   ├── localization_service.dart # ARB-based internationalization
│   ├── audio_service.dart        # Cross-platform audio
│   ├── ranking_service.dart      # Backend integration
│   └── nickname_service.dart     # Player nickname management
└── config/
    ├── environment_config.dart   # Environment management
    └── supabase_config.dart      # Backend configuration
└── l10n/
    ├── app_en.arb               # English translations
    └── app_ko.arb               # Korean translations
```

## 🎯 Game Patterns

### Pattern 1: Targeted Bullets (2-15s)

- Bullets spawn from screen edges and target player's current position
- Frequency: 1 second intervals initially, then 0.8s after 15s
- Difficulty scales: Bullet speed increases by 1 every 5 seconds after pattern ends

### Pattern 2: Eight Direction Attack (15s+)

- Simultaneous bullets from 8 directions toward player
- Frequency: Every 5 seconds
- Pattern: North, NE, East, SE, South, SW, West, NW directions

### Pattern 3: Sequential Linear Barrage (30s+)

- Linear bullet walls from each screen edge in sequence
- Frequency: Every 10 seconds
- Sequence: Top→Right→Bottom→Left (8 bullets vertically, 6 bullets horizontally)

### Visual & Audio

- **Visual**: Hitbox display, debug information, responsive scaling
- **Audio**: BGM toggle, volume control
- **Languages**: Korean/English with automatic browser detection

### Developer Features

- **Debug Mode**: Pre-configured testing values
- **Hitbox Visualization**: Press H key during gameplay
- **Quick Settings**: Reset to defaults, apply debug settings

All settings are persistent and applied in real-time.

## 🔧 Development

### Code Quality

```bash
# Analysis
flutter analyze

# Testing
flutter test

# Formatting
dart format lib/
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and analysis
5. Submit a pull request

## 📁 Scripts

### Deployment

| Script                         | Description                   |
| ------------------------------ | ----------------------------- |
| `scripts/run_chrome_dev.sh.sh` | Build Chrome local Server     |
| `scripts/deploy-itch.sh`       | Build and package for itch.io |

## 🎵 Audio Assets

- BGM: `assets/audio/bgm.wav` (optional)
- Cross-platform audio system with web compatibility
- Automatic fallback when audio files are unavailable

## 🔒 Security

- Environment variables for sensitive configuration
- `.env` files excluded from version control
- Clean separation of development and production settings

## 🐛 Known Issues

### Web/itch.io

- BGM may be restricted on some itch.io hosting environments due to security policies
- Web builds use relative paths for itch.io compatibility

### Mobile

- Joystick-keyboard input conflict on mobile devices (joystick mode automatically activated on mobile)

### Development

- AssetManifest.bin.json 404 errors in development mode (normal behavior)
- Font loading warnings resolved with Google Fonts integration

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Flame](https://flame-engine.org/) - Game engine
- [Supabase](https://supabase.com/) - Backend services
- [itch.io](https://itch.io/) - Game distribution platform

---

🎮 **Play now**: [itch.io Game Page](https://dev-kbk.itch.io/avoid-bubble)
