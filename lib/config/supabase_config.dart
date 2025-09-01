import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment_config.dart';

/// Supabase 설정 및 초기화를 관리하는 클래스
class SupabaseConfig {
  static SupabaseClient? _client;

  /// Supabase 초기화 여부 확인
  static bool get isInitialized => _client != null;

  /// Supabase 클라이언트 인스턴스 (안전한 접근)
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseConfig.initialize() first.',
      );
    }
    return _client!;
  }

  /// 안전한 Supabase 클라이언트 접근 (null 반환 가능)
  static SupabaseClient? get safeClient => _client;

  /// Supabase 초기화 (환경 설정 기반)
  static Future<void> initialize() async {
    // 이미 초기화된 경우 건너뛰기
    if (_client != null) {
      if (!kReleaseMode) debugPrint('✅ Supabase 이미 초기화됨');
      return;
    }

    final supabaseUrl = EnvironmentConfig.supabaseUrl;
    final supabaseAnonKey = EnvironmentConfig.supabaseAnonKey;

    if (!kReleaseMode) {
      debugPrint('🔧 SupabaseConfig.initialize() 시작');
      debugPrint('   - URL: ${supabaseUrl != null ? "${supabaseUrl.substring(0, 30)}..." : "null"}');
      debugPrint('   - Key: ${supabaseAnonKey != null ? "${supabaseAnonKey.substring(0, 20)}..." : "null"}');
    }

    if (supabaseUrl == null || supabaseAnonKey == null) {
      final errorMessage = 'Supabase URL or ANON KEY not found in environment config';
      if (!kReleaseMode) debugPrint('❌ SupabaseConfig 오류: $errorMessage');
      throw Exception(errorMessage);
    }

    if (supabaseUrl.contains('your-project') ||
        supabaseAnonKey.contains('your_') ||
        supabaseUrl.contains('your-production-project')) {
      final errorMessage = 'Please update SUPABASE_URL and SUPABASE_ANON_KEY in environment files';
      if (!kReleaseMode) debugPrint('❌ SupabaseConfig 오류: $errorMessage');
      throw Exception(errorMessage);
    }

    try {
      if (!kReleaseMode) debugPrint('🔌 Supabase.initialize() 호출...');
      
      // Supabase 초기화 시도 (중복 초기화 오류를 catch로 처리)
      try {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
          debug: EnvironmentConfig.showDebugInfo, // 환경에 따라 디버그 모드 설정
        );
      } catch (e) {
        if (!kReleaseMode) {
          debugPrint('🔍 Supabase.initialize() 오류 상세: $e');
          debugPrint('🔍 오류 타입: ${e.runtimeType}');
        }
        
        // 다양한 중복 초기화 오류 패턴 확인
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('notinitializederror') || 
            errorStr.contains('already') ||
            errorStr.contains('initialized') ||
            e.runtimeType.toString().contains('NotInitializedError')) {
          if (!kReleaseMode) debugPrint('⚠️ Supabase 이미 초기화됨');
          // 기존 인스턴스 사용
        } else {
          if (!kReleaseMode) debugPrint('❌ 예상하지 못한 Supabase 초기화 오류: $e');
          // 다른 오류면 재발생
          rethrow;
        }
      }
      
      _client = Supabase.instance.client;
      
      if (!kReleaseMode) debugPrint('✅ Supabase 클라이언트 생성 완료');
      
      // 연결 테스트
      if (!kReleaseMode) debugPrint('🔍 연결 테스트 시작...');
      final connectionOk = await checkConnection();
      if (!kReleaseMode) {
        if (connectionOk) {
          debugPrint('✅ Supabase 연결 테스트 성공');
        } else {
          debugPrint('⚠️ Supabase 연결 테스트 실패 (네트워크 오류일 수 있음)');
        }
      }
      
    } catch (e) {
      if (!kReleaseMode) debugPrint('❌ SupabaseConfig 초기화 실패: $e');
      rethrow;
    }
  }

  /// 연결 상태 확인
  static Future<bool> checkConnection() async {
    try {
      if (_client == null) return false;
      
      await _client!.from('rankings').select('id').limit(1);
      return true; // 쿼리가 성공하면 연결됨 (빈 테이블이어도 OK)
    } catch (e) {
      if (!kReleaseMode) debugPrint('   ⚠️ 연결 테스트 오류: $e');
      return false;
    }
  }
}
