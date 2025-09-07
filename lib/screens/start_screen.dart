import 'package:flutter/material.dart';
import '../models/game_stats.dart';
import '../services/localization_service.dart';

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
                        child:
                            _buildMainContent(context, isCompactHeight),
                      ),
                    )
                  : Center(
                      child: _buildMainContent(context, isCompactHeight),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, bool isCompactHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocalizationService.getText('start_title'),
          style: TextStyle(
            fontSize: isCompactHeight ? 32 : 48, // 컴팩트 모드에서 폰트 크기 감소
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none, // 밑줄 명시적 제거
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
        Text(
          LocalizationService.getText('start_subtitle'),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
            decoration: TextDecoration.none, // 밑줄 제거
          ),
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
                  LocalizationService.getFormattedText('start_best_time', [stats.bestTime.toStringAsFixed(1)]),
                  style: TextStyle(
                    fontSize: isCompactHeight ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                    decoration: TextDecoration.none, // 밑줄 제거
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  LocalizationService.getFormattedText('start_games_played', [stats.totalGamesPlayed]),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    decoration: TextDecoration.none, // 밑줄 제거
                  ),
                ),
                Text(
                  LocalizationService.getFormattedText('start_most_common_grade', [stats.mostCommonGrade]),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    decoration: TextDecoration.none, // 밑줄 제거
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            LocalizationService.getText('start_game'),
            style:
                const TextStyle(decoration: TextDecoration.none), // 명시적으로 밑줄 제거
          ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            LocalizationService.getText('start_view_ranking'),
            style:
                const TextStyle(decoration: TextDecoration.none), // 명시적으로 밑줄 제거
          ),
        ),
        SizedBox(height: isCompactHeight ? 15 : 20),
        Text(
          LocalizationService.getText('start_controls'),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white60,
            decoration: TextDecoration.none, // 밑줄 제거
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
