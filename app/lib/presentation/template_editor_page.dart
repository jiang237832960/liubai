import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/theme.dart';
import '../core/logger.dart';
import '../data/models/scene_template.dart';
import '../services/template_service.dart';
import '../services/audio_service.dart';

class TemplateEditorPage extends StatefulWidget {
  final SceneTemplate? template;

  const TemplateEditorPage({super.key, this.template});

  @override
  State<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends State<TemplateEditorPage> {
  final _uuid = const Uuid();
  final _templateService = TemplateService();
  final _audioService = AudioService();

  late TextEditingController _nameController;
  String _emoji = '🍅';
  int _cycles = 4;
  int _workDuration = 25 * 60 * 1000;
  int _restDuration = 5 * 60 * 1000;
  List<SoundSource> _workAudios = [];
  List<SoundSource> _restAudios = [];

  bool get isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '我的专注');
    if (widget.template != null) {
      _emoji = widget.template!.emoji;
      _cycles = widget.template!.cycles;
      _workDuration = widget.template!.workDurationMs;
      _restDuration = widget.template!.restDurationMs;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiubaiColors.liubaiWhite,
      appBar: AppBar(
        title: Text(isEditing ? '编辑场景' : '创建场景'),
        backgroundColor: LiubaiColors.liubaiWhite,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveTemplate,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNameSection(),
          const SizedBox(height: 24),
          _buildCyclesSection(),
          const SizedBox(height: 24),
          _buildDurationSection(),
          const SizedBox(height: 24),
          _buildAudioSection('工作音频', _workAudios, true),
          const SizedBox(height: 24),
          _buildAudioSection('休息音频', _restAudios, false),
          const SizedBox(height: 32),
          _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('场景名称', style: LiubaiTypography.caption),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '输入场景名称',
            prefixIcon: GestureDetector(
              onTap: _showEmojiPicker,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCyclesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('循环次数', style: LiubaiTypography.caption),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCycleButton(2, '2轮'),
            const SizedBox(width: 12),
            _buildCycleButton(4, '4轮'),
            const SizedBox(width: 12),
            _buildCycleButton(6, '6轮'),
            const SizedBox(width: 12),
            _buildCycleButton(8, '8轮'),
          ],
        ),
      ],
    );
  }

  Widget _buildCycleButton(int cycles, String label) {
    final isSelected = _cycles == cycles;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _cycles = cycles),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? LiubaiColors.inkBlack : LiubaiColors.liubaiWhite,
            border: Border.all(
              color: isSelected ? LiubaiColors.inkBlack : LiubaiColors.lightInkGray,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? LiubaiColors.liubaiWhite : LiubaiColors.inkBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('专注/休息时长', style: LiubaiTypography.caption),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDurationPicker('工作', _workDuration, true),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDurationPicker('休息', _restDuration, false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationPicker(String label, int duration, bool isWork) {
    final minutes = duration ~/ 60000;
    final options = isWork 
        ? [15, 25, 30, 45, 60, 90]
        : [5, 10, 15, 20];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: LiubaiTypography.body),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: LiubaiColors.lightInkGray),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<int>(
            value: options.contains(minutes) ? minutes : options.first,
            isExpanded: true,
            underline: const SizedBox(),
            items: options.map((m) => DropdownMenuItem(
              value: m,
              child: Text('$m分钟'),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  if (isWork) {
                    _workDuration = value * 60000;
                  } else {
                    _restDuration = value * 60000;
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAudioSection(String title, List<SoundSource> selected, bool isWork) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: LiubaiTypography.caption),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAudioOption(null, '无', isWork),
              ...BuiltInAudioLibrary.sources.map(
                (s) => _buildAudioOption(s, s.emoji, isWork),
              ),
            ],
          ),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: selected.map((s) => Chip(
              label: Text('${s.emoji} ${s.name}'),
              onDeleted: () {
                setState(() {
                  if (isWork) {
                    _workAudios.remove(s);
                  } else {
                    _restAudios.remove(s);
                  }
                });
              },
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAudioOption(SoundSource? source, String emoji, bool isWork) {
    final isSelected = source != null && 
        (isWork ? _workAudios : _restAudios).any((s) => s.id == source.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (source == null) return;
          if (isWork) {
            if (isSelected) {
              _workAudios.removeWhere((s) => s.id == source.id);
            } else {
              _workAudios.add(source);
            }
          } else {
            if (isSelected) {
              _restAudios.removeWhere((s) => s.id == source.id);
            } else {
              _restAudios.add(source);
            }
          }
        });
      },
      child: Container(
        width: 64,
        margin: const EdgeInsets.only(right: 8),
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
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              source?.name ?? '无',
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final totalWork = (_workDuration / 60000 * _cycles).round();
    final totalRest = (_restDuration / 60000 * _cycles).round();
    final totalMinutes = totalWork + totalRest;

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
          const Text('预览', style: LiubaiTypography.body),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPreviewItem('总时长', '${totalMinutes}分钟'),
              _buildPreviewItem('循环', '$_cycles轮'),
              _buildPreviewItem('工作', '${totalWork}分钟'),
              _buildPreviewItem('休息', '${totalRest}分钟'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: LiubaiTypography.h2),
        const SizedBox(height: 4),
        Text(label, style: LiubaiTypography.caption),
      ],
    );
  }

  void _showEmojiPicker() async {
    final emojis = ['🍅', '📚', '💼', '🎯', '🧘', '💻', '✍️', '🎨', '🎵', '🌙'];
    
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择图标'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emojis.map((e) => GestureDetector(
            onTap: () => Navigator.pop(context, e),
            child: Text(e, style: const TextStyle(fontSize: 32)),
          )).toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() => _emoji = selected);
    }
  }

  Future<void> _saveTemplate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入场景名称')),
      );
      return;
    }

    try {
      final workTracks = _workAudios.map((s) => AudioTrack(
        id: _uuid.v4(),
        name: s.name,
        volume: 1.0,
        fadeInDuration: 500,
        fadeOutDuration: 500,
        soundSource: s,
      )).toList();

      final restTracks = _restAudios.map((s) => AudioTrack(
        id: _uuid.v4(),
        name: s.name,
        volume: 1.0,
        fadeInDuration: 500,
        fadeOutDuration: 500,
        soundSource: s,
      )).toList();

      final now = DateTime.now();
      final template = SceneTemplate(
        id: widget.template?.id ?? _uuid.v4(),
        name: name,
        emoji: _emoji,
        cycles: _cycles,
        workDurationMs: _workDuration,
        restDurationMs: _restDuration,
        audioTracks: [...workTracks, ...restTracks],
        segments: [],
        createdAt: widget.template?.createdAt ?? now,
        updatedAt: now,
      );

      await _templateService.saveTemplate(template);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已保存: $name')),
        );
        Navigator.pop(context, template);
      }
    } catch (e) {
      Logger.e('保存模板失败', tag: 'TemplateEditor', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
