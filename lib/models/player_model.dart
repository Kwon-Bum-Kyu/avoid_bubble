import 'package:flame/components.dart';

// 플레이어의 데이터와 상태를 관리하는 모델 클래스
class PlayerModel {
  final double speed; // 플레이어 속도
  final Vector2 size; // 플레이어 크기 (시각적 크기)
  final double collisionRadius; // 충돌 범위 반지름 (실제 충돌 판정 크기)
  final Vector2 initialPosition; // 초기 위치
  Vector2 position; // 현재 위치
  Vector2 velocity; // 현재 속도 (방향과 빠르기)
  
  // 생성자
  PlayerModel({
    this.speed = 200.0,
    Vector2? size,
    double? collisionRadius,
    Vector2? initialPosition,
  }) : size = size ?? Vector2(40, 40),
       collisionRadius = collisionRadius ?? 12.0, // 기본값: 스프라이트 크기의 절반보다 작게
       initialPosition = initialPosition ?? Vector2.zero(),
       position = initialPosition ?? Vector2.zero(),
       velocity = Vector2.zero();

  // 매 프레임마다 위치를 업데이트
  void updatePosition(double dt, Vector2 screenSize) {
    // 속도를 적용하여 위치 변경
    position += velocity * dt;
    
    // 플레이어가 화면 밖으로 나가지 않도록 제한
    // position은 플레이어의 중심이므로, 반지름을 고려하여 경계를 설정합니다.
    position.x = position.x.clamp(radius, screenSize.x - radius);
    position.y = position.y.clamp(radius, screenSize.y - radius);
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
      (screenSize.x / 2) - (size.x / 2),
      (screenSize.y / 2) - (size.y / 2),
    );
    velocity.setZero();
  }

  // 플레이어의 중심 좌표 getter
  Vector2 get center {
    return Vector2(
      position.x + size.x / 2,
      position.y + size.y / 2,
    );
  }

  // 플레이어의 충돌 반경 getter (별도로 설정된 충돌 범위 사용)
  double get radius => collisionRadius;

  // 현재 모델을 복사하여 새로운 인스턴스를 만드는 메서드
  PlayerModel copyWith({
    double? speed,
    Vector2? size,
    double? collisionRadius,
    Vector2? initialPosition,
    Vector2? position,
    Vector2? velocity,
  }) {
    final newModel = PlayerModel(
      speed: speed ?? this.speed,
      size: size ?? this.size,
      collisionRadius: collisionRadius ?? this.collisionRadius,
      initialPosition: initialPosition ?? this.initialPosition,
    );
    newModel.position = position ?? this.position.clone();
    newModel.velocity = velocity ?? this.velocity.clone();
    return newModel;
  }
}
