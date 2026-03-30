import 'dart:async';
import 'package:flutter/material.dart';
import '../core/logger.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/database.dart';
import '../data/models.dart';
import '../data/models/scene_template.dart';
import '../services/audio_service.dart';
import '../services/template_service.dart';
import '../services/timeline_engine.dart';
import 'log_page.dart';
import 'settings_page.dart';
import 'template_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _templateService = TemplateService();
  final _audioService = AudioService();
  final _timelineEngine = TimelineEngine();
  
  List<SceneTemplate> _templates = [];
  SceneTemplate? _activeTemplate;
  bool _isLoading = true;
  TimelineStatus _timelineStatus = TimelineStatus.idle;
  int _elapsedMs = 0;
  int _currentCycle = 1;
  int _totalCycles = 1;
  SegmentType? _currentSegmentType;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _audioService.initialize();
    await _loadTemplates();
    _setupTimelineCallbacks();
  }

  void _setupTimelineCallbacks() {
    _timelineEngine.onTick = (state) {
      if (mounted) {
        setState(() {
          _elapsedMs = state.elapsedMs;
          _currentCycle = state.currentCycle;
          _currentSegmentType = state.currentSegmentType;
        });
      }
    };

    _timelineEngine.onPhaseChange = (state) {
      if (mounted) {
        setState(() {
          _currentSegmentType = state.currentSegmentType;
          _currentCycle = state.currentCycle;
          _elapsedMs = state.elapsedMs;
          _timelineStatus = state.status;
          _activeTemplate = state.template;
          _totalCycles = state.totalCycles;
        });
        _audioService.stop();
      }
    };

    _timelineEngine.onComplete = (state) {
      if (mounted) {
        setState(() {
          _timelineStatus = TimelineStatus.completed;
        });
        _audioService.stop();
      }
    };
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _templateService.getAllTemplates();
      if (mounted) {
        setState(() {
          _templates = templates;
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.e('加载模板失败', tag: 'HomePage', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timelineEngine.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: _timelineStatus == TimelineStatus.idle
            ? _buildIdleView()
            : _buildRunningView(),
      ),
    );
  }

  Widget _buildIdleView() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _templates.isEmpty
                  ? _buildEmptyState()
                  : _buildTemplateList(),
        ),
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 64,
            color: LiubaiColors.pineSmokeGray,
          ),
          const SizedBox(height: 16),
          const Text(
            '创建你的第一个专注场景',
            style: LiubaiTypography.body,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createTemplate,
            icon: const Icon(Icons.add),
            label: const Text('创建场景'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('选择场景开始专注', style: LiubaiTypography.caption),
        const SizedBox(height: 16),
        ..._templates.map((t) => _buildTemplateCard(t)),
        const SizedBox(height: 16),
        _buildAddTemplateCard(),
      ],
    );
  }

  Widget _buildTemplateCard(SceneTemplate template) {
    final workMinutes = template.workDurationMs ~/ 60000;
    final restMinutes = template.restDurationMs ~/ 60000;
    final totalMinutes = (workMinutes + restMinutes) * template.cycles;

    return GestureDetector(
      onTap: () => _startTemplate(template),
      onLongPress: () => _showTemplateOptions(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LiubaiColors.liubaiWhite,
          border: Border.all(color: LiubaiColors.lightInkGray),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(template.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.name, style: LiubaiTypography.body),
                  const SizedBox(height: 4),
                  Text(
                    '${template.cycles}轮 · ${workMinutes}分钟工作 · ${restMinutes}分钟休息',
                    style: LiubaiTypography.caption,
                  ),
                  Text(
                    '总时长约 ${totalMinutes}分钟',
                    style: LiubaiTypography.caption,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _editTemplate(template),
              icon: const Icon(Icons.edit_outlined),
              color: LiubaiColors.pineSmokeGray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTemplateCard() {
    return GestureDetector(
      onTap: _createTemplate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: LiubaiColors.lightInkGray,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: LiubaiColors.pineSmokeGray),
            const SizedBox(width: 8),
            Text(
              '创建新场景',
              style: LiubaiTypography.body.copyWith(
                color: LiubaiColors.pineSmokeGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunningView() {
    final template = _activeTemplate!;
    final workMinutes = template.workDurationMs ~/ 60000;
    final restMinutes = template.restDurationMs ~/ 60000;
    final phaseMs = _currentSegmentType == SegmentType.work 
        ? template.workDurationMs 
        : template.restDurationMs;
    final phaseElapsed = _currentSegmentType == SegmentType.work
        ? _elapsedMs % (template.workDurationMs + template.restDurationMs)
        : (_elapsedMs - template.workDurationMs) % (template.workDurationMs + template.restDurationMs);
    
    final progress = phaseMs > 0 ? phaseElapsed / phaseMs : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              template.emoji,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(template.name, style: LiubaiTypography.h2),
            const SizedBox(height: 8),
            Text(
              '第$_currentCycle / $_totalCycles 轮',
              style: LiubaiTypography.caption,
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: LiubaiColors.lightInkGray,
                            valueColor: AlwaysStoppedAnimation(
                              _currentSegmentType == SegmentType.work
                                  ? LiubaiColors.inkBlack
                                  : LiubaiColors.cinnabarRed,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              _currentSegmentType == SegmentType.work ? '专注' : '休息',
                              style: LiubaiTypography.caption,
                            ),
                            Text(
                              FormatUtils.formatDuration((phaseMs - phaseElapsed) ~/ 60000),
                              style: LiubaiTypography.timer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _pauseTemplate,
                  child: Text(_timelineStatus == TimelineStatus.running ? '暂停' : '继续'),
                ),
                const SizedBox(width: 32),
                TextButton(
                  onPressed: _stopTemplate,
                  child: const Text('结束'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('场景', Icons.circle_outlined, true),
          _buildNavItem('日志', Icons.menu_book_outlined, false),
          _buildNavItem('设置', Icons.settings_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isSelected) {
    final theme = Theme.of(context);
    final color = isSelected
        ? LiubaiColors.inkBlack
        : LiubaiColors.pineSmokeGray;

    return GestureDetector(
      onTap: () {
        if (label == '日志') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogPage()),
          );
        } else if (label == '设置') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  void _createTemplate() async {
    final result = await Navigator.push<SceneTemplate>(
      context,
      MaterialPageRoute(builder: (_) => const TemplateEditorPage()),
    );
    if (result != null) {
      _loadTemplates();
    }
  }

  void _editTemplate(SceneTemplate template) async {
    final result = await Navigator.push<SceneTemplate>(
      context,
      MaterialPageRoute(builder: (_) => TemplateEditorPage(template: template)),
    );
    if (result != null) {
      _loadTemplates();
    }
  }

  void _startTemplate(SceneTemplate template) async {
    _timelineEngine.loadTemplate(template);
    await _timelineEngine.start();
    
    setState(() {
      _activeTemplate = template;
      _timelineStatus = TimelineStatus.running;
      _totalCycles = template.cycles;
      _currentCycle = 1;
      _elapsedMs = 0;
    });
  }

  void _pauseTemplate() {
    if (_timelineStatus == TimelineStatus.running) {
      _timelineEngine.pause();
      _audioService.pause();
    } else if (_timelineStatus == TimelineStatus.paused) {
      _timelineEngine.resume();
      _audioService.resume();
    }
    setState(() {
      _timelineStatus = _timelineStatus == TimelineStatus.running
          ? TimelineStatus.paused
          : TimelineStatus.running;
    });
  }

  void _stopTemplate() async {
    await _timelineEngine.stop();
    await _audioService.stop();
    
    setState(() {
      _activeTemplate = null;
      _timelineStatus = TimelineStatus.idle;
    });
  }

  void _showTemplateOptions(SceneTemplate template) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(context);
                _editTemplate(template);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: LiubaiColors.cinnabarRed),
              title: const Text('删除', style: TextStyle(color: LiubaiColors.cinnabarRed)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('确认删除'),
                    content: Text('确定要删除 "${template.name}" 吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('删除'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _templateService.deleteTemplate(template.id);
                  _loadTemplates();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
