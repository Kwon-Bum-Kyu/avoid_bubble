import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 설정을 관리하는 클래스
class EnvironmentConfig {
  /// dotenv 초기화 (환경에 따라 다른 파일 로드)
  static Future<void> initialize() async {
    try {
      // dart-define으로 환경 변수가 주입되었는지 확인 (웹 배포용)
      const dartDefineEnv = String.fromEnvironment('ENVIRONMENT');
      if (dartDefineEnv.isNotEmpty) {
        // dart-define 환경 변수가 있으면 .env 파일 로딩 건너뛰기
        if (kDebugMode) {
          print('✅ dart-define 환경 변수 감지: $dartDefineEnv');
        }
        return;
      }

      // dart-define이 없는 경우에만 .env 파일 로딩 시도 (로컬 개발용)
      if (kIsWeb && kReleaseMode) {
        // 웹 릴리즈 빌드에서는 .env 파일 로딩을 건너뛰고 폴백 설정 사용
        await _setHardcodedWebConfig();
        return;
      }

      // Flutter 빌드 모드에 따라 환경 파일 선택
      String envFile;
      if (kReleaseMode) {
        envFile = ".env.production";
      } else if (kDebugMode) {
        envFile = ".env.development";
      } else {
        envFile = ".env";
      }

      // 로컬 환경에서만 .env 파일 로딩 시도
      if (kIsWeb) {
        await _loadEnvironmentForWeb(envFile);
      } else {
        await dotenv.load(fileName: envFile);
      }

    } catch (e) {
      // 폴백 로딩 시도
      await _tryFallbackLoading();
    }
  }

  /// 웹 플랫폼용 환경 로딩
  static Future<void> _loadEnvironmentForWeb(String envFile) async {
    // 웹 릴리즈 빌드에서는 .env 파일 로딩을 시도하지 않음
    if (kReleaseMode) {
      await _setHardcodedWebConfig();
      return;
    }

    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      // 웹에서는 하드코딩된 설정으로 폴백
      await _setHardcodedWebConfig();
    }
  }

  /// 폴백 로딩 시도
  static Future<void> _tryFallbackLoading() async {
    // 웹 릴리즈 빌드에서는 바로 하드코딩된 설정 사용
    if (kIsWeb && kReleaseMode) {
      await _setHardcodedWebConfig();
      return;
    }

    final fallbackFiles = [".env", ".env.development"];
    bool loaded = false;

    for (final fallbackFile in fallbackFiles) {
      try {
        if (kIsWeb) {
          await _loadEnvironmentForWeb(fallbackFile);
        } else {
          await dotenv.load(fileName: fallbackFile);
        }
        loaded = true;
        break;
      } catch (fallbackError) {
        // 폴백 파일 로딩 실패는 다음 파일로 시도
      }
    }

    if (!loaded) {
      if (kIsWeb) {
        await _setHardcodedWebConfig();
      }
    }
  }

  /// 웹용 폴백 설정 (환경 파일 로딩 실패 시)
  static Future<void> _setHardcodedWebConfig() async {
    if (kDebugMode) {
      print('⚠️ 환경 파일을 찾을 수 없어 폴백 설정을 사용합니다.');
      print('ℹ️ .env 파일을 생성하고 Supabase 설정을 추가하세요.');
    }

    // 프로덕션인지 확인하여 적절한 설정 적용
    final isProduction = kReleaseMode;

    // 기본 환경 변수 설정 (민감한 정보는 제외)
    dotenv.env.clear();
    dotenv.env.addAll({
      'ENVIRONMENT': isProduction ? 'production' : 'development',
      'DEVELOPER_MODE_ENABLED': isProduction ? 'false' : 'true',
      'DEBUG_INFO': isProduction ? 'false' : 'true',
      'API_TIMEOUT': isProduction ? '5000' : '10000',
      'MAX_RETRIES': isProduction ? '2' : '3',
      // 주의: SUPABASE_URL과 SUPABASE_ANON_KEY는 .env 파일에서 설정해야 합니다
    });
  }

  /// 현재 환경이 로컬인지 확인
  static bool get isLocal {
    // dart-define 환경 설정 우선 확인 (웹 배포용)
    const dartDefineEnv = String.fromEnvironment('ENVIRONMENT');
    String environment = dartDefineEnv.isNotEmpty 
        ? dartDefineEnv.toLowerCase() 
        : (dotenv.env['ENVIRONMENT']?.toLowerCase() ?? '');

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

    // dart-define 개발자 모드 설정 우선 확인 (웹 배포용)
    const dartDefineDeveloperMode = String.fromEnvironment('DEVELOPER_MODE_ENABLED');
    String developerMode = dartDefineDeveloperMode.isNotEmpty 
        ? dartDefineDeveloperMode.toLowerCase() 
        : (dotenv.env['DEVELOPER_MODE_ENABLED']?.toLowerCase() ?? 'false');
        
    return developerMode == 'true' || developerMode == '1';
  }

  /// 현재 환경 이름
  static String get environmentName {
    return isLocal ? 'Local' : 'Production';
  }

  /// 디버그 정보 표시 여부
  static bool get showDebugInfo {
    if (isProduction) return false;

    // dart-define 디버그 정보 설정 우선 확인 (웹 배포용)
    const dartDefineDebugInfo = String.fromEnvironment('DEBUG_INFO');
    String debugInfo = dartDefineDebugInfo.isNotEmpty 
        ? dartDefineDebugInfo.toLowerCase() 
        : (dotenv.env['DEBUG_INFO']?.toLowerCase() ?? 'false');
        
    return debugInfo == 'true' || debugInfo == '1';
  }

  /// API 타임아웃 (밀리초)
  static int get apiTimeout {
    // dart-define API 타임아웃 설정 우선 확인 (웹 배포용)
    const dartDefineTimeout = String.fromEnvironment('API_TIMEOUT');
    String timeout = dartDefineTimeout.isNotEmpty 
        ? dartDefineTimeout 
        : (dotenv.env['API_TIMEOUT'] ?? '5000');
        
    return int.tryParse(timeout) ?? 5000;
  }

  /// 최대 재시도 횟수
  static int get maxRetries {
    // dart-define 최대 재시도 설정 우선 확인 (웹 배포용)
    const dartDefineRetries = String.fromEnvironment('MAX_RETRIES');
    String retries = dartDefineRetries.isNotEmpty 
        ? dartDefineRetries 
        : (dotenv.env['MAX_RETRIES'] ?? '2');
        
    return int.tryParse(retries) ?? 2;
  }

  /// Supabase URL (dart-define 우선, 그 다음 .env)
  static String? get supabaseUrl {
    // dart-define으로 주입된 값 우선 사용 (웹 배포용)
    const dartDefineUrl = String.fromEnvironment('SUPABASE_URL');
    if (dartDefineUrl.isNotEmpty) return dartDefineUrl;
    
    // .env 파일의 값 사용 (로컬 개발용)
    return dotenv.env['SUPABASE_URL'];
  }

  /// Supabase Anon Key (dart-define 우선, 그 다음 .env)
  static String? get supabaseAnonKey {
    // dart-define으로 주입된 값 우선 사용 (웹 배포용)
    const dartDefineKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (dartDefineKey.isNotEmpty) return dartDefineKey;
    
    // .env 파일의 값 사용 (로컬 개발용)
    return dotenv.env['SUPABASE_ANON_KEY'];
  }
}
