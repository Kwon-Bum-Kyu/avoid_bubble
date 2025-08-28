import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../models/game_settings.dart';

/// 웹용 오디오 서비스 구현
class AudioServiceWeb {
  /// 웹용 오디오 엘리먼트
  html.AudioElement? _webAudioElement;

  /// 웹용 BGM 재생
  Future<void> playBgmWeb(String filename, GameSettings? settings) async {
    if (!kIsWeb) return;
    
    try {
      // 웹용 오디오 엘리먼트 생성
      _webAudioElement = html.AudioElement();
      
      // itch.io 호환 경로 설정 - 절대 경로 사용
      _webAudioElement!.src = 'assets/assets/audio/$filename';
      _webAudioElement!.loop = true;
      _webAudioElement!.volume = _getEffectiveVolume(settings);
      
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
    }
  }

  /// BGM 정지 (웹)
  Future<void> stopBgmWeb() async {
    try {
      if (_webAudioElement != null) {
        _webAudioElement!.pause();
        _webAudioElement!.currentTime = 0;
        _webAudioElement = null;
      }
    } catch (e) {
      // BGM 정지 실패는 무시
    }
  }

  /// BGM 일시정지 (웹)
  Future<void> pauseBgmWeb() async {
    try {
      if (_webAudioElement != null) {
        _webAudioElement!.pause();
      }
    } catch (e) {
      // BGM 일시정지 실패는 무시
    }
  }

  /// BGM 재개 (웹)
  Future<void> resumeBgmWeb() async {
    try {
      if (_webAudioElement != null) {
        await _webAudioElement!.play();
      }
    } catch (e) {
      // BGM 재개 실패는 무시
    }
  }

  /// 사용자 클릭 시 BGM 시작 시도 (웹)
  Future<void> tryPlayBgmOnUserInteractionWeb() async {
    try {
      if (_webAudioElement != null && _webAudioElement!.paused) {
        await _webAudioElement!.play();
      }
    } catch (e) {
      // 사용자 상호작용 BGM 시도 실패는 무시
    }
  }

  /// BGM 볼륨 업데이트 (웹)
  void updateBgmVolumeWeb(GameSettings? settings) {
    if (_webAudioElement != null) {
      _webAudioElement!.volume = _getEffectiveVolume(settings);
    }
  }

  /// 유효 볼륨 계산
  double _getEffectiveVolume(GameSettings? settings) {
    if (!(settings?.soundEnabled ?? true)) return 0.0;
    return settings?.soundVolume ?? 0.5;
  }

  /// 웹 오디오 정리
  Future<void> disposeWeb() async {
    await stopBgmWeb();
  }
}