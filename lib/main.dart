import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/avoid_bubble_game.dart';
import 'game/game_state.dart';
import 'models/game_settings.dart';
import 'models/game_stats.dart';
import 'screens/start_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/ranking_screen.dart';
import 'config/environment_config.dart';
import 'config/supabase_config.dart';
import 'config/game_constants.dart';
import 'services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter 프레임워크 오류 처리 (마우스 트래킹 등)
  FlutterError.onError = (FlutterErrorDetails details) {
    // 마우스 트래킹 관련 오류는 무시
    if (details.toString().contains('mouse_tracker') ||
        details.toString().contains('deviceUpdatePhase') ||
        details.toString().contains('_debugDuringDeviceUpdate') ||
        details.toString().contains('updateAllDevices') ||
        details.toString().contains('RenderObject')) {
      if (!kReleaseMode) {
        debugPrint('⚠️ 무시된 마우스 트래킹 오류: ${details.exception}');
      }
      return;
    }
    
    // 기타 중요한 오류는 로그
    FlutterError.presentError(details);
  };

  // 웹 환경에서 안전한 orientation 처리 (itch.io 호환성)
  if (kIsWeb) {
    // 웹에서는 강제 orientation 설정을 하지 않음 (itch.io 모바일 호환성)
    try {
      // 가능하면 landscape를 선호하지만 실패해도 무시
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      // itch.io나 다른 환경에서 orientation 설정이 실패해도 계속 진행
      if (!kReleaseMode) debugPrint('⚠️ Orientation 설정 실패 (무시됨): $e');
    }
  } else {
    // 네이티브 앱에서는 landscape 우선 설정
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
      ]);
    } catch (e) {
      if (!kReleaseMode) debugPrint('⚠️ Orientation 설정 실패: $e');
    }
  }

  bool supabaseInitialized = false;

  try {
    // 환경 설정 초기화
    await EnvironmentConfig.initialize();

    if (kDebugMode) {
      // 초기화 후 환경 상태 확인
      final url = EnvironmentConfig.supabaseUrl;
      final key = EnvironmentConfig.supabaseAnonKey;
      debugPrint('🔍 main.dart에서 확인된 환경 설정:');
      debugPrint(
          '   - SUPABASE_URL: ${url != null ? "${url.substring(0, 30)}..." : "null"}');
      debugPrint(
          '   - SUPABASE_ANON_KEY: ${key != null ? "${key.substring(0, 20)}..." : "null"}');
    }

    // 웹에서 더 안전한 초기화
    if (kIsWeb) {
      try {
        if (!kReleaseMode) debugPrint('🚀 Supabase 초기화 시작...');
        await SupabaseConfig.initialize().timeout(const Duration(seconds: 10));
        supabaseInitialized = true;
        if (!kReleaseMode) debugPrint('✅ Supabase 초기화 성공');
      } catch (e) {
        if (!kReleaseMode) debugPrint('❌ Supabase 초기화 실패: $e');
        supabaseInitialized = false;
      }
    } else {
      // 네이티브 플랫폼
      await SupabaseConfig.initialize();
      supabaseInitialized = true;
    }
  } catch (e) {
    if (!kReleaseMode) debugPrint('❌ 메인 초기화 오류: $e');
    supabaseInitialized = false;
  }

  if (!kReleaseMode) {
    debugPrint('🎮 앱 시작: ${supabaseInitialized ? "온라인 모드" : "오프라인 모드"}');
  }
  runApp(MyApp(isOfflineMode: !supabaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool isOfflineMode;

  const MyApp({super.key, this.isOfflineMode = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '어보이드 버블',
      theme: ThemeData(fontFamily: 'NexonCart'),
      home: GameWrapper(isOfflineMode: isOfflineMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameWrapper extends StatefulWidget {
  final bool isOfflineMode;

  const GameWrapper({super.key, this.isOfflineMode = false});

  @override
  GameWrapperState createState() => GameWrapperState();
}

class GameWrapperState extends State<GameWrapper> {
  GameState _currentState = GameState.startScreen;
  late AvoidBubbleGame game;
  GameSettings _settings = GameSettings.defaultSettings();
  GameStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      await _loadStats();
      _createNewGame();

      setState(() {
        _isLoading = false;
      });

      // 웹에서 로딩 완료 신호 전송
      if (kIsWeb) {
        _notifyLoadingComplete();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // 오류가 발생해도 로딩 완료 신호 전송
      if (kIsWeb) {
        _notifyLoadingComplete();
      }
    }
  }

  // 웹 로딩 완료 알림
  void _notifyLoadingComplete() {
    if (kIsWeb) {
      // Flutter Web에서 JavaScript로 게임 준비 신호 전송
      // flutter-first-frame 이벤트와 함께 자동으로 처리됨
      if (!kReleaseMode) debugPrint('🎮 게임 초기화 완료');
    }
  }

  Future<void> _loadStats() async {
    final stats = await GameStats.load();
    setState(() {
      _stats = stats;
    });
  }

  @override
  void dispose() {
    // 오디오 서비스 정리
    AudioService.instance.dispose();
    super.dispose();
  }

  void _createNewGame() {
    game = AvoidBubbleGame(settings: _settings);
    game.onGameOver = _showGameOver;
  }

  void _startGame() {
    // 새로운 게임 인스턴스를 생성하여 완전히 초기화
    _createNewGame();

    setState(() {
      _currentState = GameState.playing;
    });
  }

  void _showGameOver() {
    _stats?.recordGame(game.survivalTime, 'F',
        0); // Grade and bullets avoided are not implemented yet
    setState(() {
      _currentState = GameState.gameOver;
    });
  }

  void _restartGame() {
    // 새로운 게임 인스턴스를 생성하여 완전히 초기화
    _createNewGame();

    setState(() {
      _currentState = GameState.playing;
    });
  }

  void _showSettings() {
    // 설정 화면으로 이동할 때 BGM 정지
    AudioService.instance.stopBgm();

    setState(() {
      _currentState = GameState.settings;
    });
  }

  void _updateSettings(GameSettings newSettings) {
    setState(() {
      _settings = newSettings;
      // 오디오 설정 업데이트
      AudioService.instance.updateSettings(newSettings);
      _createNewGame(); // Recreate game with new settings
    });
  }

  void _backToStart() {
    // 메인 메뉴로 돌아갈 때 BGM 정지
    AudioService.instance.stopBgm();

    setState(() {
      _currentState = GameState.startScreen;
      _createNewGame(); // Create new game instance
    });
  }

  void _showRanking() {
    // 랭킹 화면으로 이동할 때 BGM 정지
    AudioService.instance.stopBgm();

    setState(() {
      _currentState = GameState.ranking;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _stats == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              SizedBox(height: 20),
              Text(
                'Loading Game...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'NexonCart',
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_currentState) {
      case GameState.startScreen:
        return StartScreen(
          onStartGame: _startGame,
          onShowSettings: _showSettings,
          onShowRanking: _showRanking,
          stats: _stats!,
        );
      case GameState.settings:
        return SettingsScreen(
          settings: _settings,
          onSettingsChanged: _updateSettings,
          onBack: _backToStart,
        );
      case GameState.playing:
        return GameScreen(
          game: game,
          onBackToStart: _backToStart,
          onRestart: _restartGame,
        );
      case GameState.gameOver:
        return GameOverScreen(
          survivalTime: game.survivalTime,
          onRestart: _restartGame,
          onBackToMenu: _backToStart,
          onShowRanking: widget.isOfflineMode ? null : _showRanking,
        );
      case GameState.ranking:
        return RankingScreen(
          onBack: _backToStart,
        );
    }
  }
}

class GameScreen extends StatefulWidget {
  final AvoidBubbleGame game;
  final VoidCallback onBackToStart;
  final VoidCallback? onRestart;

  const GameScreen({
    super.key,
    required this.game,
    required this.onBackToStart,
    this.onRestart,
  });

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late FocusNode _focusNode;
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // Request focus immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    setState(() {
      if (event is KeyDownEvent) {
        _keysPressed.add(event.logicalKey);
      } else if (event is KeyUpEvent) {
        _keysPressed.remove(event.logicalKey);
      }
    });
    _updatePlayerMovement();
  }

  void _updatePlayerMovement() {
    double x = 0, y = 0;

    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        _keysPressed.contains(LogicalKeyboardKey.keyA)) {
      x = -1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        _keysPressed.contains(LogicalKeyboardKey.keyD)) {
      x = 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        _keysPressed.contains(LogicalKeyboardKey.keyW)) {
      y = -1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
        _keysPressed.contains(LogicalKeyboardKey.keyS)) {
      y = 1;
    }

    // R키 재시작 기능
    if (_keysPressed.contains(LogicalKeyboardKey.keyR)) {
      widget.onRestart?.call();
    }

    if (_keysPressed.contains(LogicalKeyboardKey.escape)) {
      widget.onBackToStart();
    }

    if (_keysPressed.contains(LogicalKeyboardKey.keyH)) {
      if (GameSettings.isDeveloperModeAvailable) {
        widget.game.toggleHitboxes();
      }
    }

    widget.game.setPlayerMovement(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: GestureDetector(
          onTap: () {
            _focusNode.requestFocus();
            // 사용자 클릭 시 BGM 재생 시도 (자동재생 정책 우회)
            AudioService.instance.tryPlayBgmOnUserInteraction();
          },
          child: Stack(
            children: [
              // 마우스 트래킹 오류 방지를 위해 MouseRegion 제거
              RepaintBoundary(
                child: GameWidget(game: widget.game),
              ),

              // Home button (맨 위에 위치하여 다른 요소들에 가려지지 않도록)
              Positioned(
                top: GameConstants.gameScreenPadding * 2,
                right: GameConstants.gameScreenPadding,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      widget.onBackToStart();
                    },
                    borderRadius:
                        BorderRadius.circular(GameConstants.gameButtonSize / 2),
                    child: Container(
                      width: GameConstants.gameButtonSize,
                      height: GameConstants.gameButtonSize,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(
                            GameConstants.gameButtonSize / 2),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
