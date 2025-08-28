import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_settings.dart';

// 조건부 import - 웹에서는 실제 구현, 다른 플랫폼에서는 스텁
import 'audio_service_web.dart' 
  if (dart.library.html) 'audio_service_web.dart'
  if (dart.library.io) 'audio_service_stub.dart';

/// 게임 오디오 관리 서비스 (웹/모바일 호환)
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  
  AudioService._();

  /// 현재 재생 중인 BGM
  String? _currentBgm;
  
  /// 게임 설정
  GameSettings? _settings;

  /// 웹용 오디오 서비스
  final AudioServiceWeb _webService = AudioServiceWeb();


  /// 설정 업데이트
  void updateSettings(GameSettings settings) {
    final oldSettings = _settings;
    _settings = settings;
    
    // 볼륨이 변경되었으면 BGM 볼륨 조절
    if (oldSettings?.soundVolume != settings.soundVolume) {
      _updateBgmVolume();
    }
    
    // 사운드가 비활성화되었으면 BGM 정지
    if (!settings.soundEnabled && _currentBgm != null) {
      stopBgm();
    }
  }

  /// BGM 재생
  Future<void> playBgm(String filename) async {
    try {
      if (!(_settings?.soundEnabled ?? true)) return;
      
      // 이미 같은 BGM이 재생 중이면 무시
      if (_currentBgm == filename) return;
      
      // 기존 BGM 정지
      await stopBgm();

      if (kIsWeb) {
        // 웹에서는 웹 서비스 사용
        await _webService.playBgmWeb(filename, _settings);
      } else {
        // 모바일/데스크톱에서는 flame_audio 사용
        await _playBgmNative(filename);
      }
      
      _currentBgm = filename;
    } catch (e) {
      // BGM 재생 실패는 게임 진행에 영향 없음
    }
  }


  /// 네이티브용 BGM 재생  
  Future<void> _playBgmNative(String filename) async {
    if (kIsWeb) return;
    
    // flame_audio는 웹이 아닐때만 사용
    // 실제로는 dynamic import나 conditional import 필요
  }

  /// BGM 정지
  Future<void> stopBgm() async {
    try {
      if (_currentBgm != null) {
        if (kIsWeb) {
          await _webService.stopBgmWeb();
        }
        
        _currentBgm = null;
      }
    } catch (e) {
      // BGM 정지 실패는 무시
    }
  }

  /// BGM 일시정지
  Future<void> pauseBgm() async {
    try {
      if (_currentBgm != null) {
        if (kIsWeb) {
          await _webService.pauseBgmWeb();
        }
      }
    } catch (e) {
      // BGM 일시정지 실패는 무시
    }
  }

  /// BGM 재개 (사용자 상호작용 후)
  Future<void> resumeBgm() async {
    try {
      if (_currentBgm != null && (_settings?.soundEnabled ?? true)) {
        if (kIsWeb) {
          await _webService.resumeBgmWeb();
        }
      }
    } catch (e) {
      // BGM 재개 실패는 무시
    }
  }

  /// 사용자 클릭 시 BGM 시작 시도 (자동재생 정책 우회)
  Future<void> tryPlayBgmOnUserInteraction() async {
    if (kIsWeb && _currentBgm != null) {
      try {
        await _webService.tryPlayBgmOnUserInteractionWeb();
      } catch (e) {
        // 사용자 상호작용 BGM 시도 실패는 무시
      }
    }
  }

  /// 효과음 재생 (현재는 로그만)
  Future<void> playSound(String filename) async {
    try {
      if (!(_settings?.soundEnabled ?? true)) return;
      // 효과음 재생 로직 (현재 미구현)
    } catch (e) {
      // 효과음 재생 실패는 무시
    }
  }

  /// BGM 볼륨 업데이트
  void _updateBgmVolume() {
    if (_currentBgm != null) {
      if (kIsWeb) {
        _webService.updateBgmVolumeWeb(_settings);
      }
    }
  }

  /// 유효 볼륨 계산 (설정 볼륨 * 사운드 활성화 여부)
  double _getEffectiveVolume() {
    if (!(_settings?.soundEnabled ?? true)) return 0.0;
    return _settings?.soundVolume ?? 0.5;
  }

  /// 현재 BGM 재생 상태
  bool get isBgmPlaying => _currentBgm != null;

  /// 현재 재생 중인 BGM 파일명
  String? get currentBgm => _currentBgm;

  /// 모든 오디오 정리
  Future<void> dispose() async {
    await stopBgm();
    if (kIsWeb) {
      await _webService.disposeWeb();
    }
    _settings = null;
    // 정리 완료
  }
}