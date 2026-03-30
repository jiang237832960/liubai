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
        borderRadius: BorderRadius.circular(8),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '近7天',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '近30天',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
    if (_selectedTab == 0) {
      return _buildWeekChart();
    } else {
      return _buildMonthChart();
    }
  }

  // 7天趋势图 - 柱状图
  Widget _buildWeekChart() {
    if (_weekStats.isEmpty) {
      return _buildEmptyChart('近7天暂无数据');
    }

    // 计算连续天数和总时长
    int streakDays = _calculateStreak(_weekStats);
    int totalDuration = _weekStats.fold(0, (sum, s) => sum + s.totalDuration);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 核心激励数据
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('连续专注', style: LiubaiTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      '$streakDays天',
                      style: LiubaiTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('本周总时长', style: LiubaiTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(totalDuration),
                      style: LiubaiTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 柱状图
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _weekStats.map((stat) {
                return _buildWeekBar(stat);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekBar(DailyStats stat) {
    final maxDuration = _weekStats.map((s) => s.totalDuration).reduce((a, b) => a > b ? a : b);
    final maxHeight = 100.0;
    final height = maxDuration > 0
        ? (stat.totalDuration / maxDuration) * maxHeight
        : 0.0;
    final dayName = _getDayName(stat.date);

    return Expanded(
      child: GestureDetector(
        onTap: () => _showDayDetail(stat),
        child: Column(
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

            // 柱子
            Container(
              height: height > 0 ? height : 4,
              decoration: BoxDecoration(
                color: stat.totalDuration > 0
                    ? LiubaiColors.inkBlack
                    : LiubaiColors.lightInkGray,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),

            // 星期标签
            Text(
              dayName,
              style: const TextStyle(
                fontSize: 12,
                color: LiubaiColors.pineSmokeGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 30天趋势图 - 热力图日历
  Widget _buildMonthChart() {
    if (_monthStats.isEmpty) {
      return _buildEmptyChart('近30天暂无数据');
    }

    // 计算连续天数和总时长
    int streakDays = _calculateStreak(_monthStats);
    int totalDuration = _monthStats.fold(0, (sum, s) => sum + s.totalDuration);
    int activeDays = _monthStats.where((s) => s.totalDuration > 0).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 核心激励数据
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('连续专注', style: LiubaiTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      '$streakDays天',
                      style: LiubaiTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('本月总时长', style: LiubaiTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      _formatDuration(totalDuration),
                      style: LiubaiTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('专注天数', style: LiubaiTypography.caption),
                    const SizedBox(height: 4),
                    Text(
                      '$activeDays天',
                      style: LiubaiTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 星期标题
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 30, child: Text('周一', style: TextStyle(fontSize: 10, color: LiubaiColors.pineSmokeGray))),
              SizedBox(width: 30, child: Text('周二', style: TextStyle(fontSize: 10, color: LiubaiColors.pineSmokeGray))),
              SizedBox(width: 30, child: Text('周三', style: TextStyle(fontSize: 10, color: LiubaiColors.pineSmokeGray))),
              SizedBox(width: 30, child: Text('周四', style: TextStyle(fontSize: 10, color: LiubaiColors.pineSmokeGray))),
              SizedBox(width: 30, child: Text('周五', style: TextStyle(fontSize: 10, color: LiubaiColors.pineSmokeGray))),
              SizedBox(width: 30, child: Text('周六', style: TextStyle(fontSize: 10, color: LiubaiColors.pineSmokeGray))),
              SizedBox(width: 30, child: Text('周日', style: TextStyle(fontSize: 10, color: LiubaiColors.pineSmokeGray))),
            ],
          ),
          const SizedBox(height: 8),

          // 热力图网格
          Expanded(
            child: _buildHeatmapGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    if (_monthStats.isEmpty) return const SizedBox();

    // 找到第一个日期是星期几
    final firstDate = DateTime.parse(_monthStats.first.date);
    final firstWeekday = firstDate.weekday; // 1=周一, 7=周日

    // 计算最大时长用于颜色渐变
    final maxDuration = _monthStats.map((s) => s.totalDuration).reduce((a, b) => a > b ? a : b);

    List<Widget> rows = [];
    List<DailyStats?> weekCells = [];

    // 填充第一周前面空白的日期
    for (int i = 1; i < firstWeekday; i++) {
      weekCells.add(null);
    }

    for (var stat in _monthStats) {
      weekCells.add(stat);

      if (weekCells.length == 7) {
        rows.add(_buildHeatmapRow(weekCells, maxDuration));
        weekCells = [];
      }
    }

    // 处理最后一周
    if (weekCells.isNotEmpty) {
      while (weekCells.length < 7) {
        weekCells.add(null);
      }
      rows.add(_buildHeatmapRow(weekCells, maxDuration));
    }

    return Column(
      children: rows.map((row) => Expanded(child: row)).toList(),
    );
  }

  Widget _buildHeatmapRow(List<DailyStats?> weekCells, int maxDuration) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekCells.map((stat) {
        if (stat == null) {
          return const Expanded(child: SizedBox());
        }
        return Expanded(child: _buildHeatmapCell(stat, maxDuration));
      }).toList(),
    );
  }

  Widget _buildHeatmapCell(DailyStats stat, int maxDuration) {
    final intensity = maxDuration > 0 ? (stat.totalDuration / maxDuration) : 0.0;
    final color = stat.totalDuration > 0
        ? LiubaiColors.inkBlack.withOpacity(0.3 + intensity * 0.7)
        : LiubaiColors.lightInkGray.withOpacity(0.3);

    return GestureDetector(
      onTap: () => _showDayDetail(stat),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Center(
            child: Text(
              int.parse(stat.date.split('-').last).toString(),
              style: TextStyle(
                fontSize: 10,
                color: stat.totalDuration > 0
                    ? LiubaiColors.liubaiWhite
                    : LiubaiColors.pineSmokeGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(color: LiubaiColors.lightInkGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(message, style: LiubaiTypography.caption),
      ),
    );
  }

  void _showDayDetail(DailyStats stat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LiubaiColors.liubaiWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${stat.date.split('-')[1]}月${stat.date.split('-').last}日',
              style: LiubaiTypography.h2,
            ),
            const SizedBox(height: 24),
            _buildDetailRow('专注时长', _formatDuration(stat.totalDuration)),
            _buildDetailRow('专注次数', '${stat.sessionCount}次'),
            _buildDetailRow('完成次数', '${stat.completedCount}次'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: LiubaiTypography.body),
          Text(value, style: LiubaiTypography.h2),
        ],
      ),
    );
  }

  int _calculateStreak(List<DailyStats> stats) {
    if (stats.isEmpty) return 0;

    int streak = 0;
    // 从最后一天往前数
    for (int i = stats.length - 1; i >= 0; i--) {
      if (stats[i].totalDuration > 0) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String _getDayName(String dateStr) {
    final date = DateTime.parse(dateStr);
    const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[date.weekday - 1];
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
