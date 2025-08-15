import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 설정을 관리하는 클래스
class EnvironmentConfig {
  /// dotenv 초기화 (환경에 따라 다른 파일 로드)
  static Future<void> initialize() async {
    try {
      // Flutter 빌드 모드에 따라 환경 파일 선택
      String envFile;
      if (kReleaseMode) {
        // 릴리즈 빌드 = 프로덕션 환경
        envFile = ".env.production";
      } else if (kDebugMode) {
        // 디버그 빌드 = 개발 환경
        envFile = ".env.development";
      } else {
        // 프로필 빌드 = 기본 환경
        envFile = ".env";
      }
      
      await dotenv.load(fileName: envFile);
      
      if (kDebugMode) {
        print('✅ Environment loaded: $envFile');
        print('🌍 Current environment: ${environmentName}');
        print('🔧 Developer mode: ${isDeveloperModeEnabled}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load environment file: $e');
        print('🔄 Trying fallback .env file...');
      }
      
      // 실패시 기본 .env 파일로 폴백
      try {
        await dotenv.load(fileName: ".env");
        if (kDebugMode) {
          print('✅ Fallback .env file loaded');
        }
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Fallback also failed: $fallbackError');
        }
      }
    }
  }
  
  /// 현재 환경이 로컬인지 확인
  static bool get isLocal {
    // .env 파일에서 환경 설정을 먼저 확인
    final environment = dotenv.env['ENVIRONMENT']?.toLowerCase() ?? '';
    
    // .env에서 명시적으로 production으로 설정된 경우 프로덕션으로 처리
    if (environment == 'production' || environment == 'prod' || environment == 'release') {
      return false;
    }
    
    // .env에서 명시적으로 local로 설정된 경우이고 디버그 모드일 때만 로컬로 처리  
    if ((environment == 'local' || environment == 'development' || environment == 'dev') && kDebugMode) {
      return true;
    }
    
    // 기본값: 릴리즈 빌드에서는 프로덕션 모드
    return kDebugMode;
  }
  
  /// 프로덕션 환경인지 확인
  static bool get isProduction => !isLocal;
  
  /// 개발자 모드가 활성화되어 있는지 확인
  static bool get isDeveloperModeEnabled {
    // 릴리즈 빌드에서는 항상 false (가장 강력한 제약)
    if (kReleaseMode) return false;
    
    // 프로덕션 환경에서는 항상 false
    if (isProduction) return false;
    
    // 디버그 모드가 아니면 false
    if (!kDebugMode) return false;
    
    // .env 파일에서 개발자 모드 설정 확인 (디버그 모드에서만)
    final developerMode = dotenv.env['DEVELOPER_MODE_ENABLED']?.toLowerCase() ?? 'false';
    return developerMode == 'true' || developerMode == '1';
  }
  
  /// 현재 환경 이름
  static String get environmentName {
    return isLocal ? 'Local' : 'Production';
  }
  
  /// 디버그 정보 표시 여부
  static bool get showDebugInfo {
    if (isProduction) return false;
    
    final debugInfo = dotenv.env['DEBUG_INFO']?.toLowerCase() ?? 'false';
    return debugInfo == 'true' || debugInfo == '1';
  }
  
  /// API 타임아웃 (밀리초)
  static int get apiTimeout {
    final timeout = dotenv.env['API_TIMEOUT'];
    return int.tryParse(timeout ?? '5000') ?? 5000;
  }
  
  /// 최대 재시도 횟수
  static int get maxRetries {
    final retries = dotenv.env['MAX_RETRIES'];
    return int.tryParse(retries ?? '2') ?? 2;
  }
  
  /// Supabase URL
  static String? get supabaseUrl => dotenv.env['SUPABASE_URL'];
  
  /// Supabase Anon Key
  static String? get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'];
}