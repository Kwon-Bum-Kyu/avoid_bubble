import 'package:flutter/foundation.dart';
import '../models/game_stats.dart';
import '../services/stats_service.dart';

class StatsProvider extends ChangeNotifier {
  final StatsService _statsService = StatsService.instance;
  bool _isInitialized = false;

  // 초기화 상태
  bool get isInitialized => _isInitialized;

  // 현재 통계 가져오기
  GameStats get currentStats => _statsService.currentStats;

  // 주요 통계 getter들
  double get bestTime => currentStats.bestTime;
  int get totalGamesPlayed => currentStats.totalGamesPlayed;
  int get totalBulletsAvoided => currentStats.totalBulletsAvoided;
  double get totalPlayTime => currentStats.totalPlayTime;
  Map<String, int> get gradeCount => currentStats.gradeCount;
  double get averagePlayTime => currentStats.averagePlayTime;
  String get mostCommonGrade => currentStats.mostCommonGrade;

  // 초기화
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _statsService.initialize();
      _isInitialized = true;
      notifyListeners();
    }
  }

  // 게임 결과 기록
  Future<void> recordGame(double survivalTime, String grade, int bulletsAvoided) async {
    await _statsService.recordGame(survivalTime, grade, bulletsAvoided);
    notifyListeners();
  }

  // 통계 리셋
  Future<void> resetStats() async {
    await _statsService.resetStats();
    notifyListeners();
  }

  // 특정 등급 카운트 가져오기
  int getGradeCount(String grade) {
    return currentStats.gradeCount[grade] ?? 0;
  }

  // 최고 기록 포맷팅 (분:초)
  String getFormattedBestTime() {
    final minutes = (bestTime / 60).floor();
    final seconds = (bestTime % 60).floor();
    return '$minutes분 $seconds초';
  }

  // 총 플레이 시간 포맷팅
  String getFormattedTotalPlayTime() {
    final hours = (totalPlayTime / 3600).floor();
    final minutes = ((totalPlayTime % 3600) / 60).floor();

    if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }

  // 평균 플레이 시간 포맷팅
  String getFormattedAveragePlayTime() {
    final minutes = (averagePlayTime / 60).floor();
    final seconds = (averagePlayTime % 60).floor();
    return '$minutes분 $seconds초';
  }

  // 등급별 통계 요약
  Map<String, dynamic> getGradeSummary() {
    return {
      'total': totalGamesPlayed,
      'grades': Map<String, int>.from(gradeCount),
      'mostCommon': mostCommonGrade,
    };
  }

  // 진행률 계산 (S등급까지 도달하기 위한)
  double getProgressToSRank() {
    if (bestTime >= 300.0) return 1.0; // 이미 S등급
    return (bestTime / 300.0).clamp(0.0, 1.0);
  }

  // 다음 등급까지 필요한 시간 계산
  String getTimeToNextGrade() {
    if (bestTime >= 300.0) return '목표 달성!';

    double targetTime;
    String targetGrade;

    if (bestTime < 50.0) {
      targetTime = 50.0;
      targetGrade = 'D';
    } else if (bestTime < 100.0) {
      targetTime = 100.0;
      targetGrade = 'C';
    } else if (bestTime < 150.0) {
      targetTime = 150.0;
      targetGrade = 'B';
    } else if (bestTime < 200.0) {
      targetTime = 200.0;
      targetGrade = 'A';
    } else {
      targetTime = 300.0;
      targetGrade = 'S';
    }

    final needed = targetTime - bestTime;
    final minutes = (needed / 60).floor();
    final seconds = (needed % 60).floor();

    return '$targetGrade등급까지 $minutes분 $seconds초';
  }

  // 통계 업데이트 (외부에서 직접 업데이트)
  Future<void> updateStats(GameStats newStats) async {
    await _statsService.saveStats(newStats);
    notifyListeners();
  }
}