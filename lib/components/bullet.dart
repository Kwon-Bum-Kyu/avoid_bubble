import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/avoid_bubble_game.dart';

class Bullet extends CircleComponent {
  static const double speed = 150.0;
  late Vector2 velocity;
  
  Bullet({required Vector2 startPosition}) : super(
    radius: 8.0,
    paint: Paint()..color = const Color(0xFF64B5F6).withValues(alpha: 0.8),
  ) {
    position = startPosition;
    velocity = Vector2(0, speed);
  }


  @override
  void update(double dt) {
    super.update(dt);
    
    // Move bullet downward
    position += velocity * dt;
    
    // Remove bullet if it's off-screen
    final game = parent! as AvoidBubbleGame;
    if (position.y > game.size.y + radius) {
      removeFromParent();
    }
  }
}