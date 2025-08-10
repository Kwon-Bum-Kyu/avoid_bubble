import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../components/player.dart';
import '../components/bullet.dart';
import '../models/game_settings.dart';
import '../models/bullet_model.dart';

// 게임의 핵심 로직을 담고 있는 메인 클래스
class AvoidBubbleGame extends FlameGame {
  final GameSettings settings; // 게임 설정값
  late Player player; // 플레이어 컴포넌트
  late TextComponent timeText; // 생존 시간 표시 텍스트
  double survivalTime = 0.0; // 생존 시간

  // 각 패턴의 마지막 생성 시간 기록
  double lastBulletSpawn = -1.0; // 이전 값을 -1로 설정하여 2초에 첫 총알이 나오도록 보장
  double lastPattern2Spawn = 0.0;
  double lastPattern3Spawn = 0.0;

  int pattern3Direction = 0; // 패턴 3의 방향 순서 (0:상, 1:하, 2:좌, 3:우)
  bool isGameOver = false; // 게임 오버 상태
  final Random random = Random(); // 랜덤 숫자 생성기
  VoidCallback? onGameOver; // 게임 오버 시 호출될 콜백

  // 생성자
  AvoidBubbleGame({required this.settings});

  // 무적 모드 여부 getter
  bool get isInvincible => settings.isInvincible;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 배경 이미지 추가
    final background = await Sprite.load('background.png');
    add(
      SpriteComponent(sprite: background, size: size, anchor: Anchor.topLeft)
        ..priority = 0, // 우선순위를 낮게 설정하여 배경에 위치
    );

    // 플레이어 추가
    player = Player(speed: settings.playerSpeed);
    add(player..priority = 1);

