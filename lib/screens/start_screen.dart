import 'package:flutter/material.dart';
import '../models/game_stats.dart';

class StartScreen extends StatelessWidget {
  final VoidCallback onStartGame;
  final VoidCallback onShowSettings;
  final VoidCallback onShowRanking;
  final GameStats stats;

  const StartScreen({
    super.key,
    required this.onStartGame,
    required this.onShowSettings,
    required this.onShowRanking,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompactHeight = screenHeight < 500; // 모바일 가로 모드 감지
    
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header with settings button (컴팩트 모드에서 패딩 감소)
            Padding(
              padding: EdgeInsets.all(isCompactHeight ? 10.0 : 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: onShowSettings,
                    icon: const Icon(Icons.settings, color: Colors.white),
                    iconSize: isCompactHeight ? 24 : 30,
                  ),
                ],
              ),
            ),

            // Main content (스크롤 가능하게 변경)
            Expanded(
              child: isCompactHeight 
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildMainContent(isCompactHeight),
                    ),
                  )
                : Center(
                    child: _buildMainContent(isCompactHeight),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isCompactHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '어보이드 버블',
          style: TextStyle(
            fontSize: isCompactHeight ? 32 : 48, // 컴팩트 모드에서 폰트 크기 감소
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [
              Shadow(
                offset: Offset(2, 2),
                blurRadius: 4,
                color: Color.fromARGB(128, 0, 0, 0),
              ),
            ],
          ),
        ),
        SizedBox(height: isCompactHeight ? 10 : 20), // 컴팩트 모드에서 간격 감소
        const Text(
          '탄막을 피해 최대한 오래 생존하세요!',
          style: TextStyle(fontSize: 18, color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isCompactHeight ? 20 : 40),

        // Stats display
        if (stats.totalGamesPlayed > 0)
          Container(
            margin: EdgeInsets.only(bottom: isCompactHeight ? 15 : 30),
            padding: EdgeInsets.all(isCompactHeight ? 15 : 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'Best Time: ${stats.bestTime.toStringAsFixed(1)}s',
                  style: TextStyle(
                    fontSize: isCompactHeight ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Games Played: ${stats.totalGamesPlayed}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  'Most Common Grade: ${stats.mostCommonGrade}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

        ElevatedButton(
          onPressed: onStartGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isCompactHeight ? 30 : 40,
              vertical: isCompactHeight ? 12 : 15,
            ),
            textStyle: TextStyle(
              fontSize: isCompactHeight ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('게임 시작'),
        ),
        SizedBox(height: isCompactHeight ? 8 : 10),
        ElevatedButton(
          onPressed: onShowRanking,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isCompactHeight ? 30 : 40,
              vertical: isCompactHeight ? 12 : 15,
            ),
            textStyle: TextStyle(
              fontSize: isCompactHeight ? 20 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('랭킹 보기'),
        ),
        SizedBox(height: isCompactHeight ? 15 : 20),
        const Text(
          '조작법: WASD 또는 방향키로 이동',
          style: TextStyle(fontSize: 14, color: Colors.white60),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
