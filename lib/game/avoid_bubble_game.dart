import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../components/player.dart';
import '../components/bullet.dart';
import '../models/game_settings.dart';
import '../models/bullet_model.dart';

class AvoidBubbleGame extends FlameGame {
  final GameSettings settings;
  late Player player;
  late TextComponent timeText;
  double spawnRate = 1.0; // bullets per second
  double survivalTime = 0.0;
  double lastBulletSpawn = -1.0; // -1로 시작하여 2초에 첫 총알이 확실히 나오도록
  double lastPattern2Spawn = 0.0; // 8방향 패턴
  double lastPattern3Spawn = 0.0; // 일직선 패턴
  int pattern3Direction = 0; // 패턴 3 방향 순서 (0: 위, 1: 아래, 2: 왼쪽, 3: 오른쪽)
  bool isGameOver = false;
  final Random random = Random();
  VoidCallback? onGameOver;

  AvoidBubbleGame({required this.settings});

  bool get isInvincible => settings.isInvincible;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background image
    final background = await Sprite.load('background.png');
    add(
      SpriteComponent(
        sprite: background,
        size: size,
        anchor: Anchor.topLeft,
      )..priority = 0,
    );

    // Add player
    player = Player(speed: settings.playerSpeed);
    add(player..priority = 1);

