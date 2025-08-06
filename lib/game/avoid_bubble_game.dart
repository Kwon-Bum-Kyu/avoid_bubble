import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../components/player.dart';
import '../components/bullet.dart';

class AvoidBubbleGame extends FlameGame {
  late Player player;
  late TextComponent timeText;
  double spawnRate = 1.0; // bullets per second
  double survivalTime = 0.0;
  double lastBulletSpawn = -1.0; // -1로 시작하여 2초에 첫 총알이 확실히 나오도록
  double lastPattern2Spawn = 0.0; // 8방향 패턴
  double lastPattern3Spawn = 0.0; // 일직선 패턴
  bool isGameOver = false;
  final Random random = Random();
  VoidCallback? onGameOver;

  // 로컬 테스트용 무적 모드
  bool get isInvincible => true; // 로컬에서는 무적

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
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
    add(timeText..priority = 2);

    print('Game initialized - ready to spawn bullets!');
  }

  void spawnBullet() {
    print('Spawning bullet...');

    // Choose random side (0=top, 1=right, 2=bottom, 3=left)
    final side = random.nextInt(4);
    late Vector2 startPosition;
    late Vector2 direction;

    print('Spawn side: $side');

    switch (side) {
      case 0: // Top
        startPosition = Vector2(random.nextDouble() * size.x, -16);
        direction = Vector2(
          (random.nextDouble() - 0.5) * 0.5, // slight horizontal variance
          1.0, // downward
        );
        break;
      case 1: // Right
        startPosition = Vector2(size.x + 16, random.nextDouble() * size.y);
        direction = Vector2(
          -1.0, // leftward
          (random.nextDouble() - 0.5) * 0.5, // slight vertical variance
        );
        break;
      case 2: // Bottom
        startPosition = Vector2(random.nextDouble() * size.x, size.y + 16);
        direction = Vector2(
          (random.nextDouble() - 0.5) * 0.5, // slight horizontal variance
          -1.0, // upward
        );
        break;
      case 3: // Left
        startPosition = Vector2(-16, random.nextDouble() * size.y);
        direction = Vector2(
          1.0, // rightward
          (random.nextDouble() - 0.5) * 0.5, // slight vertical variance
        );
        break;
    }

    final bullet = Bullet(startPosition: startPosition, direction: direction);
    bullet.priority = 1;
    add(bullet);

    print('Bullet created at: $startPosition, direction: $direction');
  }

  // 패턴 1: 플레이어 위치로 날아오는 탄막 (2-15초)
  void spawnTargetedBullet() {
    print(
      '=== PATTERN 1: Targeted Bullet at ${survivalTime.toStringAsFixed(1)}s ===',
    );

    // 맵 밖 화면 가장자리에서 시작
    final side = random.nextInt(4);
    late Vector2 startPosition;

    switch (side) {
      case 0: // Top - 화면 위쪽 가장자리 (확실히 보이게)
        startPosition = Vector2(random.nextDouble() * size.x, 10);
        break;
      case 1: // Right - 화면 오른쪽 가장자리 (확실히 보이게)
        startPosition = Vector2(size.x - 10, random.nextDouble() * size.y);
        break;
      case 2: // Bottom - 화면 아래쪽 가장자리 (확실히 보이게)
        startPosition = Vector2(random.nextDouble() * size.x, size.y - 10);
        break;
      case 3: // Left - 화면 왼쪽 가장자리 (확실히 보이게)
        startPosition = Vector2(10, random.nextDouble() * size.y);
        break;
    }

    // 플레이어 중심점 계산
    final playerCenter = Vector2(
      player.position.x + player.size.x / 2,
      player.position.y + player.size.y / 2,
    );

    // 플레이어 방향으로 향하는 정규화된 방향 벡터
    final direction = (playerCenter - startPosition).normalized();

    final bullet = Bullet(startPosition: startPosition, direction: direction);
    bullet.priority = 1;
    add(bullet);

    print(
      'Bullet spawned from outside map: ${startPosition.toString()} -> player at: ${playerCenter.toString()}',
    );
  }

  // 패턴 2: 8방향에서 플레이어로 날아오는 탄막 (15초부터 5초마다)
  void spawnEightDirectionBullets() {
    print('=== PATTERN 2: Eight Direction Bullets ===');

    final playerCenter = Vector2(
      player.position.x + player.size.x / 2,
      player.position.y + player.size.y / 2,
    );

    // 8방향에서 탄막 생성
    final directions = [
      Vector2(0, -1), // 위
      Vector2(1, -1), // 우상
      Vector2(1, 0), // 우
      Vector2(1, 1), // 우하
      Vector2(0, 1), // 하
      Vector2(-1, 1), // 좌하
      Vector2(-1, 0), // 좌
      Vector2(-1, -1), // 좌상
    ];

    for (int i = 0; i < directions.length; i++) {
      final dir = directions[i];
      // 플레이어에서 충분히 멀리 떨어진 곳에서 시작 (맵 밖)
      final startPosition = playerCenter + (dir * -300);

      // 플레이어 방향으로 향하는 정규화된 벡터
      final targetDirection = (playerCenter - startPosition).normalized();

      add(
        Bullet(startPosition: startPosition, direction: targetDirection)
          ..priority = 1,
      );
    }

    print('8-direction bullets spawned targeting: $playerCenter');
  }

  // 패턴 3: 바닥에서 위로 일직선 탄막 8개 (30초부터 10초마다)
  void spawnLinearBullets() {
    print('=== PATTERN 3: Linear Bullets ===');

    final bulletCount = 8;
    final spacing = size.x / (bulletCount + 1); // 간격을 더 넓게

    for (int i = 1; i <= bulletCount; i++) {
      final startPosition = Vector2(
        spacing * i,
        size.y - 10,
      ); // 화면 아래쪽 가장자리에서 시작
      final direction = Vector2(0, -1).normalized(); // 위쪽 방향 (정규화)

      final bullet = Bullet(startPosition: startPosition, direction: direction);
      bullet.priority = 1;
      add(bullet);
      
      print('📍 Pattern 3 bullet $i: pos=${startPosition.toString()}, dir=${direction.toString()}, vel will be ${(direction * 80).toString()}');
    }

    print('Linear bullets: $bulletCount bullets from bottom to top, spacing: ${spacing.toStringAsFixed(1)}');
  }

  void _handleBulletPatterns() {
    // 패턴 1: 2초~15초 - 플레이어를 향한 탄막 (1초마다)
    if (survivalTime >= 2.0 && survivalTime < 15.0) {
      if (survivalTime - lastBulletSpawn >= 1.0) {
        print(
          '*** PATTERN 1: Spawning targeted bullet at ${survivalTime.toStringAsFixed(2)}s ***',
        );
        spawnTargetedBullet();
        lastBulletSpawn = survivalTime;
      }
    }

    // 패턴 2: 15초부터 - 8방향 탄막 (5초마다)
    if (survivalTime >= 15.0) {
      if (survivalTime - lastPattern2Spawn >= 5.0) {
        spawnEightDirectionBullets();
        lastPattern2Spawn = survivalTime;
      }
    }

    // 패턴 3: 20초부터 - 일직선 탄막 (8초마다)
    if (survivalTime >= 20.0) {
      if (survivalTime - lastPattern3Spawn >= 8.0) {
        print('🎯 Pattern 3 triggered at ${survivalTime.toStringAsFixed(1)}s (last: ${lastPattern3Spawn.toStringAsFixed(1)}s)');
        spawnLinearBullets();
        lastPattern3Spawn = survivalTime;
      }
    }

    // 15초 이후에는 패턴 1도 계속 진행 (더 빠르게)
    if (survivalTime >= 15.0) {
      if (survivalTime - lastBulletSpawn >= 0.8) {
        spawnTargetedBullet();
        lastBulletSpawn = survivalTime;
      }
    }
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

      // 패턴별 탄막 스폰 로직
      _handleBulletPatterns();

      // Debug: print bullet count every 2 seconds
      if (survivalTime % 2.0 < 0.1) {
        final bulletCount = children.whereType<Bullet>().length;
        print(
          'Bullets in game: $bulletCount, spawn rate: ${spawnRate.toStringAsFixed(2)}',
        );
      }
    }
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    print(
      'Game Over! Final survival time: ${survivalTime.toStringAsFixed(1)}s',
    );

    // Call the game over callback
    onGameOver?.call();
  }

  void restart() {
    // Remove all bullets
    children.whereType<Bullet>().forEach((bullet) => bullet.removeFromParent());

    // Reset game state
    isGameOver = false;
    survivalTime = 0.0;
    lastBulletSpawn = -1.0; // 이전 값을 -1로 설정하여 2초에 첫 총알이 나오도록 보장
    lastPattern2Spawn = 0.0;
    lastPattern3Spawn = 0.0;
    spawnRate = 1.0;

    print('Game restarted! lastBulletSpawn reset to -1.0');

    // Reset player position to center
    player.position = Vector2(
      (size.x / 2) - (player.size.x / 2),
      (size.y / 2) - (player.size.y / 2),
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