    // 생존 시간 텍스트 추가
    timeText = TextComponent(
      text: 'Time: 0.0s',
      position: Vector2(20, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'NexonCart',
          shadows: [
            // 텍스트 가독성을 위한 그림자 효과
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Color(0x80000000),
            ),
          ],
        ),
      ),
    );
    add(timeText..priority = 2); // 다른 컴포넌트보다 위에 표시
  }

  // 기본 총알 생성 (현재는 사용되지 않음)
  void spawnBullet() {
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

  // 패턴 1: 플레이어를 타겟팅하는 총알 생성
  void spawnTargetedBullet() {
    // 화면 가장자리 4방향 중 랜덤한 위치에서 시작
    final side = random.nextInt(4);
    late Vector2 startPosition;

    switch (side) {
      case 0: // 상단
        startPosition = Vector2(random.nextDouble() * size.x, 10);
        break;
      case 1: // 우측
        startPosition = Vector2(size.x - 10, random.nextDouble() * size.y);
        break;
      case 2: // 하단
        startPosition = Vector2(random.nextDouble() * size.x, size.y - 10);
        break;
      case 3: // 좌측
        startPosition = Vector2(10, random.nextDouble() * size.y);
        break;
    }

    final playerCenter = player.playerCenter;
    // 시작 위치에서 플레이어 중앙으로 향하는 방향 벡터 계산
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

  // 패턴 2: 8방향에서 플레이어를 향해 날아오는 총알 생성
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

    // 화면 대각선 길이를 기반으로 한 안전한 생성 거리 계산
    final safeDistance = size.length / 2 + 50;

    for (final dir in directions) {
      // 플레이어의 반대 방향 멀리서 시작 위치 설정
      final startPosition = playerCenter - (dir * safeDistance);
      // 시작점에서 플레이어를 향하는 방향 계산
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

  // 패턴 3: 상하좌우 순서대로 한 방향에서 일직선으로 총알 생성
  void spawnLinearBullets() {
    final bulletCount = 8;
    final direction = pattern3Direction;

    late Vector2 startPos;
    late Vector2 directionVector;
    late double spacing;

    switch (direction) {
      case 0: // 위에서 아래로
        spacing = size.x / (bulletCount + 1);
        directionVector = Vector2(0, 1).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(spacing * i, -10);
          add(
            Bullet(
              startPosition: startPos,
              direction: directionVector,
              speed: settings.bulletSpeed,
              type: BulletType.linear,
            )..priority = 1,
          );
        }
        break;
      case 1: // 오른쪽에서 왼쪽으로
        spacing = size.y / (bulletCount + 1);
        directionVector = Vector2(-1, 0).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(size.x + 10, spacing * i);
          add(
            Bullet(
              startPosition: startPos,
              direction: directionVector,
              speed: settings.bulletSpeed,
              type: BulletType.linear,
            )..priority = 1,
          );
        }
        break;
      case 2: // 아래에서 위로
        spacing = size.x / (bulletCount + 1);
        directionVector = Vector2(0, -1).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(spacing * i, size.y + 10);
          add(
            Bullet(
              startPosition: startPos,
              direction: directionVector,
              speed: settings.bulletSpeed,
              type: BulletType.linear,
            )..priority = 1,
          );
        }
        break;
      case 3: // 왼쪽에서 오른쪽으로
        spacing = size.y / (bulletCount + 1);
        directionVector = Vector2(1, 0).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(-10, spacing * i);
          add(
            Bullet(
              startPosition: startPos,
              direction: directionVector,
              speed: settings.bulletSpeed,
              type: BulletType.linear,
            )..priority = 1,
          );
        }
        break;
    }

    // 다음 패턴을 위해 방향 순서 변경
    pattern3Direction = (pattern3Direction + 1) % 4;
  }

  // 생존 시간에 따라 총알 패턴을 관리하고 실행
  void _handleBulletPatterns() {
    final timings = settings.patternTimings;

    // 패턴 1 실행
    if (survivalTime >= timings.pattern1StartTime &&
        survivalTime < timings.pattern1EndTime) {
      if (survivalTime - lastBulletSpawn >= timings.pattern1Interval) {
        spawnTargetedBullet();
        lastBulletSpawn = survivalTime;
      }
    }

    // 패턴 2 실행
    if (survivalTime >= timings.pattern2StartTime) {
      if (survivalTime - lastPattern2Spawn >= timings.pattern2Interval) {
        spawnEightDirectionBullets();
        lastPattern2Spawn = survivalTime;
      }
    }

    // 패턴 3 실행
    if (survivalTime >= timings.pattern3StartTime) {
      if (survivalTime - lastPattern3Spawn >= timings.pattern3Interval) {
        spawnLinearBullets();
        lastPattern3Spawn = survivalTime;
      }
    }

    // 15초 이후 패턴 1 강화
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
      // 생존 시간 업데이트 및 표시
      survivalTime += dt;
      timeText.text = 'Time: ${survivalTime.toStringAsFixed(1)}s';

      // 플레이어 충돌 확인
      player.checkCollisions();

      // 총알 패턴 관리
      _handleBulletPatterns();
    }
  }

  // 게임 오버 처리
  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    onGameOver?.call(); // 게임 오버 콜백 호출
  }

  // 게임 재시작
  void restart() {
    // 모든 총알 제거
    children.whereType<Bullet>().forEach((bullet) => bullet.removeFromParent());

    // 게임 상태 초기화
    isGameOver = false;
    survivalTime = 0.0;
    lastBulletSpawn = -1.0;
    lastPattern2Spawn = 0.0;
    lastPattern3Spawn = 0.0;
    pattern3Direction = 0;

    // 플레이어 위치 리셋
    player.resetToCenter();
  }

  // 플레이어 움직임 설정 (외부에서 호출)
  void setPlayerMovement(double x, double y) {
    if (!isGameOver) {
      player.setMovement(x, y);
    }
  }

  // 재시작 시도 (외부에서 호출)
  void tryRestart() {
    if (isGameOver) {
      restart();
    }
  }
}
