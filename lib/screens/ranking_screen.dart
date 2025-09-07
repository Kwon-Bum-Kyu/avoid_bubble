import 'package:flutter/material.dart';
import '../models/ranking_model.dart';
import '../services/ranking_service.dart';
import '../services/nickname_service.dart';
import '../utils/responsive_utils.dart';
import '../services/localization_service.dart';

class RankingScreen extends StatefulWidget {
  final VoidCallback onBack;

  const RankingScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<RankingModel> _allTimeRankings = [];
  List<RankingModel> _myRecords = [];
  
  bool _isLoading = true;
  String? _currentNickname;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 병렬로 데이터 로드
      final results = await Future.wait([
        RankingService.getTopRankings(limit: 50),
        NicknameService.getSavedNickname(),
      ]);

      _allTimeRankings = results[0] as List<RankingModel>;
      _currentNickname = results[1] as String?;

      // 내 기록 로드 (닉네임이 있는 경우만)
      if (_currentNickname != null && _currentNickname!.isNotEmpty) {
        _myRecords = await RankingService.getPlayerRecords(_currentNickname!);
      }
    } catch (e) {
      // 에러 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.getText('ranking_load_failed')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24),
                    ),
                    Expanded(
                      child: Text(
                        LocalizationService.getText('ranking_title'),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(context,
                            mobile: 24, tablet: 28, desktop: 32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.getResponsiveIconSize(context, mobile: 24) + 16),
                  ],
                ),
              ),
              
              // 탭바
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 40.0 : (isCompactHeight ? 15.0 : 20.0)
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: LocalizationService.getText('ranking_all')),
                    Tab(text: LocalizationService.getText('ranking_my_records')),
                  ],
                  labelColor: Colors.orange,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.orange,
                  dividerColor: Colors.transparent,
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, base: 16)),
              
              // 콘텐츠
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildRankingList(_allTimeRankings, LocalizationService.getText('ranking_no_records')),
                          _buildMyRecordsList(),
                        ],
                      ),
              ),
              
              // 새로고침 버튼
              Padding(
                padding: ResponsiveUtils.getResponsivePadding(context),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadData,
                  icon: Icon(Icons.refresh, 
                    size: ResponsiveUtils.getResponsiveIconSize(context, mobile: 20)
                  ),
                  label: Text(
                    LocalizationService.getText('ranking_refresh'),
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(context, mobile: 16, tablet: 18)
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsiveSpacing(context, base: 24), 
                      vertical: isCompactHeight ? 10 : 12
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildRankingList(List<RankingModel> rankings, String emptyMessage) {
    if (rankings.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: rankings.length,
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        final isMyRecord = ranking.playerName == _currentNickname;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isMyRecord 
                ? Colors.orange.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: isMyRecord 
                ? Border.all(color: Colors.orange, width: 1)
                : null,
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(ranking.rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  ranking.rankEmoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  ranking.playerName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isMyRecord ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                if (isMyRecord) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      LocalizationService.getText('ranking_me'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              LocalizationService.getFormattedText('ranking_survival_time', [ranking.survivalTime.toStringAsFixed(1)]),
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(int.parse(ranking.gradeColor.replaceFirst('#', '0xff'))),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${ranking.gradeEmoji} ${ranking.grade}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyRecordsList() {
    if (_currentNickname == null || _currentNickname!.isEmpty) {
      return Center(
        child: Text(
          LocalizationService.getText('ranking_register_prompt'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_myRecords.isEmpty) {
      return Center(
        child: Text(
          LocalizationService.getText('ranking_no_my_records'),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _myRecords.length,
      itemBuilder: (context, index) {
        final record = _myRecords[index];
        final isPersonalBest = index == 0; // 첫 번째가 최고 기록
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isPersonalBest 
                ? Colors.orange.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: isPersonalBest 
                ? Border.all(color: Colors.orange, width: 2)
                : null,
          ),
          child: ListTile(
            leading: isPersonalBest
                ? const Icon(Icons.star, color: Colors.orange, size: 30)
                : Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            title: Row(
              children: [
                Text(
                  LocalizationService.getFormattedText('ranking_survival_time', [record.survivalTime.toStringAsFixed(1)]),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isPersonalBest ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                if (isPersonalBest) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      LocalizationService.getText('ranking_best'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              record.createdAt != null 
                  ? '${record.createdAt!.year}-${record.createdAt!.month.toString().padLeft(2, '0')}-${record.createdAt!.day.toString().padLeft(2, '0')}'
                  : LocalizationService.getText('ranking_no_date'),
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(int.parse(record.gradeColor.replaceFirst('#', '0xff'))),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${record.gradeEmoji} ${record.grade}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // 금색
      case 2:
        return Colors.grey[300]!; // 은색
      case 3:
        return Colors.brown[300]!; // 동색
      default:
        return Colors.grey[600]!;
    }
  }
}