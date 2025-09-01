import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/ranking_model.dart';

/// 랭킹 관련 API 서비스 클래스
class RankingService {
  static const String _tableName = 'rankings';
  
  /// 새로운 랭킹 데이터 추가
  static Future<bool> addRanking(RankingModel ranking) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 랭킹 추가 건너뛰기');
      }
      return false;
    }

    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(ranking.toInsertJson())
          .select();
      
      if (kDebugMode) {
        print('✅ 랭킹 추가 성공: ${ranking.playerName} (${ranking.survivalTime}s)');
      }
      
      return response.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 랭킹 추가 실패: $e');
      }
      return false;
    }
  }
  
  /// 상위 N명의 랭킹 조회 (플레이어당 최고 기록만)
  static Future<List<RankingModel>> getTopRankings({int limit = 10}) async {
    // 클라이언트 사이드 필터링 사용 (안정적)
    return await _getTopRankingsFallback(limit: limit);
  }
  
  /// 대체 방법: 클라이언트 사이드에서 중복 제거
  static Future<List<RankingModel>> _getTopRankingsFallback({int limit = 10}) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 빈 랭킹 목록 반환');
      }
      return [];
    }

    try {
      // 더 많은 데이터를 가져와서 클라이언트에서 필터링
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('survival_time', ascending: false)
          .limit(limit * 3); // 중복을 고려해 더 많이 가져옴
      
      // 플레이어별 최고 기록만 남기기
      final Map<String, RankingModel> bestRecords = {};
      
      for (final data in response) {
        final ranking = RankingModel.fromJson(data);
        
        if (!bestRecords.containsKey(ranking.playerName) ||
            ranking.survivalTime > bestRecords[ranking.playerName]!.survivalTime) {
          bestRecords[ranking.playerName] = ranking;
        }
      }
      
      // 생존 시간 기준으로 정렬 후 순위 부여
      final sortedRankings = bestRecords.values.toList()
        ..sort((a, b) => b.survivalTime.compareTo(a.survivalTime));
      
      final rankings = <RankingModel>[];
      for (int i = 0; i < sortedRankings.length && i < limit; i++) {
        final data = sortedRankings[i].toJson();
        data['rank'] = i + 1;
        rankings.add(RankingModel.fromJson(data));
      }
      
      return rankings;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 랭킹 조회 실패: $e');
      }
      return [];
    }
  }
  
  /// 특정 플레이어의 최고 기록 조회
  static Future<RankingModel?> getPlayerBestRecord(String playerName) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 플레이어 기록 조회 불가');
      }
      return null;
    }

    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('player_name', playerName)
          .order('survival_time', ascending: false)
          .limit(1);
      
      if (response.isNotEmpty) {
        return RankingModel.fromJson(response.first);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 플레이어 최고 기록 조회 실패: $e');
      }
      return null;
    }
  }
  
  /// 특정 플레이어의 모든 기록 조회
  static Future<List<RankingModel>> getPlayerRecords(String playerName, {int limit = 50}) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 플레이어 기록 조회 불가');
      }
      return [];
    }

    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('player_name', playerName)
          .order('survival_time', ascending: false)
          .limit(limit);
      
      return response.map<RankingModel>((data) => RankingModel.fromJson(data)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 플레이어 기록 조회 실패: $e');
      }
      return [];
    }
  }
  
  /// 내 순위 조회 (플레이어별 최고 기록 기준)
  static Future<int> getMyRank(double survivalTime) async {
    try {
      // 전체 랭킹에서 해당 점수보다 높은 플레이어 수 계산
      final topRankings = await getTopRankings(limit: 1000); // 충분히 많이 가져옴
      
      int rank = 1;
      for (final ranking in topRankings) {
        if (ranking.survivalTime > survivalTime) {
          rank++;
        } else {
          break;
        }
      }
      
      return rank;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 내 순위 조회 실패: $e');
      }
      return 0;
    }
  }

  /// 전체 기록 수 조회
  static Future<int> getTotalRecords() async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 전체 기록 수 조회 불가');
      }
      return 0;
    }

    try {
      final count = await SupabaseConfig.client
          .from(_tableName)
          .count();

      return count;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 전체 기록 수 조회 실패: $e');
      }
      return 0;
    }
  }
  
  /// 등급별 랭킹 조회
  static Future<List<RankingModel>> getRankingsByGrade(String grade, {int limit = 10}) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 등급별 랭킹 조회 불가');
      }
      return [];
    }

    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('grade', grade.toUpperCase())
          .order('survival_time', ascending: false)
          .limit(limit);
      
      final rankings = <RankingModel>[];
      for (int i = 0; i < response.length; i++) {
        final data = Map<String, dynamic>.from(response[i]);
        data['rank'] = i + 1;
        rankings.add(RankingModel.fromJson(data));
      }
      
      return rankings;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 등급별 랭킹 조회 실패: $e');
      }
      return [];
    }
  }
  
  /// 오늘의 랭킹 조회 (플레이어당 최고 기록만)
  static Future<List<RankingModel>> getTodayRankings({int limit = 10}) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 오늘 랭킹 조회 불가');
      }
      return [];
    }

    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .gte('created_at', startOfDay.toIso8601String())
          .order('survival_time', ascending: false)
          .limit(limit * 3); // 중복을 고려해 더 많이 가져옴
      
      // 플레이어별 최고 기록만 남기기
      final Map<String, RankingModel> bestRecords = {};
      
      for (final data in response) {
        final ranking = RankingModel.fromJson(data);
        
        if (!bestRecords.containsKey(ranking.playerName) ||
            ranking.survivalTime > bestRecords[ranking.playerName]!.survivalTime) {
          bestRecords[ranking.playerName] = ranking;
        }
      }
      
      // 생존 시간 기준으로 정렬 후 순위 부여
      final sortedRankings = bestRecords.values.toList()
        ..sort((a, b) => b.survivalTime.compareTo(a.survivalTime));
      
      final rankings = <RankingModel>[];
      for (int i = 0; i < sortedRankings.length && i < limit; i++) {
        final data = sortedRankings[i].toJson();
        data['rank'] = i + 1;
        rankings.add(RankingModel.fromJson(data));
      }
      
      return rankings;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 오늘 랭킹 조회 실패: $e');
      }
      return [];
    }
  }
  
  /// 닉네임 중복 검사
  static Future<bool> isNicknameAvailable(String nickname) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 닉네임 중복 검사 불가');
      }
      return true; // 오프라인에서는 사용 가능으로 처리
    }

    try {
      final count = await SupabaseConfig.client
          .from(_tableName)
          .count()
          .eq('player_name', nickname);
      
      return count == 0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 닉네임 중복 검사 실패: $e');
      }
      return false;
    }
  }
  
  /// 최고 기록인지 확인 (기존 기록과 비교)
  static Future<bool> isNewBestRecord(String playerName, double survivalTime) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 신기록 여부 확인 불가');
      }
      return false; // 오프라인 모드에서는 신기록 처리 안함
    }

    try {
      final bestRecord = await getPlayerBestRecord(playerName);
      
      if (bestRecord == null) {
        // 첫 기록이면 최고 기록
        return true;
      }
      
      // 기존 최고 기록보다 높으면 true
      return survivalTime > bestRecord.survivalTime;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 신기록 여부 확인 실패: $e');
      }
      return true; // 에러 시에는 기록 저장 허용
    }
  }
  
  /// 최고 기록일 때만 랭킹 추가
  static Future<bool> addRankingIfBest(RankingModel ranking) async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 랭킹 추가 건너뛰기');
      }
      return false;
    }

    try {
      // 최고 기록인지 먼저 확인
      final isBest = await isNewBestRecord(ranking.playerName, ranking.survivalTime);
      
      if (!isBest) {
        if (kDebugMode) {
          print('ℹ️ 기존 기록이 더 좋음 - 랭킹 추가 건너뜀');
        }
        return false;
      }
      
      // 최고 기록이면 등록
      return await addRanking(ranking);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 최고 기록 랭킹 추가 실패: $e');
      }
      return false;
    }
  }
  
  /// 연결 테스트
  static Future<bool> testConnection() async {
    // Supabase 초기화 확인
    if (!SupabaseConfig.isInitialized) {
      if (kDebugMode) {
        print('⚠️ Supabase 미초기화 - 연결 테스트 불가');
      }
      return false;
    }

    try {
      await SupabaseConfig.client
          .from(_tableName)
          .select('id')
          .limit(1);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Supabase 연결 테스트 실패: $e');
      }
      return false;
    }
  }
}