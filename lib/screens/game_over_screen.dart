import 'package:flutter/material.dart';
import '../models/ranking_model.dart';
import '../services/ranking_service.dart';
import '../services/nickname_service.dart';
import 'nickname_registration_screen.dart';

class GameOverScreen extends StatefulWidget {
  final double survivalTime;
  final VoidCallback onRestart;
  final VoidCallback onBackToMenu;
  final VoidCallback? onShowRanking;

  const GameOverScreen({
    super.key,
    required this.survivalTime,
    required this.onRestart,
    required this.onBackToMenu,
    this.onShowRanking,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _isCheckingRecord = true;
  bool _isNewBestRecord = false;
  bool _isRankingRegistered = false;
  int? _currentRank;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _checkAndRegisterRecord();
  }

  Future<void> _checkAndRegisterRecord() async {
    try {
      // 닉네임 확인
      _nickname = await NicknameService.getSavedNickname();
      
      if (_nickname != null && _nickname!.isNotEmpty) {
        // 최고 기록인지 확인
        _isNewBestRecord = await RankingService.isNewBestRecord(_nickname!, widget.survivalTime);
        
        if (_isNewBestRecord) {
          // 최고 기록이면 자동 등록
          await _registerRanking();
        }
        
        // 현재 순위 조회
        _currentRank = await RankingService.getMyRank(widget.survivalTime);
      }
    } catch (e) {
      // 에러 무시 (오프라인일 수 있음)
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingRecord = false;
        });
      }
    }
  }

  Future<void> _registerRanking() async {
    if (_nickname == null || _nickname!.isEmpty) return;
    
    try {
      final ranking = RankingModel(
        playerName: _nickname!,
        survivalTime: widget.survivalTime,
        grade: _getScoreGrade(widget.survivalTime),
      );
      
      _isRankingRegistered = await RankingService.addRankingIfBest(ranking);
    } catch (e) {
      // 에러 처리
    }
  }

  void _showNicknameRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NicknameRegistrationScreen(
          onNicknameRegistered: () async {
            Navigator.of(context).pop();
            await _checkAndRegisterRecord();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  String _formatTime(double time) {
    return time.toStringAsFixed(1);
  }

  String _getScoreGrade(double time) {
    if (time >= 60) return 'S';
    if (time >= 45) return 'A';
    if (time >= 30) return 'B';
    if (time >= 15) return 'C';
    if (time >= 5) return 'D';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S': return const Color(0xFFFFD700); // Gold
      case 'A': return const Color(0xFF32CD32); // Lime Green
      case 'B': return const Color(0xFF1E90FF); // Dodger Blue
      case 'C': return const Color(0xFFFF8C00); // Dark Orange
      case 'D': return const Color(0xFFDC143C); // Crimson
      case 'F': return const Color(0xFF808080); // Gray
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grade = _getScoreGrade(widget.survivalTime);
    final gradeColor = _getGradeColor(grade);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: gradeColor.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradeColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Game Over Title
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        letterSpacing: 2,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 생존 시간과 등급
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: gradeColor, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '생존 시간',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_formatTime(widget.survivalTime)}초',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: gradeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Grade $grade',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 랭킹 정보
                    if (_isCheckingRecord)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              '기록 확인 중...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // 랭킹 관련 정보
                      if (_nickname != null && _nickname!.isNotEmpty) ...[
                        if (_isNewBestRecord && _isRankingRegistered) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange, width: 1),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.celebration,
                                  color: Colors.orange,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '🎉 신기록 달성!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_nickname!}님의 최고 기록이 갱신되었습니다.',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_currentRank != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '현재 순위: ${_currentRank}위',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ] else if (_currentRank != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '현재 순위: ${_currentRank}위',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ] else ...[
                        // 닉네임이 없는 경우
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.leaderboard,
                                color: Colors.blue,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '랭킹에 도전하세요!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '닉네임을 등록하면 기록이 랭킹에 등록됩니다.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _showNicknameRegistration,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('닉네임 등록하기'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // 버튼들
                    Column(
                      children: [
                        // 랭킹 보기 버튼 (있는 경우만)
                        if (widget.onShowRanking != null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: widget.onShowRanking,
                              icon: const Icon(Icons.leaderboard),
                              label: const Text(
                                '랭킹 보기',
                                style: TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // 다시 시작
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onRestart,
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              '다시 시작',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // 메뉴로 돌아가기
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onBackToMenu,
                            icon: const Icon(Icons.home),
                            label: const Text(
                              '메뉴로 돌아가기',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}