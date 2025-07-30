import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../game/avoid_bubble_game.dart';
import 'bullet.dart';

class Player extends RectangleComponent with KeyboardHandler {
  static const double speed = 200.0;
  late Vector2 velocity;
  
  Player() : super(
    size: Vector2(40, 40),
    paint: Paint()..color = const Color(0xFF4FC3F7),
  );

  @override
  Future<void> onLoad() async {
    velocity = Vector2.zero();
    final game = parent! as AvoidBubbleGame;
    position = Vector2(
      (game.size.x / 2) - (size.x / 2),
      game.size.y - 80,
    );
    
    print('Player loaded and ready for keyboard input!');
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply velocity
    position += velocity * dt;
    
    // Keep player within screen bounds
    final game = parent! as AvoidBubbleGame;
    position.x = position.x.clamp(0, game.size.x - size.x);
    position.y = position.y.clamp(0, game.size.y - size.y);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final game = parent! as AvoidBubbleGame;
    
    print('Key event detected: $event, keys: ${keysPressed.map((k) => k.keyLabel)}');
    
    // Handle restart
    if (keysPressed.contains(LogicalKeyboardKey.keyR) && game.isGameOver) {
      game.restart();
      return true;
    }
    
    // Don't move if game is over
    if (game.isGameOver) {
      velocity.setZero();
      return true;
    }
    
    velocity.setZero();
    
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || 
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      velocity.x = -speed;
      print('Moving left');
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || 
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      velocity.x = speed;
      print('Moving right');
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || 
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      velocity.y = -speed;
      print('Moving up');
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || 
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      velocity.y = speed;
      print('Moving down');
    }
    
    return true;
  }

  void setMovement(double x, double y) {
    velocity.setValues(x * speed, y * speed);
    print('Setting movement: x=$x, y=$y, velocity=$velocity');
  }

  void checkCollisions() {
    final game = parent! as AvoidBubbleGame;
    final bullets = game.children.whereType<Bullet>();
    
    for (final bullet in bullets) {
      // Check if bullet center is within player bounds
      final dx = (position.x + size.x / 2) - (bullet.position.x + bullet.radius);
      final dy = (position.y + size.y / 2) - (bullet.position.y + bullet.radius);
      final distance = sqrt(dx * dx + dy * dy);
      
      if (distance < (size.x / 2 + bullet.radius)) {
        game.gameOver();
        break;
      }
    }
  }
}