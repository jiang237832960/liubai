import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/database.dart';
import '../data/models.dart';
import 'package:intl/intl.dart';
import 'stats_page.dart';
import 'widgets/scene_tag_selector.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  List<LiubaiSession> _sessions = [];
  List<SceneTag> _tags = [];
  DailyStats? _todayStats;
  bool _isLoading = true;
  int? _selectedFilterTagId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final tags = await DatabaseHelper.instance.getAllSceneTags();
      List<LiubaiSession> sessions;

      if (_selectedFilterTagId != null) {
        sessions = await DatabaseHelper.instance.getSessionsByTag(_selectedFilterTagId!);
      } else {
        sessions = await DatabaseHelper.instance.getAllSessions();
      }

      final stats = await DatabaseHelper.instance.getTodayStats();

      setState(() {
        _tags = tags;
        _sessions = sessions;
        _todayStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onFilterTagSelected(int? tagId) {
    setState(() {
      _selectedFilterTagId = tagId;
    });
    _loadData();
  }

  SceneTag? _getTagById(int? tagId) {
    if (tagId == null) return null;
    try {
      return _tags.firstWhere((tag) => tag.id == tagId);
    } catch (e) {
      return null;
    }
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours小时';
    }
    return '$hours小时$mins分钟';
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatDate(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(time.year, time.month, time.day);

    if (date == today) {
      return '今天';
    } else if (date == yesterday) {
      return '昨天';
    } else {
      return DateFormat('M月d日').format(time);
    }
  }

  void _navigateToStats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StatsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiubaiColors.liubaiWhite,
      appBar: AppBar(
        title: const Text('留白日志', style: LiubaiTypography.h1),
        backgroundColor: LiubaiColors.liubaiWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 今日统计
                if (_todayStats != null) _buildTodayStats(),

                // 标签筛选器
                if (_tags.isNotEmpty) _buildTagFilter(),

                // 留白记录列表
                Expanded(
                  child: _sessions.isEmpty
                      ? _buildEmptyState()
                      : _buildSessionList(),
                ),
              ],
            ),
    );
  }

  Widget _buildTodayStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text('今日留白', style: LiubaiTypography.caption),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_todayStats!.totalDuration),
            style: LiubaiTypography.h1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('次数', '${_todayStats!.sessionCount}'),
              _buildStatItem('完成', '${_todayStats!.completedCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: LiubaiTypography.h2),
        const SizedBox(height: 4),
        Text(label, style: LiubaiTypography.caption),
      ],
    );
  }

  Widget _buildTagFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '筛选标签',
            style: LiubaiTypography.caption,
          ),
          const SizedBox(height: 8),
          SceneTagSelector(
            selectedTagId: _selectedFilterTagId,
            onTagSelected: _onFilterTagSelected,
            showAddButton: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: LiubaiColors.pineSmokeGray,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无留白记录',
            style: LiubaiTypography.body,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilterTagId != null ? '该标签下暂无记录' : '开始你的第一次留白吧',
            style: LiubaiTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(LiubaiSession session) {
    final tag = _getTagById(session.sceneTagId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // 时间和标签
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatDate(session.startTime),
                      style: LiubaiTypography.caption,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(session.startTime),
                      style: LiubaiTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // 标签
                    if (tag != null) ...[
                      SceneTagChip(tag: tag, isSmall: true),
                      const SizedBox(width: 8),
                    ],
                    // 时长
                    Text(
                      session.actualDuration != null
                          ? _formatDuration(session.actualDuration!)
                          : _formatDuration(session.plannedDuration),
                      style: LiubaiTypography.body,
                    ),
                    const SizedBox(width: 8),
                    // 完成状态
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: session.isCompleted
                            ? LiubaiColors.inkBlack.withOpacity(0.1)
                            : LiubaiColors.pineSmokeGray.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        session.isCompleted ? '已完成' : '未完成',
                        style: TextStyle(
                          fontSize: 10,
                          color: session.isCompleted
                              ? LiubaiColors.inkBlack
                              : LiubaiColors.pineSmokeGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 删除按钮
          IconButton(
            onPressed: () => _deleteSession(session.id!),
            icon: const Icon(
              Icons.delete_outline,
              color: LiubaiColors.pineSmokeGray,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSession(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，是否确认？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteSession(id);
      _loadData();
    }
  }
}
