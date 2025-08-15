/// 랭킹 데이터 모델 클래스
class RankingModel {
  final int? id;
  final String playerName;
  final double survivalTime;
  final String grade;
  final DateTime? createdAt;
  final int rank; // 순위 (조회 시에만 사용)

  const RankingModel({
    this.id,
    required this.playerName,
    required this.survivalTime,
    required this.grade,
    this.createdAt,
    this.rank = 0,
  });

  /// JSON에서 RankingModel 생성
  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      id: json['id'] as int?,
      playerName: json['player_name'] as String,
      survivalTime: (json['survival_time'] as num).toDouble(),
      grade: json['grade'] as String,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      rank: json['rank'] as int? ?? 0,
    );
  }

  /// RankingModel을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_name': playerName,
      'survival_time': survivalTime,
      'grade': grade,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// 삽입용 JSON (id와 created_at 제외)
  Map<String, dynamic> toInsertJson() {
    return {
      'player_name': playerName,
      'survival_time': survivalTime,
      'grade': grade,
    };
  }

  /// 점수 계산 (생존 시간 기반)
  int get score => (survivalTime * 100).round();

  /// 등급별 색상 (UI에서 사용)
  String get gradeColor {
    switch (grade.toUpperCase()) {
      case 'S':
        return '#FFD700'; // 금색
      case 'A':
        return '#C0C0C0'; // 은색
      case 'B':
        return '#CD7F32'; // 동색
      case 'C':
        return '#4169E1'; // 파란색
      case 'D':
        return '#32CD32'; // 초록색
      case 'F':
      default:
        return '#808080'; // 회색
    }
  }

  /// 등급별 이모지
  String get gradeEmoji {
    switch (grade.toUpperCase()) {
      case 'S':
        return '🏆';
      case 'A':
        return '🥈';
      case 'B':
        return '🥉';
      case 'C':
        return '📋';
      case 'D':
        return '📝';
      case 'F':
      default:
        return '❌';
    }
  }

  /// 순위별 메달 이모지
  String get rankEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏃';
    }
  }

  @override
  String toString() {
    return 'RankingModel{id: $id, playerName: $playerName, survivalTime: $survivalTime, grade: $grade, rank: $rank}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RankingModel &&
        other.id == id &&
        other.playerName == playerName &&
        other.survivalTime == survivalTime &&
        other.grade == grade;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        playerName.hashCode ^
        survivalTime.hashCode ^
        grade.hashCode;
  }
}