    // Add survival time display
    timeText = TextComponent(
      text: 'Time: 0.0s',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'NexonCart',
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Color(0x80000000),
            ),
          ],
        ),
      ),
    );
    add(timeText..priority = 2);

  }

  void spawnBullet() {
    // Choose random side (0=top, 1=right, 2=bottom, 3=left)
    final side = random.nextInt(4);
    late Vector2 startPosition;
    late Vector2 direction;

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

    final bullet = Bullet(
      startPosition: startPosition,
      direction: direction,
      speed: settings.bulletSpeed,
    );
    bullet.priority = 1;
    add(bullet);
  }

  // 패턴 1: 플레이어 위치로 날아오는 탄막 (2-15초)
  void spawnTargetedBullet() {
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

    final playerCenter = player.playerCenter;
    final direction = (playerCenter - startPosition).normalized();

    final bullet = Bullet(
      startPosition: startPosition,
      direction: direction,
      speed: settings.bulletSpeed,
      type: BulletType.targeted,
    );
    bullet.priority = 1;
    add(bullet);
  }

  // 패턴 2: 8방향에서 플레이어로 날아오는 탄막 (15초부터 5초마다)
  void spawnEightDirectionBullets() {
    final playerCenter = player.playerCenter;

    // 8개의 정규화된 방향 벡터
    final directions = [
      Vector2(0, -1), // N
      Vector2(1, -1)..normalize(), // NE
      Vector2(1, 0), // E
      Vector2(1, 1)..normalize(), // SE
      Vector2(0, 1), // S
      Vector2(-1, 1)..normalize(), // SW
      Vector2(-1, 0), // W
      Vector2(-1, -1)..normalize(), // NW
    ];

    // 화면 대각선 길이를 기반으로 한 일관된 생성 거리
    final safeDistance = size.length / 2 + 50; // 화면 대각선의 절반 + 여유 거리

    for (final dir in directions) {
      // 플레이어의 반대 방향 멀리서 시작
      final startPosition = playerCenter - (dir * safeDistance);

      // 시작점에서 플레이어를 향하는 방향
      final targetDirection = (playerCenter - startPosition).normalized();

      add(
        Bullet(
          startPosition: startPosition,
          direction: targetDirection,
          speed: settings.bulletSpeed,
          type: BulletType.directional,
        )..priority = 1,
      );
    }
  }

  // 패턴 3: 상하좌우 순서대로 한 방향에서 일직선 탄막 8개
  void spawnLinearBullets() {
    final bulletCount = 8;
    final direction = pattern3Direction; // 순서대로 방향 변경

    late Vector2 startPos;
    late Vector2 directionVector;
    late double spacing;

    switch (direction) {
      case 0: // 위에서 아래로
        spacing = size.x / (bulletCount + 1);
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(spacing * i, -10);
          directionVector = Vector2(0, 1).normalized();

          final bullet = Bullet(
            startPosition: startPos,
            direction: directionVector,
            speed: settings.bulletSpeed,
            type: BulletType.linear,
          );
          bullet.priority = 1;
          add(bullet);
        }
        break;

      case 1: // 오른쪽에서 왼쪽으로
        spacing = size.y / (bulletCount + 1);
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(size.x + 10, spacing * i);
          directionVector = Vector2(-1, 0).normalized();

          final bullet = Bullet(
            startPosition: startPos,
            direction: directionVector,
            speed: settings.bulletSpeed,
            type: BulletType.linear,
          );
          bullet.priority = 1;
          add(bullet);
        }
        break;

      case 2: // 아래에서 위로
        spacing = size.x / (bulletCount + 1);
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(spacing * i, size.y + 10);
          directionVector = Vector2(0, -1).normalized();

          final bullet = Bullet(
            startPosition: startPos,
            direction: directionVector,
            speed: settings.bulletSpeed,
            type: BulletType.linear,
          );
          bullet.priority = 1;
          add(bullet);
        }
        break;

      case 3: // 왼쪽에서 오른쪽으로
        spacing = size.y / (bulletCount + 1);
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(-10, spacing * i);
          directionVector = Vector2(1, 0).normalized();

          final bullet = Bullet(
            startPosition: startPos,
            direction: directionVector,
            speed: settings.bulletSpeed,
            type: BulletType.linear,
          );
          bullet.priority = 1;
          add(bullet);
        }
        break;
    }

    // 다음 발동을 위해 방향 순서 변경 (0: 위 → 1: 아래 → 2: 왼쪽 → 3: 오른쪽 → 0: 위)
    pattern3Direction = (pattern3Direction + 1) % 4;
  }

  void _handleBulletPatterns() {
    final timings = settings.patternTimings;

    // 패턴 1: 설정된 시간부터 시작 - 플레이어를 향한 탄막
    if (survivalTime >= timings.pattern1StartTime &&
        survivalTime < timings.pattern1EndTime) {
      if (survivalTime - lastBulletSpawn >= timings.pattern1Interval) {
        spawnTargetedBullet();
        lastBulletSpawn = survivalTime;
      }
    }

    // 패턴 2: 설정된 시간부터 - 8방향 탄막
    if (survivalTime >= timings.pattern2StartTime) {
      if (survivalTime - lastPattern2Spawn >= timings.pattern2Interval) {
        spawnEightDirectionBullets();
        lastPattern2Spawn = survivalTime;
      }
    }

    // 패턴 3: 설정된 시간부터 - 일직선 탄막
    if (survivalTime >= timings.pattern3StartTime) {
      if (survivalTime - lastPattern3Spawn >= timings.pattern3Interval) {
        spawnLinearBullets();
        lastPattern3Spawn = survivalTime;
      }
    }

    // 패턴 1 종료 후에는 더 빠른 주기로 계속 진행
    if (survivalTime >= timings.pattern1EndTime) {
      if (survivalTime - lastBulletSpawn >= timings.pattern1FastInterval) {
        spawnTargetedBullet();
        lastBulletSpawn = survivalTime;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isGameOver) {
      survivalTime += dt;
      timeText.text = 'Time: ${survivalTime.toStringAsFixed(1)}s';

      player.checkCollisions();

      // 패턴별 탄막 스폰 로직
      _handleBulletPatterns();
    }
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;

    onGameOver?.call();
  }

  void restart() {
    // 총알 초기화
    children.whereType<Bullet>().forEach((bullet) => bullet.removeFromParent());

    // 게임 스텟 초기화
    isGameOver = false;
    survivalTime = 0.0;
    lastBulletSpawn = -1.0; // 이전 값을 -1로 설정하여 2초에 첫 총알이 나오도록 보장
    lastPattern2Spawn = 0.0;
    lastPattern3Spawn = 0.0;
    pattern3Direction = 0; // 패턴 3 방향 순서 리셋
    spawnRate = 1.0;

    player.resetToCenter();
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
