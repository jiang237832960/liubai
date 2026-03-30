import 'dart:async';
import 'package:flutter/material.dart';
import '../core/logger.dart';
import '../core/theme.dart';
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
  bool _showSceneSelector = false;
  TimelineStatus _timelineStatus = TimelineStatus.idle;
  int _elapsedMs = 0;
  int _currentCycle = 1;
  int _totalCycles = 1;
  SegmentType? _currentSegmentType;
  DateTime? _sessionStartTime;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _audioService.initialize();
    await _loadTemplates();
    _setupCallbacks();
  }

  void _setupCallbacks() {
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
          _activeTemplate = _timelineEngine.template;
          _totalCycles = state.totalCycles;
        });
        _audioService.stop();
      }
    };

    _timelineEngine.onComplete = (state) {
      if (mounted) {
        setState(() => _timelineStatus = TimelineStatus.completed);
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
      Logger.e('加载模板失败', tag: 'HomePage');
      if (mounted) setState(() => _isLoading = false);
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
    return Scaffold(
      backgroundColor: LiubaiColors.liubaiWhite,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_timelineStatus != TimelineStatus.idle) {
      return _buildRunningView();
    }
    
    if (_showSceneSelector) {
      return _buildSceneSelectorView();
    }
    
    return _buildIdleView();
  }

  Widget _buildIdleView() {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 2),
          const Text('留白', style: LiubaiTypography.brand),
          const Spacer(flex: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _templates.isEmpty ? _createTemplate : () => setState(() => _showSceneSelector = true),
                child: Text(_templates.isEmpty ? '创建场景' : '开始留白'),
              ),
            ),
          ),
          const Spacer(flex: 2),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildSceneSelectorView() {
    return SafeArea(
      child: Column(
        children: [
          _buildSceneSelectorHeader(),
          Expanded(child: _buildSceneList()),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildSceneSelectorHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showSceneSelector = false),
            color: LiubaiColors.pineSmokeGray,
          ),
          const Text('选择场景', style: LiubaiTypography.h2),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _createTemplate,
            color: LiubaiColors.pineSmokeGray,
          ),
        ],
      ),
    );
  }

  Widget _buildSceneList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.spa_outlined,
              size: 48,
              color: LiubaiColors.lightInkGray,
            ),
            const SizedBox(height: 16),
            Text(
              '创建你的专注场景',
              style: LiubaiTypography.caption,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _templates.length,
      itemBuilder: (context, index) => _buildTemplateItem(_templates[index]),
    );
  }

  Widget _buildTemplateItem(SceneTemplate template) {
    return GestureDetector(
      onTap: () => _startTemplate(template),
      onLongPress: () => _showOptions(template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: LiubaiColors.lightInkGray),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(template.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.name, style: LiubaiTypography.body),
                  const SizedBox(height: 4),
                  Text(
                    '${template.cycles}轮 · ${template.workDurationMs ~/ 60000}分钟/轮',
                    style: LiubaiTypography.caption,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_outline,
              color: LiubaiColors.pineSmokeGray,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunningView() {
    final template = _activeTemplate!;
    final phaseMs = _currentSegmentType == SegmentType.work
        ? template.workDurationMs
        : template.restDurationMs;
    final cyclePos = _elapsedMs % (template.workDurationMs + template.restDurationMs);
    final phaseElapsed = _currentSegmentType == SegmentType.work
        ? cyclePos
        : (cyclePos - template.workDurationMs).clamp(0, template.restDurationMs);
    final progress = phaseMs > 0 ? phaseElapsed / phaseMs : 0.0;
    final remaining = phaseMs - phaseElapsed;
    final minutes = remaining ~/ 60000;
    final seconds = (remaining % 60000) ~/ 1000;

    return Scaffold(
      backgroundColor: LiubaiColors.liubaiWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(template.emoji, style: const TextStyle(fontSize: 20)),
                  Text(template.name, style: LiubaiTypography.body),
                  Text(
                    '${_currentSegmentType == SegmentType.work ? '专注' : '休息'} · ${_currentCycle}/$_totalCycles',
                    style: LiubaiTypography.caption,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      height: 260,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 2,
                        backgroundColor: LiubaiColors.lightInkGray.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation(LiubaiColors.inkBlack),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                          style: LiubaiTypography.timer.copyWith(
                            fontSize: 56,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentSegmentType == SegmentType.work ? '专注中' : '休息中',
                          style: LiubaiTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _pauseTemplate,
                    child: Text(_timelineStatus == TimelineStatus.running ? '暂停' : '继续'),
                  ),
                  const SizedBox(width: 48),
                  TextButton(
                    onPressed: _stopTemplate,
                    child: const Text('结束'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('留白', Icons.spa_outlined, true),
          _buildNavItem('日志', Icons.menu_book_outlined, false),
          _buildNavItem('设置', Icons.settings_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isSelected) {
    final color = isSelected ? LiubaiColors.inkBlack : LiubaiColors.pineSmokeGray;

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
    if (result != null) _loadTemplates();
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
      _showSceneSelector = false;
      _sessionStartTime = DateTime.now();
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
    final template = _activeTemplate;
    final startTime = _sessionStartTime;
    final elapsed = _elapsedMs;
    final isCompleted = _timelineStatus == TimelineStatus.completed;
    
    await _timelineEngine.stop();
    await _audioService.stop();
    
    if (template != null && startTime != null) {
      final plannedMinutes = template.totalDurationMs ~/ 60000;
      final actualMinutes = elapsed ~/ 60000;
      
      final session = LiubaiSession(
        startTime: startTime,
        endTime: DateTime.now(),
        plannedDuration: plannedMinutes,
        actualDuration: actualMinutes,
        isCompleted: isCompleted,
        sceneTemplateId: template.id,
        createdAt: startTime,
        updatedAt: DateTime.now(),
      );
      
      try {
        await DatabaseHelper.instance.insertSession(session);
        Logger.i('保存留白会话成功', tag: 'HomePage');
      } catch (e) {
        Logger.e('保存留白会话失败', tag: 'HomePage', error: e);
      }
    }
    
    setState(() {
      _activeTemplate = null;
      _timelineStatus = TimelineStatus.idle;
      _sessionStartTime = null;
    });
  }

  void _showOptions(SceneTemplate template) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TemplateEditorPage(template: template),
                  ),
                ).then((r) => _loadTemplates());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: LiubaiColors.cinnabarRed),
              title: Text('删除', style: TextStyle(color: LiubaiColors.cinnabarRed)),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
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
                if (confirm == true) {
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
