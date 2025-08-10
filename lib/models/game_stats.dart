// 게임 통계를 관리하는 클래스
class GameStats {
  double bestTime; // 최고 생존 시간
  int totalGamesPlayed; // 총 플레이 횟수
  int totalBulletsAvoided; // 총 피한 총알 수
  double totalPlayTime; // 총 플레이 시간
  Map<String, int> gradeCount; // 등급별 횟수
  
  // 생성자
  GameStats({
    this.bestTime = 0.0,
    this.totalGamesPlayed = 0,
    this.totalBulletsAvoided = 0,
    this.totalPlayTime = 0.0,
    Map<String, int>? gradeCount,
  }) : gradeCount = gradeCount ?? {
    'S': 0,
    'A': 0,
    'B': 0,
    'C': 0,
    'D': 0,
    'F': 0,
  };

  // 게임 결과를 기록
  void recordGame(double survivalTime, String grade, int bulletsAvoided) {
    if (survivalTime > bestTime) {
      bestTime = survivalTime;
    }
    
    totalGamesPlayed++;
    totalBulletsAvoided += bulletsAvoided;
    totalPlayTime += survivalTime;
    
    gradeCount[grade] = (gradeCount[grade] ?? 0) + 1;
  }

  // 평균 플레이 시간 getter
  double get averagePlayTime => totalGamesPlayed > 0 ? totalPlayTime / totalGamesPlayed : 0.0;
  
  // 가장 많이 받은 등급 getter
  String get mostCommonGrade {
    if (gradeCount.isEmpty) return 'F';
    
    String mostCommon = 'F';
    int maxCount = 0;
    
    gradeCount.forEach((grade, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = grade;
      }
    });
    
    return mostCommon;
  }

  // 현재 통계를 복사하여 새로운 인스턴스를 만드는 메서드
  GameStats copyWith({
    double? bestTime,
    int? totalGamesPlayed,
    int? totalBulletsAvoided,
    double? totalPlayTime,
    Map<String, int>? gradeCount,
  }) {
    return GameStats(
      bestTime: bestTime ?? this.bestTime,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalBulletsAvoided: totalBulletsAvoided ?? this.totalBulletsAvoided,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      gradeCount: gradeCount ?? Map<String, int>.from(this.gradeCount),
    );
  }

  // 통계 리셋
  void reset() {
    bestTime = 0.0;
    totalGamesPlayed = 0;
    totalBulletsAvoided = 0;
    totalPlayTime = 0.0;
    gradeCount = {
      'S': 0,
      'A': 0,
      'B': 0,
      'C': 0,
      'D': 0,
      'F': 0,
    };
  }
}
