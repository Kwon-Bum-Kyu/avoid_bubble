import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/avoid_bubble_game.dart';
import '../models/bullet_model.dart';

class Bullet extends SpriteComponent with HasGameReference<AvoidBubbleGame> {
  late BulletModel model;

  // 총알의 시작 위치, 방향, 속도, 타입(패턴)
  Bullet({
    required Vector2 startPosition,
    required Vector2 direction,
    required double speed,
    BulletType type = BulletType.targeted,
  }) {
    model = BulletModel(
      startPosition: startPosition,
      direction: direction,
      speed: speed,
      radius: 24.0, // 총알 충돌 반지름 고정값
      type: type,
    );
    // 모델의 위치와 크기를 기반으로 컴포넌트의 위치와 크기를 설정
    position = model.position;
    size = Vector2.all(model.radius * 2); // 스프라이트 크기를 모델 반경의 2배로 설정
    anchor = Anchor.center; // 앵커를 중심으로 설정
    priority = 1; // 우선순위 설정
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 총알 스프라이트 이미지 로드
    sprite = await game.loadSprite('bullet.png');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 모델의 위치를 업데이트하고 컴포넌트 위치와 동기화
    model.updatePosition(dt);
    position = model.position;

    // 모델의 로직에 따라 화면을 벗어났는지 확인하고 제거
    if (model.shouldRemove(game.size, game.player.position)) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 히트박스 표시 옵션이 활성화된 경우 충돌 범위를 시각화
    if (game.shouldShowHitboxes) {
      _renderHitbox(canvas);
    }
  }

  void _renderHitbox(Canvas canvas) {
    // 모든 총알 타입을 빨간색으로 통일
    Color hitboxColor = Colors.red;

    final paint = Paint()
      ..color = hitboxColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = hitboxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 앵커가 center
    final center = Offset(size.x / 2, size.y / 2);
    // 실제 충돌 반지름 사용 (이미 모델에서 조정됨)
    final radius = model.radius - 5;

    // 충돌 범위 원을 그림 (반투명 채우기 + 테두리)
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, strokePaint);

    // 중심점 표시
    final centerPaint = Paint()
      ..color = hitboxColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.0, centerPaint);
  }

  // 충돌 감지를 위한 총알의 반지름 getter
  double get radius => size.x / 2;
}
