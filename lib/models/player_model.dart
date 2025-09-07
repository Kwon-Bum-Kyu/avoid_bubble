import 'package:avoid_bubble/config/game_constants.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

// 캐릭터 스킨 정의 (1440x720 기준)
enum CharacterSkin {
  fireChar('fire_char_walk.png', 48.0, 48.0, 24.0, 24.0, 10.0),
  // 향후 추가할 스킨들
  // iceChar('ice_char_walk.png', 52.0, 52.0, 26.0, 26.0, 13.0),
  // windChar('wind_char_walk.png', 44.0, 44.0, 22.0, 22.0, 11.0),
  ;

  const CharacterSkin(
      this.spriteSheet,
      this.baseRenderSizeX,
      this.baseRenderSizeY,
      this.baseTextureSizeX,
      this.baseTextureSizeY,
      this.baseCollisionRadius);

  final String spriteSheet; // 스프라이트 시트 파일명
  final double baseRenderSizeX, baseRenderSizeY; // 기준 렌더링 크기 (1440x720 기준)
  final double baseTextureSizeX, baseTextureSizeY; // 기준 텍스처 크기
  final double baseCollisionRadius; // 기준 충돌 반지름

  // 스케일링된 크기 계산
  Vector2 getScaledRenderSize(Vector2 screenSize) {
    final scale = _calculateScale(screenSize);
    final scaledX = baseRenderSizeX * scale;
    final scaledY = baseRenderSizeY * scale;
    // 최소 32px로 제한
    final result =
        Vector2(scaledX.clamp(36.0, 48.0), scaledY.clamp(36.0, 48.0));
    debugPrint('player size ${result.x} x ${result.y} (scale: $scale)');
    return result;
  }

  Vector2 getScaledTextureSize(Vector2 screenSize) {
    // 텍스쳐 사이즈는 유지
    return Vector2(baseTextureSizeX, baseTextureSizeY);
  }

  double getScaledCollisionRadius(Vector2 screenSize) {
    final scale = _calculateScale(screenSize);
    final scaledRadius = baseCollisionRadius * scale;
    return scaledRadius.clamp(7.5, 10.0); // 7.5px~10px 사이로 제한
  }

  // 화면 크기에 따른 스케일 계산 (1440x720 기준)
  double _calculateScale(Vector2 screenSize) {
    const baseWidth = 1440.0;
    const baseHeight = 720.0;

    final scaleX = screenSize.x / baseWidth;
    final scaleY = screenSize.y / baseHeight;
    return (scaleX + scaleY) / 2; // 평균 스케일 사용
  }

  // 기본 getter들 (호환성 유지)
  Vector2 get renderSize => Vector2(baseRenderSizeX, baseRenderSizeY);
  Vector2 get textureSize => Vector2(baseTextureSizeX, baseTextureSizeY);
}

// 플레이어의 데이터와 상태를 관리하는 모델 클래스
class PlayerModel {
  final double speed; // 플레이어 속도
  final CharacterSkin skin; // 캐릭터 스킨
  final Vector2 initialPosition; // 초기 위치
  Vector2 position; // 현재 위치
  Vector2 velocity; // 현재 속도 (방향과 빠르기)
  Vector2 _screenSize = Vector2.zero(); // 현재 화면 크기

  // 생성자
  PlayerModel({
    this.speed = GameConstants.playerSpeed,
    this.skin = CharacterSkin.fireChar,
    Vector2? initialPosition,
  })  : initialPosition = initialPosition ?? Vector2.zero(),
        position = initialPosition ?? Vector2.zero(),
        velocity = Vector2.zero();

  // 화면 크기 설정
  void setScreenSize(Vector2 screenSize) {
    _screenSize = screenSize;
  }

  // 스케일링된 렌더 크기 getter
  Vector2 get renderSize => _screenSize != Vector2.zero()
      ? skin.getScaledRenderSize(_screenSize)
      : skin.renderSize;

  // 스케일링된 텍스처 크기 getter
  Vector2 get textureSize => _screenSize != Vector2.zero()
      ? skin.getScaledTextureSize(_screenSize)
      : skin.textureSize;

  // 스케일링된 충돌 반지름 getter
  double get collisionRadius => _screenSize != Vector2.zero()
      ? skin.getScaledCollisionRadius(_screenSize)
      : skin.baseCollisionRadius;

  // 매 프레임마다 위치를 업데이트
  void updatePosition(double dt, Vector2 screenSize) {
    // 속도를 적용하여 위치 변경
    position += velocity * dt;

    // 플레이어가 화면 밖으로 나가지 않도록 제한
    // position은 플레이어의 중심이므로, 반지름을 고려하여 경계를 설정합니다.
    position.x =
        position.x.clamp(collisionRadius, screenSize.x - collisionRadius);
    position.y =
        position.y.clamp(collisionRadius, screenSize.y - collisionRadius);
  }

  // 움직임 방향 설정
  void setMovement(double x, double y) {
    velocity.setValues(x * speed, y * speed);
  }

  // 움직임 정지
  void stopMovement() {
    velocity.setZero();
  }

  // 플레이어를 화면 중앙으로 리셋
  void resetToCenter(Vector2 screenSize) {
    position = Vector2(
      (screenSize.x / 2) - (renderSize.x / 2),
      (screenSize.y / 2) - (renderSize.y / 2),
    );
    velocity.setZero();
  }

  // 플레이어의 중심 좌표 getter
  Vector2 get center {
    return Vector2(
      position.x + renderSize.x / 2,
      position.y + renderSize.y / 2,
    );
  }

  // 스킨별 속성 접근자들
  String get spriteSheet => skin.spriteSheet;

  // 플레이어의 충돌 반경 getter (스킨별 충돌 범위 사용)
  double get radius => collisionRadius;

  // 현재 모델을 복사하여 새로운 인스턴스를 만드는 메서드
  PlayerModel copyWith({
    double? speed,
    CharacterSkin? skin,
    Vector2? initialPosition,
    Vector2? position,
    Vector2? velocity,
  }) {
    final newModel = PlayerModel(
      speed: speed ?? this.speed,
      skin: skin ?? this.skin,
      initialPosition: initialPosition ?? this.initialPosition,
    );
    newModel.position = position ?? this.position.clone();
    newModel.velocity = velocity ?? this.velocity.clone();
    return newModel;
  }

  // 캐릭터 스킨 변경
  PlayerModel changeSkin(CharacterSkin newSkin) {
    return copyWith(skin: newSkin);
  }
}
