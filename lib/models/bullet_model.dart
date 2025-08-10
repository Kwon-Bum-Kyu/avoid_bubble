import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// 총알의 종류를 나타내는 enum
enum BulletType {
  targeted, // 패턴 1: 플레이어 타겟팅
  directional, // 패턴 2: 8방향
  linear, // 패턴 3: 직선
}

// 총알의 데이터와 상태를 관리하는 모델 클래스
class BulletModel {
  final double speed; // 속도
  final double radius; // 반지름 (충돌 감지용)
  final BulletType type; // 총알 종류
  final Vector2 startPosition; // 시작 위치
  final Vector2 direction; // 방향
  Vector2 position; // 현재 위치
  late Vector2 velocity; // 속도 벡터
  bool hasEnteredScreen; // 화면에 진입한 적 있는지 여부
  bool isActive; // 활성화 상태 여부

  // 생성자
  BulletModel({
    required this.startPosition,
    required this.direction,
    this.speed = 100.0,
    this.radius = 20.0,
    this.type = BulletType.targeted,
  }) : position = startPosition.clone(),
       hasEnteredScreen = false,
       isActive = true {
    // 방향과 속도를 기반으로 속도 벡터 초기화
    if (direction.length > 0) {
      velocity = direction.normalized() * speed;
    } else {
      velocity = Vector2.zero();
    }
  }

  // 매 프레임마다 위치 업데이트
  void updatePosition(double dt) {
    if (!isActive) return;

    position += velocity * dt;
  }

  // 총알을 제거해야 하는지 확인
  bool shouldRemove(Vector2 screenSize, Vector2 playerPosition) {
    if (!isActive) return true;

    // 화면 경계에 반지름만큼의 버퍼를 둔 사각형 정의
    final screenRect = Rect.fromLTWH(
      -radius,
      -radius,
      screenSize.x + 2 * radius,
      screenSize.y + 2 * radius,
    );

    // 총알이 화면에 진입했는지 추적
    if (!hasEnteredScreen && screenRect.contains(position.toOffset())) {
      hasEnteredScreen = true;
    }

    // 화면에 진입했다가 나간 총알은 제거
    if (hasEnteredScreen && !screenRect.contains(position.toOffset())) {
      return true;
    }

    // 화면에 진입하지 않고 너무 멀리 날아간 총알 제거 (안전장치)
    if (!hasEnteredScreen && position.distanceTo(playerPosition) > 2000) {
      return true;
    }

    return false;
  }

  // 플레이어와의 충돌 확인
  bool checkCollisionWith(Vector2 playerCenter, double playerRadius) {
    if (!isActive) return false;

    final distance = position.distanceTo(playerCenter);
    final collisionDistance = radius + playerRadius;

    return distance < collisionDistance;
  }

  // 총알 비활성화
  void deactivate() {
    isActive = false;
  }

  // 중심 좌표 getter
  Vector2 get center => position.clone();

  // 특정 패턴의 총알을 생성하는 팩토리 메서드들
  static BulletModel createTargeted({
    required Vector2 startPosition,
    required Vector2 playerPosition,
    double speed = 100.0,
    double radius = 20.0,
  }) {
    final direction = (playerPosition - startPosition).normalized();
    return BulletModel(
      startPosition: startPosition,
      direction: direction,
      speed: speed,
      radius: radius,
      type: BulletType.targeted,
    );
  }

  static BulletModel createDirectional({
    required Vector2 startPosition,
    required Vector2 direction,
    double speed = 100.0,
    double radius = 20.0,
  }) {
    return BulletModel(
      startPosition: startPosition,
      direction: direction,
      speed: speed,
      radius: radius,
      type: BulletType.directional,
    );
  }

  static BulletModel createLinear({
    required Vector2 startPosition,
    required Vector2 direction,
    double speed = 100.0,
    double radius = 20.0,
  }) {
    return BulletModel(
      startPosition: startPosition,
      direction: direction,
      speed: speed,
      radius: radius,
      type: BulletType.linear,
    );
  }

  // 8방향 패턴 총알 리스트 생성
  static List<BulletModel> createEightDirectionBullets({
    required Vector2 playerCenter,
    required Vector2 screenSize,
    double speed = 100.0,
    double radius = 20.0,
  }) {
    final bullets = <BulletModel>[];

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

    final safeDistance = screenSize.length / 2 + 50;

    for (final dir in directions) {
      final startPosition = playerCenter - (dir * safeDistance);
      final targetDirection = (playerCenter - startPosition).normalized();

      bullets.add(
        BulletModel.createDirectional(
          startPosition: startPosition,
          direction: targetDirection,
          speed: speed,
          radius: radius,
        ),
      );
    }

    return bullets;
  }

  // 직선 패턴 총알 리스트 생성
  static List<BulletModel> createLinearBullets({
    required int direction, // 0: 위, 1: 오른쪽, 2: 아래, 3: 왼쪽
    required Vector2 screenSize,
    int bulletCount = 8,
    double speed = 100.0,
    double radius = 20.0,
  }) {
    final bullets = <BulletModel>[];

    late Vector2 startPos;
    late Vector2 directionVector;
    late double spacing;

    switch (direction) {
      case 0: // 위에서 아래로
        spacing = screenSize.x / (bulletCount + 1);
        directionVector = Vector2(0, 1).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(spacing * i, -10);
          bullets.add(
            BulletModel.createLinear(
              startPosition: startPos,
              direction: directionVector,
              speed: speed,
              radius: radius,
            ),
          );
        }
        break;

      case 1: // 오른쪽에서 왼쪽으로
        spacing = screenSize.y / (bulletCount + 1);
        directionVector = Vector2(-1, 0).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(screenSize.x + 10, spacing * i);
          bullets.add(
            BulletModel.createLinear(
              startPosition: startPos,
              direction: directionVector,
              speed: speed,
              radius: radius,
            ),
          );
        }
        break;

      case 2: // 아래에서 위로
        spacing = screenSize.x / (bulletCount + 1);
        directionVector = Vector2(0, -1).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(spacing * i, screenSize.y + 10);
          bullets.add(
            BulletModel.createLinear(
              startPosition: startPos,
              direction: directionVector,
              speed: speed,
              radius: radius,
            ),
          );
        }
        break;

      case 3: // 왼쪽에서 오른쪽으로
        spacing = screenSize.y / (bulletCount + 1);
        directionVector = Vector2(1, 0).normalized();
        for (int i = 1; i <= bulletCount; i++) {
          startPos = Vector2(-10, spacing * i);
          bullets.add(
            BulletModel.createLinear(
              startPosition: startPos,
              direction: directionVector,
              speed: speed,
              radius: radius,
            ),
          );
        }
        break;
    }

    return bullets;
  }

  // 현재 모델을 복사하여 새로운 인스턴스를 만드는 메서드
  BulletModel copyWith({
    Vector2? startPosition,
    Vector2? direction,
    double? speed,
    double? radius,
    BulletType? type,
  }) {
    return BulletModel(
      startPosition: startPosition ?? this.startPosition,
      direction: direction ?? this.direction,
      speed: speed ?? this.speed,
      radius: radius ?? this.radius,
      type: type ?? this.type,
    );
  }
}