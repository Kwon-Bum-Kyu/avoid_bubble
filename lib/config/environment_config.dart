import 'package:flutter/foundation.dart';

/// 환경 설정을 관리하는 클래스
class EnvironmentConfig {
  /// 환경 설정 초기화 (dart-define만 사용)
  static Future<void> initialize() async {
    EnvironmentConfig.debugPrint('🚀 EnvironmentConfig.initialize() 시작');
    
    // dart-define 환경 변수 확인
    const dartDefineEnv = String.fromEnvironment('ENVIRONMENT');
    if (dartDefineEnv.isNotEmpty && kDebugMode) {
      EnvironmentConfig.debugPrint('✅ dart-define 환경 변수 감지: $dartDefineEnv');
    }
    
    EnvironmentConfig.debugPrint('📝 기본 환경 설정 적용 시작...');
    // 기본 환경 설정 적용
    _setDefaultConfig();
    
    EnvironmentConfig.debugPrint('🔍 Supabase 설정 상태 확인 시작...');
    // Supabase 설정 상태 확인 및 알림
    _logSupabaseStatus();
    
    EnvironmentConfig.debugPrint('✅ EnvironmentConfig.initialize() 완료');
  }
  
  /// Supabase 설정 상태 로깅 (개발 모드 전용)
  static void _logSupabaseStatus() {
    // 프로덕션 모드에서는 로깅하지 않음
    if (kReleaseMode) return;
    
    final url = supabaseUrl;
    final key = supabaseAnonKey;
    
    // dart-define 직접 확인
    const dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
    const dartDefineKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    
    EnvironmentConfig.debugPrint('🔍 EnvironmentConfig - Supabase 설정 상태 검사:');
    EnvironmentConfig.debugPrint('   - dart-define SUPABASE_URL: ${dartDefineUrl.isNotEmpty ? "${dartDefineUrl.substring(0, 30)}..." : "미설정"}');
    EnvironmentConfig.debugPrint('   - dart-define SUPABASE_ANON_KEY: ${dartDefineKey.isNotEmpty ? "${dartDefineKey.substring(0, 20)}..." : "미설정"}');
    EnvironmentConfig.debugPrint('   - EnvironmentConfig.supabaseUrl getter: ${url != null ? "${url.substring(0, 30)}..." : "null"}');
    EnvironmentConfig.debugPrint('   - EnvironmentConfig.supabaseAnonKey getter: ${key != null ? "${key.substring(0, 20)}..." : "null"}');
    
    if (url != null && key != null) {
      EnvironmentConfig.debugPrint('🔗 EnvironmentConfig - Supabase 온라인 모드 활성화');
    } else {
      EnvironmentConfig.debugPrint('📱 EnvironmentConfig - Supabase 오프라인 모드');
      EnvironmentConfig.debugPrint('   ❌ 온라인 랭킹 기능 비활성화');
    }
  }

  /// 기본 환경 설정 적용
  static void _setDefaultConfig() {
    final isProduction = kReleaseMode;
    
    // dart-define 전용으로 변경됨 - dotenv 사용하지 않음
    // 모든 환경 변수는 dart-define 또는 기본값으로 처리
    
    EnvironmentConfig.debugPrint('✅ 기본 환경 설정 적용 완료: ${isProduction ? "Production" : "Development"}');
  }




  /// 현재 환경이 로컬인지 확인
  static bool get isLocal {
    // dart-define 환경 설정만 사용 (flutter_dotenv 의존성 제거)
    const dartDefineEnv = String.fromEnvironment('ENVIRONMENT');
    String environment = dartDefineEnv.isNotEmpty
        ? dartDefineEnv.toLowerCase()
        : '';

    // 명시적으로 production으로 설정된 경우 프로덕션으로 처리
    if (environment == 'production' ||
        environment == 'prod' ||
        environment == 'release') {
      return false;
    }

    // 명시적으로 local로 설정된 경우이고 디버그 모드일 때만 로컬로 처리
    if ((environment == 'local' ||
            environment == 'development' ||
            environment == 'dev') &&
        kDebugMode) {
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

    // dart-define 개발자 모드 설정만 사용 (flutter_dotenv 의존성 제거)
    const dartDefineDeveloperMode =
        String.fromEnvironment('DEVELOPER_MODE_ENABLED');
    String developerMode = dartDefineDeveloperMode.isNotEmpty
        ? dartDefineDeveloperMode.toLowerCase()
        : 'false';

    return developerMode == 'true' || developerMode == '1';
  }

  /// 현재 환경 이름
  static String get environmentName {
    return isLocal ? 'Local' : 'Production';
  }

  /// 디버그 정보 표시 여부
  static bool get showDebugInfo {
    if (isProduction) return false;

    // dart-define 디버그 정보 설정만 사용 (flutter_dotenv 의존성 제거)
    const dartDefineDebugInfo = String.fromEnvironment('DEBUG_INFO');
    String debugInfo = dartDefineDebugInfo.isNotEmpty
        ? dartDefineDebugInfo.toLowerCase()
        : 'false';

    return debugInfo == 'true' || debugInfo == '1';
  }

  /// API 타임아웃 (밀리초)
  static int get apiTimeout {
    // dart-define API 타임아웃 설정만 사용 (flutter_dotenv 의존성 제거)
    const dartDefineTimeout = String.fromEnvironment('API_TIMEOUT');
    String timeout = dartDefineTimeout.isNotEmpty
        ? dartDefineTimeout
        : '5000';

    return int.tryParse(timeout) ?? 5000;
  }

  /// 최대 재시도 횟수
  static int get maxRetries {
    // dart-define 최대 재시도 설정만 사용 (flutter_dotenv 의존성 제거)
    const dartDefineRetries = String.fromEnvironment('MAX_RETRIES');
    String retries = dartDefineRetries.isNotEmpty
        ? dartDefineRetries
        : '2';

    return int.tryParse(retries) ?? 2;
  }

  /// Supabase URL (dart-define에서만 가져옴)
  static String? get supabaseUrl {
    const dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
    return dartDefineUrl.isNotEmpty ? dartDefineUrl : null;
  }

  /// Supabase Anon Key (dart-define에서만 가져옴)
  static String? get supabaseAnonKey {
    const dartDefineKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    return dartDefineKey.isNotEmpty ? dartDefineKey : null;
  }

  /// 환경에 따른 안전한 print 출력
  /// 프로덕션 모드에서는 print 출력을 억제합니다.
  static void debugPrint(Object? object) {
    // 프로덕션 환경이거나 릴리즈 빌드에서는 print 출력 안함
    if (isProduction || kReleaseMode) {
      return;
    }
    
    // 개발 환경에서만 print 출력
    // ignore: avoid_print
    print(object);
  }

  /// 중요한 시스템 메시지용 print (프로덕션에서도 출력)
  /// 오류나 중요한 시스템 상태 정보에만 사용
  static void systemPrint(Object? object) {
    // ignore: avoid_print
    print(object);
  }
}
