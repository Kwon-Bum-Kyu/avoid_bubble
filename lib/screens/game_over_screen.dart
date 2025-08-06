import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final double survivalTime;
  final VoidCallback onRestart;
  final VoidCallback onBackToMenu;

  const GameOverScreen({
    super.key,
    required this.survivalTime,
    required this.onRestart,
    required this.onBackToMenu,
  });

  String _formatTime(double time) {
    return time.toStringAsFixed(1);
  }

  String _getScoreGrade(double time) {
    if (time >= 60) return 'S';
    if (time >= 45) return 'A';
    if (time >= 30) return 'B';
    if (time >= 15) return 'C';
    if (time >= 5) return 'D';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S': return const Color(0xFFFFD700); // Gold
      case 'A': return const Color(0xFF32CD32); // Lime Green
      case 'B': return const Color(0xFF1E90FF); // Dodger Blue
      case 'C': return const Color(0xFFFF8C00); // Dark Orange
      case 'D': return const Color(0xFFDC143C); // Crimson
      case 'F': return const Color(0xFF808080); // Gray
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grade = _getScoreGrade(survivalTime);
    final gradeColor = _getGradeColor(grade);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF0F0F1E),
          ],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDC143C).withValues(alpha: 0.6),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFDC143C).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Game Over Title
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC143C),
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Color(0xFFDC143C),
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Grade Display
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: gradeColor,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    grade,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: gradeColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Survival Time
              Text(
                '생존 시간',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              
              const SizedBox(height: 5),
              
              Text(
                '${_formatTime(survivalTime)}초',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4FC3F7),
                ),
              ),

              const SizedBox(height: 30),

              // Performance Message
              Text(
                _getPerformanceMessage(survivalTime),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Restart Button
                  ElevatedButton.icon(
                    onPressed: onRestart,
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시작'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FC3F7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  // Menu Button
                  ElevatedButton.icon(
                    onPressed: onBackToMenu,
                    icon: const Icon(Icons.home),
                    label: const Text('메뉴'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Keyboard Instructions
              Text(
                'R: 다시 시작 | ESC: 메뉴',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPerformanceMessage(double time) {
    if (time >= 60) return '놀라운 실력입니다! 마스터급!';
    if (time >= 45) return '훌륭한 생존 실력을 보여주셨습니다!';
    if (time >= 30) return '좋은 실력입니다! 조금 더 도전해보세요!';
    if (time >= 15) return '괜찮은 시작입니다! 더 연습해보세요!';
    if (time >= 5) return '연습이 필요합니다. 포기하지 마세요!';
    return '다시 도전해보세요! 연습하면 늘어날 거예요!';
  }
}