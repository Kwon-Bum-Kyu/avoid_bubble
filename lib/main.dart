import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/avoid_bubble_game.dart';
import 'game/game_state.dart';
import 'models/game_settings.dart';
import 'models/game_stats.dart';
import 'screens/start_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/ranking_screen.dart';
import 'config/environment_config.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // 환경 설정 초기화
    await EnvironmentConfig.initialize();
    
    // Supabase 초기화
    await SupabaseConfig.initialize();
    
    if (kDebugMode) {
      print('✅ Supabase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Initialization error: $e');
      print('⚠️  Running without Supabase (ranking disabled)');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '어보이드 버블',
      theme: ThemeData(fontFamily: 'NexonCart'),
      home: const GameWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  GameWrapperState createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> {
  GameState _currentState = GameState.startScreen;
  late AvoidBubbleGame game;
  GameSettings _settings = GameSettings.defaultSettings();
  GameStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _createNewGame();
  }

  Future<void> _loadStats() async {
    final stats = await GameStats.load();
    setState(() {
      _stats = stats;
    });
  }

  void _createNewGame() {
    game = AvoidBubbleGame(settings: _settings);
    game.onGameOver = _showGameOver;
  }

  void _startGame() {
    setState(() {
      _currentState = GameState.playing;
    });
  }

  void _showGameOver() {
    _stats?.recordGame(game.survivalTime, 'F', 0); // Grade and bullets avoided are not implemented yet
    setState(() {
      _currentState = GameState.gameOver;
    });
  }

  void _restartGame() {
    game.restart();
    setState(() {
      _currentState = GameState.playing;
    });
  }

  void _showSettings() {
    setState(() {
      _currentState = GameState.settings;
    });
  }

  void _updateSettings(GameSettings newSettings) {
    setState(() {
      _settings = newSettings;
      _createNewGame(); // Recreate game with new settings
    });
  }

  void _backToStart() {
    setState(() {
      _currentState = GameState.startScreen;
      _createNewGame(); // Create new game instance
    });
  }

  void _showRanking() {
    setState(() {
      _currentState = GameState.ranking;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_stats == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    switch (_currentState) {
      case GameState.startScreen:
        return StartScreen(
          onStartGame: _startGame,
          onShowSettings: _showSettings,
          stats: _stats!,
        );
      case GameState.settings:
        return SettingsScreen(
          settings: _settings,
          onSettingsChanged: _updateSettings,
          onBack: _backToStart,
        );
      case GameState.playing:
        return GameScreen(game: game, onBackToStart: _backToStart);
      case GameState.gameOver:
        return GameOverScreen(
          survivalTime: game.survivalTime,
          onRestart: _restartGame,
          onBackToMenu: _backToStart,
          onShowRanking: _showRanking,
        );
      case GameState.ranking:
        return RankingScreen(
          onBack: _backToStart,
        );
    }
  }
}

class GameScreen extends StatefulWidget {
  final AvoidBubbleGame game;
  final VoidCallback onBackToStart;

  const GameScreen({
    super.key,
    required this.game,
    required this.onBackToStart,
  });

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late FocusNode _focusNode;
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Request focus immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _keysPressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }

    _updatePlayerMovement();
  }

  void _updatePlayerMovement() {
    double x = 0, y = 0;

    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA)) {
      x = -1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD)) {
      x = 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        _keysPressed.contains(LogicalKeyboardKey.keyW)) {
      y = -1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        _keysPressed.contains(LogicalKeyboardKey.keyS)) {
      y = 1;
    }

    if (_keysPressed.contains(LogicalKeyboardKey.keyR)) {
      widget.game.tryRestart();
    }

    if (_keysPressed.contains(LogicalKeyboardKey.escape)) {
      widget.onBackToStart();
    }

    widget.game.setPlayerMovement(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
          },
          child: Stack(
            children: [
              GameWidget(game: widget.game),

              // Home button (맨 위에 위치하여 다른 요소들에 가려지지 않도록)
              Positioned(
                top: 40,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      widget.onBackToStart();
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
