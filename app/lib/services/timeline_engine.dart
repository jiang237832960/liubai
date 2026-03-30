import 'dart:async';
import '../core/logger.dart';
import '../data/models/scene_template.dart';
import 'audio_service.dart';

enum TimelineStatus {
  idle,
  running,
  paused,
  completed,
}

class TimelineState {
  final SceneTemplate? template;
  final TimelineStatus status;
  final int currentCycle;
  final int totalCycles;
  final int elapsedMs;
  final SegmentType? currentSegmentType;
  final int? currentSegmentIndex;

  const TimelineState({
    this.template,
    required this.status,
    required this.currentCycle,
    required this.totalCycles,
    required this.elapsedMs,
    this.currentSegmentType,
    this.currentSegmentIndex,
  });

  const TimelineState.initial()
      : template = null,
        status = TimelineStatus.idle,
        currentCycle = 0,
        totalCycles = 0,
        elapsedMs = 0,
        currentSegmentType = null,
        currentSegmentIndex = null;

  TimelineState copyWith({
    SceneTemplate? template,
    TimelineStatus? status,
    int? currentCycle,
    int? totalCycles,
    int? elapsedMs,
    SegmentType? currentSegmentType,
    int? currentSegmentIndex,
  }) {
    return TimelineState(
      template: template ?? this.template,
      status: status ?? this.status,
      currentCycle: currentCycle ?? this.currentCycle,
      totalCycles: totalCycles ?? this.totalCycles,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      currentSegmentType: currentSegmentType ?? this.currentSegmentType,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
    );
  }
}

typedef TimelineCallback = void Function(TimelineState state);

class TimelineEngine {
  static final TimelineEngine _instance = TimelineEngine._internal();
  factory TimelineEngine() => _instance;
  TimelineEngine._internal();

  static const String _tag = 'Timeline';

  final AudioService _audioService = AudioService();
  Timer? _timer;
  TimelineState _state = const TimelineState.initial();
  SceneTemplate? _template;
  List<_SegmentPhase> _phases = [];
  int _currentPhaseIndex = 0;

  TimelineCallback? onTick;
  TimelineCallback? onPhaseChange;
  TimelineCallback? onCycleChange;
  TimelineCallback? onComplete;

  TimelineState get state => _state;
  SceneTemplate? get template => _template;
  bool get isRunning => _state.status == TimelineStatus.running;

  void loadTemplate(SceneTemplate template) {
    _template = template;
    _buildPhases(template);
    Logger.i('加载场景模板: ${template.name}', tag: _tag);
  }

  void _buildPhases(SceneTemplate template) {
    _phases = [];
    int offset = 0;

    for (int cycle = 1; cycle <= template.cycles; cycle++) {
      _phases.add(_SegmentPhase(
        type: SegmentType.work,
        cycle: cycle,
        startOffset: offset,
        duration: template.workDurationMs,
        audioTracks: template.audioTracks,
      ));
      offset += template.workDurationMs;

      if (cycle < template.cycles || template.restDurationMs > 0) {
        _phases.add(_SegmentPhase(
          type: SegmentType.rest,
          cycle: cycle,
          startOffset: offset,
          duration: template.restDurationMs,
          audioTracks: template.audioTracks,
        ));
        offset += template.restDurationMs;
      }
    }
  }

  Future<void> start() async {
    if (_template == null || _phases.isEmpty) {
      Logger.e('场景模板未加载', tag: _tag);
      return;
    }

    try {
      _state = TimelineState(
        template: _template,
        status: TimelineStatus.running,
        currentCycle: 1,
        totalCycles: _template!.cycles,
        elapsedMs: 0,
        currentSegmentType: SegmentType.work,
        currentSegmentIndex: 0,
      );

      _currentPhaseIndex = 0;
      await _playCurrentPhase();
      _startTick();

      Logger.i('时间轴开始: ${_template!.name}', tag: _tag);
    } catch (e, stackTrace) {
      Logger.e('时间轴启动失败', tag: _tag, error: e, stackTrace: stackTrace);
      _state = const TimelineState.initial();
      rethrow;
    }
  }

  void pause() {
    if (_state.status != TimelineStatus.running) return;

    _timer?.cancel();
    _audioService.pause();
    _state = _state.copyWith(status: TimelineStatus.paused);

    Logger.i('时间轴暂停', tag: _tag);
  }

  void resume() {
    if (_state.status != TimelineStatus.paused) return;

    _audioService.resume();
    _state = _state.copyWith(status: TimelineStatus.running);
    _startTick();

    Logger.i('时间轴恢复', tag: _tag);
  }

  Future<void> stop() async {
    _timer?.cancel();
    await _audioService.stop();

    _state = const TimelineState.initial();
    _currentPhaseIndex = 0;

    Logger.i('时间轴停止', tag: _tag);
  }

  void _startTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _tick();
    });
  }

  void _tick() {
    if (_state.status != TimelineStatus.running) return;

    final newElapsed = _state.elapsedMs + 100;
    final currentPhase = _phases[_currentPhaseIndex];

    if (newElapsed >= currentPhase.endOffset) {
      _advancePhase();
    } else {
      _state = _state.copyWith(elapsedMs: newElapsed);
      onTick?.call(_state);
    }
  }

  void _advancePhase() {
    if (_currentPhaseIndex < _phases.length - 1) {
      _currentPhaseIndex++;
      final nextPhase = _phases[_currentPhaseIndex];
      
      final newCycle = nextPhase.cycle;
      final cycleChanged = newCycle != _state.currentCycle;

      _state = _state.copyWith(
        elapsedMs: nextPhase.startOffset,
        currentSegmentType: nextPhase.type,
        currentSegmentIndex: _currentPhaseIndex,
        currentCycle: newCycle,
      );

      _playCurrentPhase();

      if (cycleChanged) {
        onCycleChange?.call(_state);
      }

      onPhaseChange?.call(_state);
      Logger.i('阶段切换: ${nextPhase.type.name} 第${newCycle}轮', tag: _tag);
    } else {
      _complete();
    }
  }

  Future<void> _playCurrentPhase() async {
    final phase = _phases[_currentPhaseIndex];
    
    if (phase.audioTracks.isEmpty) {
      await _audioService.stop();
      return;
    }

    final tracksToPlay = phase.audioTracks.where((t) {
      return t.soundSource.sourceType == SoundSourceType.builtIn || t.soundSource.filePath != null;
    }).toList();

    if (tracksToPlay.isEmpty) {
      await _audioService.stop();
      return;
    }

    try {
      await _audioService.playTracks(tracksToPlay);
    } catch (e) {
      Logger.e('播放轨道失败', tag: _tag, error: e);
    }
  }

  void _complete() {
    _timer?.cancel();
    _audioService.stop();

    _state = _state.copyWith(
      status: TimelineStatus.completed,
      elapsedMs: _phases.last.endOffset,
    );

    onComplete?.call(_state);
    Logger.i('时间轴完成', tag: _tag);
  }

  void dispose() {
    _timer?.cancel();
    _audioService.stop();
    _state = const TimelineState.initial();
    _phases = [];
    _currentPhaseIndex = 0;
    _template = null;
    Logger.i('时间轴引擎已释放', tag: _tag);
  }
}

class _SegmentPhase {
  final SegmentType type;
  final int cycle;
  final int startOffset;
  final int duration;
  final List<AudioTrack> audioTracks;

  const _SegmentPhase({
    required this.type,
    required this.cycle,
    required this.startOffset,
    required this.duration,
    required this.audioTracks,
  });

  int get endOffset => startOffset + duration;
}
