import 'package:flutter/material.dart';
import '../models/game_settings.dart';

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
                        'Settings',
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
                      _buildSection(
                        'Game Difficulty',
                        [
                          _buildSlider(
                            'Bullet Speed',
                            _currentSettings.bulletSpeed,
                            40.0,
                            150.0,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(bulletSpeed: value);
                            }),
                          ),
                          _buildSlider(
                            'Player Speed',
                            _currentSettings.playerSpeed,
                            200.0,
                            500.0,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(playerSpeed: value);
                            }),
                          ),
                          _buildSwitch(
                            'Invincible Mode',
                            _currentSettings.isInvincible,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(isInvincible: value);
                            }),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      _buildSection(
                        'Pattern Timings',
                        [
                          _buildSlider(
                            'Pattern 1 Start (sec)',
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
                            'Pattern 2 Start (sec)',
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
                            'Pattern 3 Start (sec)',
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
                      
                      _buildSection(
                        'Visual & Audio',
                        [
                          _buildSwitch(
                            'Show Hitboxes',
                            _currentSettings.showHitboxes,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(showHitboxes: value);
                            }),
                          ),
                          _buildSwitch(
                            'Sound Effects',
                            _currentSettings.soundEnabled,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(soundEnabled: value);
                            }),
                          ),
                          _buildSlider(
                            'Sound Volume',
                            _currentSettings.soundVolume,
                            0.0,
                            1.0,
                            (value) => setState(() {
                              _currentSettings = _currentSettings.copyWith(soundVolume: value);
                            }),
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
                              child: const Text('Reset to Defaults'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _loadDebugSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[700],
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text('Debug Mode'),
                            ),
                          ),
                        ],
                      ),
                      
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
                            'Save Settings',
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
            color: Colors.white.withOpacity(0.1),
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