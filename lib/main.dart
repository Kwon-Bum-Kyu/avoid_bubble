import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/avoid_bubble_game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avoid Bubble Game',
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late AvoidBubbleGame game;
  late FocusNode _focusNode;
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};

  @override
  void initState() {
    super.initState();
    game = AvoidBubbleGame();
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
    print('Key event: $event');
    
    if (event is KeyDownEvent) {
      _keysPressed.add(event.logicalKey);
      print('Key down: ${event.logicalKey.keyLabel}');
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
      print('Key up: ${event.logicalKey.keyLabel}');
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
      game.tryRestart();
    }
    
    game.setPlayerMovement(x, y);
    print('Setting movement: x=$x, y=$y');
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
            print('Focus requested');
          },
          child: Stack(
            children: [
              GameWidget(game: game),
              // Virtual controls overlay
              Positioned.fill(
                child: Row(
                  children: [
                    // Left side - left movement
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => game.setPlayerMovement(-1, 0),
                        onTapUp: (_) => game.setPlayerMovement(0, 0),
                        onTapCancel: () => game.setPlayerMovement(0, 0),
                        child: Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Icon(Icons.arrow_left, size: 50, color: Colors.white30),
                          ),
                        ),
                      ),
                    ),
                    // Right side - right movement  
                    Expanded(
                      child: GestureDetector(
                        onTapDown: (_) => game.setPlayerMovement(1, 0),
                        onTapUp: (_) => game.setPlayerMovement(0, 0),
                        onTapCancel: () => game.setPlayerMovement(0, 0),
                        child: Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: Icon(Icons.arrow_right, size: 50, color: Colors.white30),
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
                  'WASD/Arrow keys or tap left/right to move\nClick screen to focus for keyboard\nAvoid the bubbles!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
