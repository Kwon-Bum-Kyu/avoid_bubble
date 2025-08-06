import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  final VoidCallback onStartGame;

  const StartScreen({super.key, required this.onStartGame});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1E)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Game Title
            const Text(
              'AVOID BUBBLE',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Color(0xFF4FC3F7),
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Subtitle
            const Text(
              '탄막 서바이벌 게임',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 60),

            // Game instructions
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    '게임 방법',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4FC3F7),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    '• WASD 또는 방향키로 이동\n'
                    '• 화면을 터치해서도 이동 가능\n'
                    '• 물방울 탄막을 피하세요\n'
                    '• 최대한 오래 생존하세요!\n'
                    '• 게임 오버 후 R키로 재시작',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Start button
            ElevatedButton(
              onPressed: onStartGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 10,
                shadowColor: const Color(0xFF4FC3F7).withValues(alpha: 0.5),
              ),
              child: const Text(
                '게임 시작',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Version info
            const Text(
              'v1.0 - Flame Engine',
              style: TextStyle(fontSize: 12, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}
