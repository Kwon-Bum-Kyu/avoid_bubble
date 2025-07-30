import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../components/player.dart';
import '../components/bullet.dart';

class AvoidBubbleGame extends FlameGame {
  late Player player;
  late TimerComponent bulletSpawner;
  late TextComponent timeText;
  double spawnRate = 1.0; // bullets per second
  double survivalTime = 0.0;
  bool isGameOver = false;
  final Random random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background color
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF1A1A2E),
        priority: 0,
      ),
    );

    // Add player
    player = Player();
    add(player..priority = 1);

    // Add survival time display
    timeText = TextComponent(
      text: 'Time: 0.0s',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
    add(timeText..priority = 2);

    // Add bullet spawner
    bulletSpawner = TimerComponent(
      period: 1.0 / spawnRate,
      repeat: true,
      onTick: spawnBullet,
    );
    add(bulletSpawner);
  }

  void spawnBullet() {
    final x = random.nextDouble() * (size.x - 16);
    add(Bullet(startPosition: Vector2(x, -16))..priority = 1);
  }


  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isGameOver) {
      // Update survival time
      survivalTime += dt;
      timeText.text = 'Time: ${survivalTime.toStringAsFixed(1)}s';
      
      // Check collisions
      player.checkCollisions();
      
      // Gradually increase spawn rate for difficulty
      spawnRate = 1.0 + (survivalTime * 0.1);
      bulletSpawner.timer.limit = 1.0 / spawnRate;
    }
  }

  void gameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    bulletSpawner.timer.stop();
    
    // Add game over text
    add(TextComponent(
      text: 'GAME OVER\nSurvival Time: ${survivalTime.toStringAsFixed(1)}s\nPress R to Restart',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 32,
        ),
      ),
    )..priority = 3);
  }

  void restart() {
    // Remove all bullets
    children.whereType<Bullet>().forEach((bullet) => bullet.removeFromParent());
    
    // Reset game state
    isGameOver = false;
    survivalTime = 0.0;
    spawnRate = 1.0;
    
    // Remove game over text
    children.whereType<TextComponent>().where((text) => text.text.contains('GAME OVER')).forEach((text) => text.removeFromParent());
    
    // Restart bullet spawner
    bulletSpawner.timer.start();
    
    // Reset player position
    player.position = Vector2(
      (size.x / 2) - (player.size.x / 2),
      size.y - 80,
    );
  }

  void setPlayerMovement(double x, double y) {
    if (!isGameOver) {
      player.setMovement(x, y);
    }
  }

  void tryRestart() {
    if (isGameOver) {
      restart();
    }
  }
}