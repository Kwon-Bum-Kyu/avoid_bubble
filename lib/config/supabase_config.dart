import 'package:supabase_flutter/supabase_flutter.dart';
import 'environment_config.dart';

/// Supabase 설정 및 초기화를 관리하는 클래스
class SupabaseConfig {
  static SupabaseClient? _client;

  /// Supabase 클라이언트 인스턴스
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseConfig.initialize() first.',
      );
    }
    return _client!;
  }

  /// Supabase 초기화 (환경 설정 기반)
  static Future<void> initialize() async {
    final supabaseUrl = EnvironmentConfig.supabaseUrl;
    final supabaseAnonKey = EnvironmentConfig.supabaseAnonKey;

    if (supabaseUrl == null || supabaseAnonKey == null) {
      final errorMessage = 'Supabase URL or ANON KEY not found in environment config';
      throw Exception(errorMessage);
    }

    if (supabaseUrl.contains('your-project') ||
        supabaseAnonKey.contains('your_') ||
        supabaseUrl.contains('your-production-project')) {
      final errorMessage = 'Please update SUPABASE_URL and SUPABASE_ANON_KEY in environment files';
      throw Exception(errorMessage);
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: EnvironmentConfig.showDebugInfo, // 환경에 따라 디버그 모드 설정
      );

      _client = Supabase.instance.client;
      
      // 연결 테스트
      await checkConnection();
      
    } catch (e) {
      rethrow;
    }
  }

  /// 연결 상태 확인
  static Future<bool> checkConnection() async {
    try {
      final response = await client.from('rankings').select('id').limit(1);
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
