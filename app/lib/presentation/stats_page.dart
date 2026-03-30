import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../data/database.dart';
import '../data/models.dart';
import 'widgets/scene_tag_selector.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  List<DailyStats> _weekStats = [];
  List<DailyStats> _monthStats = [];
  Map<String, dynamic> _totalStats = {};
  List<Map<String, dynamic>> _tagDistribution = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0: 周, 1: 月

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(StatsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final weekStats = await DatabaseHelper.instance.getLast7DaysStats();
      final monthStats = await DatabaseHelper.instance.getLast30DaysStats();
      final totalStats = await DatabaseHelper.instance.getTotalStats();
      final tagDistribution = await DatabaseHelper.instance.getTagDistribution();

      setState(() {
        _weekStats = weekStats;
        _monthStats = monthStats;
        _totalStats = totalStats;
        _tagDistribution = tagDistribution;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  String _formatShortDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('留白统计', style: theme.textTheme.headlineMedium),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 总统计卡片
                  _buildTotalStatsCard(),

                  const SizedBox(height: 24),

                  // 标签分布
                  _buildTagDistribution(),

                  const SizedBox(height: 24),

                  // 切换标签
                  _buildTabSelector(),

                  const SizedBox(height: 24),

                  // 趋势图表
                  _buildTrendChart(),

                  const SizedBox(height: 24),

                  // 详细数据
                  _buildDetailStats(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildTotalStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text('总留白时长', style: LiubaiTypography.caption),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_totalStats['totalDuration'] ?? 0),
            style: LiubaiTypography.h1,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTotalStatItem('留白次数', '${_totalStats['totalSessions'] ?? 0}'),
              _buildTotalStatItem('完成次数', '${_totalStats['completedSessions'] ?? 0}'),
              _buildTotalStatItem('活跃天数', '${_totalStats['activeDays'] ?? 0}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: LiubaiTypography.h2),
        const SizedBox(height: 4),
        Text(label, style: LiubaiTypography.caption),
      ],
    );
  }

  Widget _buildTagDistribution() {
    if (_tagDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    // 计算总时长用于百分比
    final totalDuration = _tagDistribution.fold<int>(
      0,
      (sum, tag) => sum + (tag['totalDuration'] as int),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('场景分布', style: LiubaiTypography.body),
          const SizedBox(height: 16),
          // 横向条形图
          ..._tagDistribution.where((tag) => tag['totalDuration'] > 0).map((tag) {
            final percentage = totalDuration > 0
                ? (tag['totalDuration'] as int) / totalDuration
                : 0.0;
            return _buildTagBar(
              tag['name'] as String,
              tag['color'] as int,
              tag['totalDuration'] as int,
              tag['sessionCount'] as int,
              percentage,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTagBar(
    String name,
    int colorValue,
    int duration,
    int count,
    double percentage,
  ) {
    final color = Color(colorValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(name, style: LiubaiTypography.body),
                ],
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: LiubaiTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 进度条
          Stack(
            children: [
              // 背景
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: LiubaiColors.lightInkGray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // 进度
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * 0.7 * percentage,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 详情
          Text(
            '${_formatDuration(duration)} · $count次',
            style: const TextStyle(
              fontSize: 12,
              color: LiubaiColors.pineSmokeGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: LiubaiColors.lightInkGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? LiubaiColors.inkBlack
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '近7天',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 0
                        ? LiubaiColors.liubaiWhite
                        : LiubaiColors.inkBlack,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? LiubaiColors.inkBlack
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '近30天',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedTab == 1
                        ? LiubaiColors.liubaiWhite
                        : LiubaiColors.inkBlack,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    final stats = _selectedTab == 0 ? _weekStats : _monthStats;

    if (stats.isEmpty || stats.every((s) => s.totalDuration == 0)) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: LiubaiColors.liubaiWhite,
          border: Border.all(color: LiubaiColors.lightInkGray),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('暂无数据', style: LiubaiTypography.caption),
        ),
      );
    }

    final maxDuration = stats.map((s) => s.totalDuration).reduce((a, b) => a > b ? a : b);
    final maxHeight = 150.0;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedTab == 0 ? '近7天趋势' : '近30天趋势',
            style: LiubaiTypography.body,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: stats.map((stat) {
                final height = maxDuration > 0
                    ? (stat.totalDuration / maxDuration) * maxHeight
                    : 0.0;
                return _buildBar(stat, height, maxHeight);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(DailyStats stat, double height, double maxHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 时长标签
        if (stat.totalDuration > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              stat.totalDuration >= 60
                  ? '${stat.totalDuration ~/ 60}h'
                  : '${stat.totalDuration}m',
              style: const TextStyle(
                fontSize: 10,
                color: LiubaiColors.pineSmokeGray,
              ),
            ),
          ),

        // 柱状图
        Container(
          width: _selectedTab == 0 ? 24 : 8,
          height: height > 0 ? height : 4,
          decoration: BoxDecoration(
            color: stat.totalDuration > 0
                ? LiubaiColors.inkBlack
                : LiubaiColors.lightInkGray,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        const SizedBox(height: 8),

        // 日期标签
        Text(
          _formatShortDate(stat.date),
          style: const TextStyle(
            fontSize: 10,
            color: LiubaiColors.pineSmokeGray,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailStats() {
    final stats = _selectedTab == 0 ? _weekStats : _monthStats;
    final totalDuration = stats.fold<int>(0, (sum, s) => sum + s.totalDuration);
    final totalSessions = stats.fold<int>(0, (sum, s) => sum + s.sessionCount);
    final avgDuration = totalSessions > 0 ? totalDuration ~/ totalSessions : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedTab == 0 ? '近7天详情' : '近30天详情',
            style: LiubaiTypography.body,
          ),
          const SizedBox(height: 16),
          _buildDetailItem('总时长', _formatDuration(totalDuration)),
          _buildDetailItem('总次数', '$totalSessions次'),
          _buildDetailItem('平均时长', _formatDuration(avgDuration)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: LiubaiTypography.caption),
          Text(value, style: LiubaiTypography.body),
        ],
      ),
    );
  }
}
