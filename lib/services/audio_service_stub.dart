import 'dart:async';
import '../models/game_settings.dart';

/// 스텁(더미) 오디오 서비스 구현 (테스트/비웹 환경용)
class AudioServiceWeb {
  /// 스텁 BGM 재생 (아무것도 하지 않음)
  Future<void> playBgmWeb(String filename, GameSettings? settings) async {
    // 스텁 구현 - 아무것도 하지 않음
  }

  /// 스텁 BGM 정지 (아무것도 하지 않음)
  Future<void> stopBgmWeb() async {
    // 스텁 구현 - 아무것도 하지 않음
  }

  /// 스텁 BGM 일시정지 (아무것도 하지 않음)
  Future<void> pauseBgmWeb() async {
    // 스텁 구현 - 아무것도 하지 않음
  }

  /// 스텁 BGM 재개 (아무것도 하지 않음)
  Future<void> resumeBgmWeb() async {
    // 스텁 구현 - 아무것도 하지 않음
  }

  /// 스텁 사용자 상호작용 BGM 시작 (아무것도 하지 않음)
  Future<void> tryPlayBgmOnUserInteractionWeb() async {
    // 스텁 구현 - 아무것도 하지 않음
  }

  /// 스텁 BGM 볼륨 업데이트 (아무것도 하지 않음)
  void updateBgmVolumeWeb(GameSettings? settings) {
    // 스텁 구현 - 아무것도 하지 않음
  }

  /// 스텁 웹 오디오 정리 (아무것도 하지 않음)
  Future<void> disposeWeb() async {
    // 스텁 구현 - 아무것도 하지 않음
  }
}