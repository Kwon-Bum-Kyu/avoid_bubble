import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/avoid_bubble_game.dart';
import '../models/player_model.dart';
import 'bullet.dart';

// Player 클래스는 SpriteAnimationComponent를 상속받아 애니메이션을 처리합니다.
class Player extends SpriteAnimationComponent
    with HasGameReference<AvoidBubbleGame> {
  // 플레이어의 데이터와 로직을 관리하는 모델
  late PlayerModel model;
  // 걷기, 멈춤 애니메이션
  late SpriteAnimation _walkAnimation;
  late SpriteAnimation _idleAnimation;

  // 생성자: 플레이어의 속도와 크기를 초기화합니다.
  Player({double speed = 200.0, double collisionRadius = 10.0}) {
    model = PlayerModel(
      speed: speed,
      size: Vector2(48, 48), // 스프라이트 크기 (시각적)
      collisionRadius: collisionRadius, // 충돌 범위 (실제 판정) - 설정에서 조정 가능
    );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 스프라이트 시트 이미지 로드
    final spriteImage = await game.images.load('fire_char_walk.png');

    // 걷기 애니메이션 데이터 생성
    final walkData = SpriteAnimationData.sequenced(
      amount: 8,
      stepTime: 0.08,
      textureSize: Vector2(24, 24), // 각 프레임의 텍스처 크기
    );
    _walkAnimation = SpriteAnimation.fromFrameData(spriteImage, walkData);

    // 정지 상태 애니메이션 데이터 생성 첫 번째 프레임만 사용
    final idleData = SpriteAnimationData.sequenced(
      amount: 1, // 1개의 프레임
      stepTime: 1, // 단일 프레임이므로 의미 없음
      textureSize: Vector2(24, 24),
    );
    _idleAnimation = SpriteAnimation.fromFrameData(spriteImage, idleData);

    // 초기 애니메이션은 정지 상태로 설정
    animation = _idleAnimation;

    // 컴포넌트의 크기와 위치 설정
    size = model.size;
    model.resetToCenter(game.size);
    position = model.position;
    anchor = Anchor.center; // 앵커를 중심으로 설정하여 위치를 정확하게 맞춤
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 모델의 위치를 업데이트하고 컴포넌트 위치와 동기화
    model.updatePosition(dt, game.size);
    position = model.position;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 히트박스 표시 옵션이 활성화된 경우 충돌 범위를 시각화
    if (game.settings.showHitboxes) {
      _renderHitbox(canvas);
    }
  }

  void _renderHitbox(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.x / 2 + 5, size.y / 2 + 5);
    final radius = model.radius;

    // 충돌 범위 원을 그림 (반투명 채우기 + 테두리)
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, strokePaint);

    // 중심점 표시
    final centerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.0, centerPaint);
  }

  // 외부에서 플레이어의 움직임을 설정하는 메서드
  void setMovement(double x, double y) {
    model.setMovement(x, y);
    // 움직임 여부에 따라 애니메이션을 변경
    if (x != 0 || y != 0) {
      animation = _walkAnimation; // 움직이면 걷기 애니메이션
    } else {
      animation = _idleAnimation; // 멈추면 정지 애니메이션
    }
  }

  // 플레이어를 화면 중앙으로 리셋
  void resetToCenter() {
    model.resetToCenter(game.size);
    position = model.position;
  }

  // 플레이어의 중심 좌표와 반지름 getter
  Vector2 get playerCenter => position;
  double get playerRadius => model.radius; // 모델의 충돌 반지름 사용

  // 총알과의 충돌을 확인하는 로직
  void checkCollisions() {
    final bullets = game.children.whereType<Bullet>();

    // 무적 모드
    if (game.isInvincible) {
      for (final bullet in bullets) {
        // 충돌한 총알을 제거
        if (position.distanceTo(bullet.position) <
            playerRadius + bullet.radius) {
          bullet.removeFromParent();
        }
      }
    } else {
      // 무적 모드 X
      for (final bullet in bullets) {
        if (position.distanceTo(bullet.position) <
            playerRadius + bullet.radius) {
          game.gameOver();
          break;
        }
      }
    }
  }
}
