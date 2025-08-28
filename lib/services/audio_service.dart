import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_settings.dart';

// 웹용 오디오 구현 (조건부 선언)
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html if (dart.library.html) 'dart:html';

/// 게임 오디오 관리 서비스 (웹/모바일 호환)
class AudioService {
  static AudioService? _instance;
  static AudioService get instance => _instance ??= AudioService._();
  
  AudioService._();

  /// 현재 재생 중인 BGM
  String? _currentBgm;
  
  /// 게임 설정
  GameSettings? _settings;

  /// 웹용 오디오 엘리먼트
  html.AudioElement? _webAudioElement;


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
        // 웹에서는 HTML5 Audio 사용
        await _playBgmWeb(filename);
      } else {
        // 모바일/데스크톱에서는 flame_audio 사용
        await _playBgmNative(filename);
      }
      
      _currentBgm = filename;
    } catch (e) {
      // BGM 재생 실패는 게임 진행에 영향 없음
    }
  }


  /// 웹용 BGM 재생
  Future<void> _playBgmWeb(String filename) async {
    if (!kIsWeb) return;
    
    try {
      // 웹용 오디오 엘리먼트 생성
      _webAudioElement = html.AudioElement();
      
      // itch.io 호환 경로 설정 - 절대 경로 사용
      _webAudioElement!.src = 'assets/assets/audio/$filename';
      _webAudioElement!.loop = true;
      _webAudioElement!.volume = _getEffectiveVolume();
      
      // 브라우저 호환성을 위한 설정
      _webAudioElement!.preload = 'auto';
      
      // 오디오 로딩 대기
      final completer = Completer<void>();
      bool hasCompleted = false;
      
      _webAudioElement!.onCanPlayThrough.listen((_) {
        if (!hasCompleted) {
          hasCompleted = true;
          completer.complete();
        }
      });
      
      _webAudioElement!.onError.listen((error) {
        if (!hasCompleted) {
          hasCompleted = true;
          completer.completeError('오디오 로딩 실패');
        }
      });
      
      // 로딩 완료 대기 (타임아웃 5초)
      await completer.future.timeout(const Duration(seconds: 5));
      
      // 사용자 상호작용 후 재생 (자동재생 정책 대응)
      await _webAudioElement!.play();
      
      } catch (e) {
      // 자동재생 차단 시 사용자 클릭 후 재생 안내
      if (e.toString().contains('play() request was interrupted') ||
          e.toString().contains('NotAllowedError')) {
        // 사용자 클릭 대기를 위해 오디오 엘리먼트 유지
        return;
      }
      
      // 다른 오류 시 정리
      _webAudioElement = null;
      _currentBgm = null;
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
        if (kIsWeb && _webAudioElement != null) {
          _webAudioElement!.pause();
          _webAudioElement!.currentTime = 0;
          _webAudioElement = null;
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
        if (kIsWeb && _webAudioElement != null) {
          _webAudioElement!.pause();
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
        if (kIsWeb && _webAudioElement != null) {
          await _webAudioElement!.play();
        }
      }
    } catch (e) {
      // BGM 재개 실패는 무시
    }
  }

  /// 사용자 클릭 시 BGM 시작 시도 (자동재생 정책 우회)
  Future<void> tryPlayBgmOnUserInteraction() async {
    if (kIsWeb && _webAudioElement != null && _currentBgm != null) {
      try {
        if (_webAudioElement!.paused) {
          await _webAudioElement!.play();
        }
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
      if (kIsWeb && _webAudioElement != null) {
        _webAudioElement!.volume = _getEffectiveVolume();
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
    _settings = null;
    // 정리 완료
  }
}