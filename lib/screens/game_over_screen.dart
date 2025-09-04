import 'package:flutter/material.dart';
import '../models/ranking_model.dart';
import '../services/ranking_service.dart';
import '../services/nickname_service.dart';
import '../utils/responsive_utils.dart';
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
  bool _isNewBestRecord = false;
  int? _currentRank;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _checkAndRegisterRecord();
  }

  Future<void> _checkAndRegisterRecord() async {
    try {
      _nickname = await NicknameService.getSavedNickname();
      
      if (_nickname != null && _nickname!.isNotEmpty) {
        _isNewBestRecord = await RankingService.isNewBestRecord(_nickname!, widget.survivalTime);
        
        if (_isNewBestRecord) {
          await _registerRanking();
        }
        
        _currentRank = await RankingService.getMyRank(widget.survivalTime);
      }
    } catch (e) {
      // 에러 무시 (오프라인일 수 있음)
    } finally {
      // Check completed
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
      
      await RankingService.addRankingIfBest(ranking);
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
    final isCompactHeight = ResponsiveUtils.isCompactHeight(context);
    final isWideScreen = ResponsiveUtils.isWideScreen(context);

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
                margin: ResponsiveUtils.getResponsivePadding(context),
                padding: EdgeInsets.all(isCompactHeight ? 16 : 24),
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(isCompactHeight ? 15 : 20),
                  border: Border.all(
                    color: gradeColor.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradeColor.withValues(alpha: 0.3),
                      blurRadius: isCompactHeight ? 15 : 20,
                      spreadRadius: isCompactHeight ? 3 : 5,
                    ),
                  ],
                ),
                child: _buildMainContent(grade, gradeColor, isCompactHeight, isWideScreen),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(String grade, Color gradeColor, bool isCompactHeight, bool isWideScreen) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Game Over Title
        Text(
          'GAME OVER',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context,
              mobile: 28, tablet: 32, desktop: 36),
            fontWeight: FontWeight.bold,
            color: Colors.red,
            letterSpacing: 2,
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),
        
        // 생존 시간과 등급 표시
        Container(
          padding: EdgeInsets.all(isCompactHeight ? 15 : 20),
          decoration: BoxDecoration(
            color: gradeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: gradeColor, width: 1),
          ),
          child: Column(
            children: [
              Text(
                '생존 시간',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 14, tablet: 16, desktop: 18),
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 8)),
              Text(
                '${_formatTime(widget.survivalTime)}초',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 32, tablet: 36, desktop: 40),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompactHeight ? 12 : 16, 
                  vertical: isCompactHeight ? 6 : 8
                ),
                decoration: BoxDecoration(
                  color: gradeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Grade $grade',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 14, tablet: 16, desktop: 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),

        // 랭킹 정보 (닉네임이 있는 경우)
        if (_nickname != null && _nickname!.isNotEmpty) ...[ 
          if (_isNewBestRecord) 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.star,
                    size: 32,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '새로운 최고 기록!',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                        mobile: 16, tablet: 18, desktop: 20),
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  if (_currentRank != null) ...[ 
                    const SizedBox(height: 8),
                    Text(
                      '현재 순위: $_currentRank위',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                          mobile: 14, tablet: 16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            )
          else if (_currentRank != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '현재 순위: $_currentRank위',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 16, tablet: 18),
                ),
              ),
            ),
        ] else ...[ 
          // 닉네임이 없는 경우
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
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
                Text(
                  '랭킹에 도전하세요!',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 16, tablet: 18, desktop: 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '닉네임을 등록하면 기록이 랭킹에 등록됩니다.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 14, tablet: 16),
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

        SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 24)),

        // 버튼들
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onRestart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: EdgeInsets.symmetric(
                    vertical: isCompactHeight ? 12 : 15
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '다시 시작',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 16, tablet: 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onBackToMenu,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: EdgeInsets.symmetric(
                    vertical: isCompactHeight ? 12 : 15
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '메뉴로',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                      mobile: 16, tablet: 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        if (widget.onShowRanking != null) ...[ 
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 12)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onShowRanking,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: EdgeInsets.symmetric(
                  vertical: isCompactHeight ? 12 : 15
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                '랭킹 보기',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                    mobile: 16, tablet: 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}