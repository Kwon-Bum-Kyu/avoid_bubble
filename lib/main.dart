import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/avoid_bubble_game.dart';
import 'game/game_state.dart';
import 'screens/start_screen.dart';
import 'screens/game_over_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avoid Bubble Game',
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

  @override
  void initState() {
    super.initState();
    _createNewGame();
  }

  void _createNewGame() {
    game = AvoidBubbleGame();
    game.onGameOver = _showGameOver;
  }

  void _startGame() {
    setState(() {
      _currentState = GameState.playing;
    });
  }

  void _showGameOver() {
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

  void _backToStart() {
    setState(() {
      _currentState = GameState.startScreen;
      _createNewGame(); // Create new game instance
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case GameState.startScreen:
        return StartScreen(onStartGame: _startGame);
      case GameState.playing:
        return GameScreen(game: game, onBackToStart: _backToStart);
      case GameState.gameOver:
        return GameOverScreen(
          survivalTime: game.survivalTime,
          onRestart: _restartGame,
          onBackToMenu: _backToStart,
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
              // Virtual controls overlay
              Positioned.fill(
                child: Row(
                  children: [
                    // Left side - left movement
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => widget.game.setPlayerMovement(-1, 0),
                        onTapUp: (_) => widget.game.setPlayerMovement(0, 0),
                        onTapCancel: () => widget.game.setPlayerMovement(0, 0),
                        child: Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Icon(
                              Icons.arrow_left,
                              size: 50,
                              color: Colors.white30,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Right side - right movement
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => widget.game.setPlayerMovement(1, 0),
                        onTapUp: (_) => widget.game.setPlayerMovement(0, 0),
                        onTapCancel: () => widget.game.setPlayerMovement(0, 0),
                        child: Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Icon(
                              Icons.arrow_right,
                              size: 50,
                              color: Colors.white30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Instructions
              const Positioned(
                top: 100,
                left: 20,
                child: Text(
                  'WASD/Arrow keys or tap left/right to move\nESC or Home button to return to menu\nAvoid the bubbles!',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              // Home button (맨 위에 위치하여 다른 요소들에 가려지지 않도록)
              Positioned(
                top: 40,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      print('🏠 Home button pressed - returning to start screen');
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
