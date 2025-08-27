# 🎮 Avoid Bubble

A cross-platform bullet hell survival game built with Flutter and Flame engine.

[![CI/CD](https://github.com/username/avoid_bubble/actions/workflows/itch-deploy.yml/badge.svg)](https://github.com/username/avoid_bubble/actions)
[![Flutter](https://img.shields.io/badge/Flutter-3.24.x-blue.svg)](https://flutter.dev/)
[![Flame](https://img.shields.io/badge/Flame-1.30.1-orange.svg)](https://flame-engine.org/)

## ✨ Features

- 🎯 **3-Stage Bullet Pattern System** - Escalating difficulty with targeted, directional, and linear bullet patterns
- ⚙️ **Customizable Settings** - Adjust difficulty, pattern timings, and visual options
- 📊 **Statistics Tracking** - Real-time performance monitoring and ranking system
- 🎮 **Multi-Platform Support** - Android, iOS, Web, Linux
- 🎵 **Dynamic Audio** - BGM support with web compatibility
- 🐛 **Debug Features** - Hitbox visualization and developer mode
- 🚀 **itch.io Ready** - Optimized for web deployment

## 🎮 How to Play

- **Movement**: WASD keys or Arrow keys
- **Restart**: R key (during game or after game over)
- **Menu**: ESC key
- **Debug Hitboxes**: H key (developer mode)

**Objective**: Survive as long as possible while avoiding various bullet patterns!

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

3. **Set up environment** (for ranking features)
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. **Run the game**
   ```bash
   # Web
   flutter run -d chrome
   
   # Desktop
   flutter run -d linux    # Linux
   flutter run -d macos    # macOS
   flutter run -d windows  # Windows
   
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

# Linux
flutter build linux --release
```

### itch.io Deployment

#### Quick Deploy (Manual)
```bash
./scripts/deploy-itch.sh
```

#### Butler Deploy (Automated)
```bash
# Setup Butler (one-time)
./scripts/setup-butler.sh
butler login

# Deploy with Butler
./scripts/butler-deploy.sh
```

### CI/CD Pipeline

This project includes automated deployment workflows:

- **Single Platform**: Auto-deploy web build on push to `main`
- **Multi-Platform**: Deploy all platforms on release creation

**Setup Guide**: [docs/CICD_SETUP.md](docs/CICD_SETUP.md)

## 🛠️ Architecture

```
lib/
├── main.dart                 # App entry point
├── game/
│   ├── avoid_bubble_game.dart # Core Flame game engine
│   └── game_state.dart       # Game state management
├── screens/
│   ├── start_screen.dart     # Main menu
│   ├── settings_screen.dart  # Configuration UI
│   └── game_over_screen.dart # Results screen
├── components/
│   ├── player.dart          # Player Flame component
│   └── bullet.dart          # Bullet Flame component
├── models/
│   ├── game_settings.dart   # Configuration model
│   ├── game_stats.dart      # Statistics tracking
│   ├── player_model.dart    # Player logic
│   └── bullet_model.dart    # Bullet patterns & physics
├── services/
│   ├── audio_service.dart   # Cross-platform audio
│   └── ranking_service.dart # Backend integration
└── config/
    ├── environment_config.dart # Environment management
    └── supabase_config.dart    # Backend configuration
```

## 🎯 Game Patterns

### Pattern 1: Targeted Bullets (2-15s)
- Bullets spawn from screen edges and target player's current position
- Frequency increases over time

### Pattern 2: Eight Direction Attack (15s+)
- Simultaneous bullets from 8 directions toward player
- Requires quick positioning and movement

### Pattern 3: Sequential Linear Barrage (30s+)
- Linear bullet walls from each screen edge in sequence
- Tests timing and pattern recognition

## ⚙️ Configuration

The game supports extensive customization:

- **Difficulty**: Bullet speed, player speed, pattern timing
- **Visual**: Hitbox display, debug information
- **Audio**: BGM toggle, volume control
- **Debug**: Invincibility mode, developer features

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

### Environment Setup

See [docs/ENVIRONMENT_SETUP.md](docs/ENVIRONMENT_SETUP.md) for detailed configuration.

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and analysis
5. Submit a pull request

## 📁 Scripts

| Script | Description |
|--------|-------------|
| `scripts/deploy-itch.sh` | Build and package for itch.io |
| `scripts/setup-butler.sh` | Install and setup Butler CLI |
| `scripts/butler-deploy.sh` | Interactive Butler deployment |
| `scripts/debug-butler-download.sh` | Diagnose Butler download issues |

## 🎵 Audio Assets

- BGM: `assets/audio/bgm.wav` (optional)
- Cross-platform audio system with web compatibility
- Automatic fallback when audio files are unavailable

## 🔒 Security

- Environment variables for sensitive configuration
- `.env` files excluded from version control
- Clean separation of development and production settings

## 📚 Documentation

- [CI/CD Setup Guide](docs/CICD_SETUP.md)
- [Environment Configuration](docs/ENVIRONMENT_SETUP.md)

## 🐛 Known Issues

- BGM may be restricted on some itch.io hosting environments
- Linux builds require GTK development libraries
- Web builds use relative paths for itch.io compatibility

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI framework
- [Flame](https://flame-engine.org/) - Game engine
- [Supabase](https://supabase.com/) - Backend services
- [itch.io](https://itch.io/) - Game distribution platform

---

🎮 **Play now**: [itch.io Game Page](https://username.itch.io/avoid-bubble)
