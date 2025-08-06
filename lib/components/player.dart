import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../game/avoid_bubble_game.dart';
import 'bullet.dart';

class Player extends RectangleComponent with KeyboardHandler {
  static const double speed = 200.0;
  late Vector2 velocity;

  Player()
    : super(
        size: Vector2(40, 40),
        paint: Paint()..color = const Color(0xFF4FC3F7),
      );

  @override
  Future<void> onLoad() async {
    velocity = Vector2.zero();
    final game = parent! as AvoidBubbleGame;
    position = Vector2(
      (game.size.x / 2) - (size.x / 2), // 화면 중앙 가로
      (game.size.y / 2) - (size.y / 2), // 화면 중앙 세로
    );

    print('Player loaded at center and ready for keyboard input!');
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
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      velocity.x = speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW)) {
      velocity.y = -speed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        keysPressed.contains(LogicalKeyboardKey.keyS)) {
      velocity.y = speed;
    }

    return true;
  }

  void setMovement(double x, double y) {
    velocity.setValues(x * speed, y * speed);
  }

  void checkCollisions() {
    final game = parent! as AvoidBubbleGame;
    final bullets = game.children.whereType<Bullet>();

    // 무적 모드 상태 확인
    if (bullets.isNotEmpty) {
      print('🔍 Checking collisions - Invincible mode: ${game.isInvincible}, Bullets: ${bullets.length}');
    }

    for (final bullet in bullets) {
      // Check if bullet center is within player bounds
      final playerCenter = Vector2(
        position.x + size.x / 2,
        position.y + size.y / 2,
      );
      final bulletCenter = Vector2(bullet.position.x, bullet.position.y);
      final distance = playerCenter.distanceTo(bulletCenter);
      final collisionDistance = (size.x / 2) + bullet.radius;
      
      if (distance < collisionDistance) {
        print('⚠️  COLLISION DISTANCE: ${distance.toStringAsFixed(2)} < ${collisionDistance.toStringAsFixed(2)}');
        print('🛡️  Invincible status: ${game.isInvincible}');
        
        if (game.isInvincible) {
          print('💀 COLLISION DETECTED but invincible mode is ON at ${game.survivalTime.toStringAsFixed(1)}s');
          // 무적 모드에서는 총알을 제거하고 계속 진행
          bullet.removeFromParent();
        } else {
          print('COLLISION! Player hit at ${game.survivalTime.toStringAsFixed(1)}s');
          game.gameOver();
          break;
        }
      }
    }
  }
}
