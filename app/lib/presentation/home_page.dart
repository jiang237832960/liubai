import 'dart:async';
import 'package:flutter/material.dart';
import '../core/logger.dart';
import '../core/theme.dart';
import '../core/utils.dart';
import '../data/database.dart';
import '../data/models.dart';
import '../data/models/scene_template.dart';
import '../services/audio_service.dart';
import 'log_page.dart';
import 'settings_page.dart';
import 'widgets/scene_tag_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TimerState _timerState = TimerState();
  Timer? _timer;
  int _defaultDuration = 25;
  int? _currentSessionId;
  SceneTag? _selectedTag;
  List<SceneTag> _tags = [];
  
  final AudioService _audioService = AudioService();
  SoundSource? _selectedAudioSource;
  bool _isAudioInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _loadSettings();
    _loadTags();
    await _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _audioService.initialize();
      if (mounted) {
        setState(() {
          _isAudioInitialized = true;
        });
      }
    } catch (e, stackTrace) {
      Logger.e('音频初始化失败', tag: 'HomePage', error: e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await DatabaseHelper.instance.getSettings();
      if (mounted) {
        setState(() {
          _defaultDuration = settings.defaultDuration;
          if (_timerState.isIdle) {
            _timerState = TimerState(
              total: Duration(minutes: settings.defaultDuration),
              remaining: Duration(minutes: settings.defaultDuration),
              sceneTagId: settings.defaultSceneTagId,
            );
          }
        });
      }
    } catch (e, stackTrace) {
      Logger.e('加载设置失败', tag: 'HomePage', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> _loadTags() async {
    try {
      final tags = await DatabaseHelper.instance.getAllSceneTags();
      if (mounted) {
        setState(() {
          _tags = tags;
          if (_timerState.sceneTagId != null) {
            _selectedTag = tags.firstWhere(
              (tag) => tag.id == _timerState.sceneTagId,
              orElse: () => tags.first,
            );
          }
        });
      }
    } catch (e, stackTrace) {
      Logger.e('加载标签失败', tag: 'HomePage', error: e, stackTrace: stackTrace);
    }
  }

  void _startTimerTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerState.remaining.inSeconds > 0) {
        setState(() {
          _timerState = _timerState.copyWith(
            remaining: Duration(
              seconds: _timerState.remaining.inSeconds - 1,
            ),
          );
        });
      } else {
        _completeTimer();
      }
    });
  }

  Future<void> _startTimer() async {
    try {
      final now = DateTime.now();
      
      if (_selectedAudioSource != null) {
        await _audioService.playSingle(_selectedAudioSource!);
      }
      
      final session = LiubaiSession(
        startTime: now,
        plannedDuration: _defaultDuration,
        sceneTagId: _timerState.sceneTagId,
        createdAt: now,
        updatedAt: now,
      );
      
      final id = await DatabaseHelper.instance.insertSession(session);
      
      if (!mounted) return;
      
      setState(() {
        _currentSessionId = id;
        _timerState = _timerState.copyWith(
          status: TimerStatus.running,
          startTime: now,
        );
      });

      _startTimerTick();
    } catch (e, stackTrace) {
      Logger.e('开始留白失败', tag: 'HomePage', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('开始留白失败: $e')),
        );
      }
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    _audioService.pause();
    if (mounted) {
      setState(() {
        _timerState = _timerState.copyWith(status: TimerStatus.paused);
      });
    }
  }

  void _resumeTimer() {
    _audioService.resume();
    if (mounted) {
      setState(() {
        _timerState = _timerState.copyWith(status: TimerStatus.running);
      });
    }
    _startTimerTick();
  }

  Future<void> _stopTimer() async {
    _timer?.cancel();
    await _audioService.stop();
    
    if (_currentSessionId != null) {
      final now = DateTime.now();
      final actualDuration = _timerState.total.inMinutes - _timerState.remaining.inMinutes;
      
      final session = LiubaiSession(
        id: _currentSessionId,
        startTime: _timerState.startTime!,
        endTime: now,
        plannedDuration: _defaultDuration,
        actualDuration: actualDuration > 0 ? actualDuration : 0,
        isCompleted: false,
        sceneTagId: _timerState.sceneTagId,
        createdAt: _timerState.startTime!,
        updatedAt: now,
      );
      
      await DatabaseHelper.instance.updateSession(session);
    }
    
    if (mounted) {
      setState(() {
        _currentSessionId = null;
        _timerState = TimerState(
          total: Duration(minutes: _defaultDuration),
          remaining: Duration(minutes: _defaultDuration),
          sceneTagId: _timerState.sceneTagId,
        );
      });
    }
  }

  Future<void> _completeTimer() async {
    _timer?.cancel();
    await _audioService.stop();
    
    if (_currentSessionId != null) {
      final now = DateTime.now();
      
      final session = LiubaiSession(
        id: _currentSessionId,
        startTime: _timerState.startTime!,
        endTime: now,
        plannedDuration: _defaultDuration,
        actualDuration: _defaultDuration,
        isCompleted: true,
        sceneTagId: _timerState.sceneTagId,
        createdAt: _timerState.startTime!,
        updatedAt: now,
      );
      
      await DatabaseHelper.instance.updateSession(session);
    }
    
    if (mounted) {
      setState(() {
        _timerState = _timerState.copyWith(status: TimerStatus.completed);
      });
    }
  }

  void _onTagSelected(int? tagId) {
    setState(() {
      _timerState = _timerState.copyWith(sceneTagId: tagId);
      _selectedTag = tagId != null
          ? _tags.firstWhere(
              (tag) => tag.id == tagId,
              orElse: () => _tags.first,
            )
          : null;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getStatusText() {
    switch (_timerState.status) {
      case TimerStatus.idle:
        return '';
      case TimerStatus.running:
        return '留白中...';
      case TimerStatus.paused:
        return '已暂停';
      case TimerStatus.completed:
        return '留白完成';
    }
  }

  void _navigateToLog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogPage()),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    ).then((_) => _loadSettings());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(flex: 2, child: SizedBox()),
            
            if (_timerState.isIdle)
              const Text(
                '留 白',
                style: LiubaiTypography.brand,
              ),
            
            if (!_timerState.isIdle)
              Column(
                children: [
                  Text(
                    _formatDuration(_timerState.remaining),
                    style: LiubaiTypography.timer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getStatusText(),
                    style: LiubaiTypography.caption,
                  ),
                  if (_selectedTag != null) ...[
                    const SizedBox(height: 16),
                    SceneTagChip(tag: _selectedTag!),
                  ],
                ],
              ),
            
            const Expanded(flex: 2, child: SizedBox()),
            
            if (_timerState.isIdle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '选择场景',
                      style: LiubaiTypography.caption,
                    ),
                    const SizedBox(height: 12),
                    SceneTagSelector(
                      selectedTagId: _timerState.sceneTagId,
                      onTagSelected: _onTagSelected,
                      onTagsChanged: _loadTags,
                      showAddButton: true,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '选择音频',
                      style: LiubaiTypography.caption,
                    ),
                    const SizedBox(height: 12),
                    if (_isAudioInitialized)
                      _buildAudioSelector(),
                  ],
                ),
              ),
            
            const Expanded(flex: 1, child: SizedBox()),
            
            _buildActionButton(),
            
            const Expanded(flex: 2, child: SizedBox()),
            
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (_timerState.isIdle) {
      return ElevatedButton(
        onPressed: _startTimer,
        child: const Text('开始留白'),
      );
    } else if (_timerState.isRunning) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: _pauseTimer,
            child: const Text('暂停'),
          ),
          const SizedBox(width: 32),
          TextButton(
            onPressed: _stopTimer,
            child: const Text('结束'),
          ),
        ],
      );
    } else if (_timerState.isPaused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _resumeTimer,
            child: const Text('继续'),
          ),
          const SizedBox(width: 32),
          TextButton(
            onPressed: _stopTimer,
            child: const Text('结束'),
          ),
        ],
      );
    } else if (_timerState.isCompleted) {
      return Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: LiubaiColors.inkBlack,
          ),
          const SizedBox(height: 16),
          Text(
            '${_timerState.total.inMinutes}分钟',
            style: LiubaiTypography.h2,
          ),
          if (_selectedTag != null) ...[
            const SizedBox(height: 8),
            SceneTagChip(tag: _selectedTag!),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentSessionId = null;
                _timerState = TimerState(
                  total: Duration(minutes: _defaultDuration),
                  remaining: Duration(minutes: _defaultDuration),
                  sceneTagId: _timerState.sceneTagId,
                );
              });
            },
            child: const Text('再次留白'),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem('留白', Icons.circle_outlined, true),
          _buildNavItem('日志', Icons.menu_book_outlined, false),
          _buildNavItem('设置', Icons.settings_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isSelected) {
    final theme = Theme.of(context);
    final selectedColor = theme.brightness == Brightness.dark 
        ? LiubaiColors.liubaiWhite 
        : LiubaiColors.inkBlack;
    final unselectedColor = LiubaiColors.pineSmokeGray;
    
    return GestureDetector(
      onTap: () {
        if (label == '日志') {
          _navigateToLog();
        } else if (label == '设置') {
          _navigateToSettings();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSelector() {
    final audioSources = BuiltInAudioLibrary.sources;
    
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: audioSources.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAudioItem(null, '无');
          }
          final source = audioSources[index - 1];
          return _buildAudioItem(source, source.emoji);
        },
      ),
    );
  }

  Widget _buildAudioItem(SoundSource? source, String emoji) {
    final isSelected = _selectedAudioSource?.id == source?.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAudioSource = source;
        });
        if (source != null && _timerState.isIdle) {
          _audioService.playSingle(source);
        }
      },
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? LiubaiColors.inkBlack.withOpacity(0.1)
              : LiubaiColors.liubaiWhite,
          border: Border.all(
            color: isSelected 
                ? LiubaiColors.inkBlack 
                : LiubaiColors.lightInkGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
            if (source != null) ...[
              const SizedBox(height: 4),
              Text(
                source.name,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected 
                      ? LiubaiColors.inkBlack 
                      : LiubaiColors.pineSmokeGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (source == null) ...[
              const SizedBox(height: 4),
              Text(
                '无',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected 
                      ? LiubaiColors.inkBlack 
                      : LiubaiColors.pineSmokeGray,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
