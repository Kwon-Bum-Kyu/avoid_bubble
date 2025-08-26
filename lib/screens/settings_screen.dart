import 'package:flutter/material.dart';
import '../models/game_settings.dart';
import '../config/environment_config.dart';

class SettingsScreen extends StatefulWidget {
  final GameSettings settings;
  final Function(GameSettings) onSettingsChanged;
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onBack,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  late GameSettings _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = GameSettings(
      bulletSpeed: widget.settings.bulletSpeed,
      playerSpeed: widget.settings.playerSpeed,
      isInvincible: widget.settings.isInvincible,
      patternTimings: PatternTimings(
        pattern1StartTime: widget.settings.patternTimings.pattern1StartTime,
        pattern1EndTime: widget.settings.patternTimings.pattern1EndTime,
        pattern1Interval: widget.settings.patternTimings.pattern1Interval,
        pattern1FastInterval: widget.settings.patternTimings.pattern1FastInterval,
        pattern2StartTime: widget.settings.patternTimings.pattern2StartTime,
        pattern2Interval: widget.settings.patternTimings.pattern2Interval,
        pattern3StartTime: widget.settings.patternTimings.pattern3StartTime,
        pattern3Interval: widget.settings.patternTimings.pattern3Interval,
      ),
      soundEnabled: widget.settings.soundEnabled,
      soundVolume: widget.settings.soundVolume,
      showHitboxes: widget.settings.showHitboxes,
      reducedMotion: widget.settings.reducedMotion,
    );
  }

  void _saveSettings() {
    widget.onSettingsChanged(_currentSettings);
    widget.onBack();
  }

  void _resetToDefaults() {
    setState(() {
      _currentSettings = GameSettings.defaultSettings();
    });
  }

  void _loadDebugSettings() {
    setState(() {
      _currentSettings = GameSettings.debugSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        '설정',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Settings Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 개발자 모드 섹션 (로컬 빌드에서만 표시)
                      if (EnvironmentConfig.isDeveloperModeEnabled) ...[
                        _buildSection(
                          '게임 난이도 (개발자 모드)',
                          [
                            _buildSlider(
                              '총알 속도',
                              _currentSettings.bulletSpeed,
                              40.0,
                              150.0,
                              (value) => setState(() {
                                _currentSettings = _currentSettings.copyWith(bulletSpeed: value);
                              }),
                            ),
                            _buildSlider(
                              '플레이어 속도',
                              _currentSettings.playerSpeed,
                              200.0,
                              500.0,
                              (value) => setState(() {
                                _currentSettings = _currentSettings.copyWith(playerSpeed: value);
                              }),
                            ),
                            _buildSlider(
                              '충돌 범위 크기',
                              _currentSettings.playerCollisionRadius,
                              8.0,
                              24.0,
                              (value) => setState(() {
                                _currentSettings = _currentSettings.copyWith(playerCollisionRadius: value);
                              }),
                            ),
                            _buildSwitch(
                              '무적 모드',
                              _currentSettings.isInvincible,
                              (value) => setState(() {
                                _currentSettings = _currentSettings.copyWith(isInvincible: value);
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      // 패턴 시간 조정 섹션 (로컬 빌드에서만 표시)
                      if (EnvironmentConfig.isDeveloperModeEnabled) ...[
                        _buildSection(
                          '패턴 시간 (개발자 모드)',
                          [
                            _buildSlider(
                              '패턴 1 시작 (초)',
                              _currentSettings.patternTimings.pattern1StartTime,
                              1.0,
                              10.0,
                              (value) => setState(() {
                                _currentSettings = _currentSettings.copyWith(
                                  patternTimings: _currentSettings.patternTimings.copyWith(
                                    pattern1StartTime: value,
                                  ),
                                );
                              }),
                            ),
                            _buildSlider(
                              '패턴 2 시작 (초)',
                              _currentSettings.patternTimings.pattern2StartTime,
                              10.0,
                              30.0,
                              (value) => setState(() {
                                _currentSettings = _currentSettings.copyWith(
                                  patternTimings: _currentSettings.patternTimings.copyWith(
                                    pattern2StartTime: value,
                                  ),
                                );
                              }),
                            ),
                            _buildSlider(
                              '패턴 3 시작 (초)',
                              _currentSettings.patternTimings.pattern3StartTime,
                              20.0,
                              60.0,
                              (value) => setState(() {
                                _currentSettings = _currentSettings.copyWith(
                                  patternTimings: _currentSettings.patternTimings.copyWith(
                                    pattern3StartTime: value,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                      
                      const SizedBox(height: 20),
                      
                      _buildSection(
                        '시각 및 오디오',
                        [
                          // 히트박스 표시는 개발자 모드에서만 표시
                          if (EnvironmentConfig.isDeveloperModeEnabled) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSwitch(
                                  '히트박스 표시 (개발자 전용)',
                                  _currentSettings.showHitboxes,
                                  (value) => setState(() {
                                    _currentSettings = _currentSettings.copyWith(showHitboxes: value);
                                  }),
                                ),
                                if (_currentSettings.showHitboxes) ...[
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      '• 플레이어: 초록색 원\n• 모든 탄막: 빨간색 원',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                          _buildSwitch(
                            '사운드 효과',
                            _currentSettings.soundEnabled,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(soundEnabled: value);
                            }),
                          ),
                          _buildVolumeSlider(
                            '사운드',
                            _currentSettings.soundVolume,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(soundVolume: value);
                            }),
                          ),
                        ],
                      ),
                      
                      // 환경 정보 표시
                      _buildSection(
                        '빌드 정보',
                        [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: EnvironmentConfig.isDeveloperModeEnabled 
                                  ? Colors.orange.withValues(alpha: 0.3)
                                  : Colors.green.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '환경: ${EnvironmentConfig.environmentName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  EnvironmentConfig.isDeveloperModeEnabled 
                                      ? '개발자 기능이 활성화되어 있습니다.'
                                      : '프로덕션 모드로 실행 중입니다.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                if (EnvironmentConfig.showDebugInfo) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '디버그 모드: ${EnvironmentConfig.isLocal ? "활성" : "비활성"}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white60,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _resetToDefaults,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[700],
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text('기본값으로 재설정'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // 디버그 모드 버튼은 로컬 빌드에서만 표시
                          if (EnvironmentConfig.isDeveloperModeEnabled)
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _loadDebugSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[700],
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: const Text('디버그 모드'),
                              ),
                            ),
                        ],
                      ),
                      
                      // 히트박스 퀵 토글 버튼 (개발자 모드에서만 표시)
                      if (EnvironmentConfig.isDeveloperModeEnabled) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _currentSettings = _currentSettings.copyWith(
                                  showHitboxes: !_currentSettings.showHitboxes
                                );
                              });
                            },
                            icon: Icon(
                              _currentSettings.showHitboxes 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                            ),
                            label: Text(
                              _currentSettings.showHitboxes 
                                ? '히트박스 숨기기' 
                                : '히트박스 표시',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _currentSettings.showHitboxes 
                                ? Colors.green[700] 
                                : Colors.blue[700],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 10),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text(
                            '설정 저장',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).round(),
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildVolumeSlider(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '${(value * 100).round()}%',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          divisions: 20, // 5% 단위로 조절
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSwitch(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
      ],
    );
  }
}