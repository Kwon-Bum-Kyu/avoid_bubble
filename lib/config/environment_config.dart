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

      // 웹 플랫폼에서는 더 관대한 로딩 시도
      if (kIsWeb) {
        await _loadEnvironmentForWeb(envFile);
      } else {
        await dotenv.load(fileName: envFile);
      }

      // 프로덕션에서도 로딩 성공 메시지 표시 (Supabase 연결 확인용)

      if (kDebugMode) {}

      // Supabase 설정 확인
      final url = supabaseUrl;
      final key = supabaseAnonKey;
      if (url != null && key != null) {
      } else {}
    } catch (e) {
      // 순차적으로 폴백 시도
      await _tryFallbackLoading();
    }
  }

  /// 웹 플랫폼용 환경 로딩
  static Future<void> _loadEnvironmentForWeb(String envFile) async {
    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      // 웹에서는 하드코딩된 설정으로 폴백
      await _setHardcodedWebConfig();
    }
  }

  /// 폴백 로딩 시도
  static Future<void> _tryFallbackLoading() async {
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
    // .env 파일에서 환경 설정을 먼저 확인
    final environment = dotenv.env['ENVIRONMENT']?.toLowerCase() ?? '';

    // .env에서 명시적으로 production으로 설정된 경우 프로덕션으로 처리
    if (environment == 'production' ||
        environment == 'prod' ||
        environment == 'release') {
      return false;
    }

    // .env에서 명시적으로 local로 설정된 경우이고 디버그 모드일 때만 로컬로 처리
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

    // .env 파일에서 개발자 모드 설정 확인 (디버그 모드에서만)
    final developerMode =
        dotenv.env['DEVELOPER_MODE_ENABLED']?.toLowerCase() ?? 'false';
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
