import 'package:flame/components.dart';
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
      radius: 24.0, // 모델의 충돌 반경을 24로 고정
      type: type,
    );
    // 모델의 위치와 크기를 기반으로 컴포넌트의 위치와 크기를 설정
    position = model.position;
    size = Vector2.all(model.radius * 2); // 스프라이트 크기를 모델 반경의 2배로 설정
    anchor = Anchor.center; // 앵커를 중심으로 설정
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

  // 충돌 감지를 위한 총알의 반지름 getter
  double get radius => size.x / 2;
}
