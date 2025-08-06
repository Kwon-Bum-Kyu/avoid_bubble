import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/avoid_bubble_game.dart';

class Bullet extends CircleComponent {
  static const double speed = 80.0; // 더 느리게 해서 확실히 보이게
  late Vector2 velocity;

  Bullet({required Vector2 startPosition, required Vector2 direction})
    : super(
        radius: 30.0, // 훨씬 크게 만들어서 확실히 보이게
        paint: Paint()..color = const Color(0xFFFF0000), // 밝은 순수 빨간색
      ) {
    position = startPosition;
    
    // 0벡터가 아닐 때만 정규화
    if (direction.length > 0) {
      velocity = direction.normalized() * speed;
    } else {
      velocity = Vector2.zero(); // 정지된 불렛
    }
    
    print('🔴 BULLET CREATED: pos=$position, vel=$velocity, radius=$radius, speed=$speed');
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    print('🎯 BULLET LOADED: pos=$position, size=${size.toString()}, visible=true');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Removed excessive logging
  }

  @override
  void update(double dt) {
    super.update(dt);

    final oldPosition = Vector2.copy(position);
    // Move bullet in its direction (직선 이동)
    position += velocity * dt;

    // 총알이 화면 안에 있는지 확인
    final game = parent! as AvoidBubbleGame;

    // Debug: 패턴 3 총알(수직 이동)의 위치 추적
    if (velocity.x == 0 && velocity.y != 0) {
      if (game.survivalTime % 2.0 < 0.1) {
        print('⬆️  Pattern 3 bullet: pos=$position, vel=$velocity');
      }
    }

    // Remove bullet if it's off-screen (any direction)
    final isOffScreen = position.x < -radius || 
                       position.x > game.size.x + radius ||
                       position.y < -radius || 
                       position.y > game.size.y + radius;
                       
    if (isOffScreen) {
      print('🗑️  Bullet removed at pos=$position (was at $oldPosition), screen size: ${game.size}');
      removeFromParent();
      return; // 즉시 리턴하여 다른 로직 실행 방지
    }
    
    // 추가 안전 장치: 화면에서 너무 멀리 벗어난 경우
    if (position.x.abs() > 5000 || position.y.abs() > 5000) {
      print('⚠️  Bullet at extreme position $position - force removing!');
      removeFromParent();
      return;
    }
  }
}
