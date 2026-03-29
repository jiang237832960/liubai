import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../core/theme.dart';
import '../services/audio_service.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final AudioService _audioService = AudioService();
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LiubaiColors.liubaiWhite,
      appBar: AppBar(
        title: const Text('留白音', style: LiubaiTypography.h1),
        backgroundColor: LiubaiColors.liubaiWhite,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 说明文字
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              '选择一段声音，陪伴你的留白时光',
              style: LiubaiTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),
          
          // 内置白噪音列表
          ..._audioService.builtInNoises.map((noise) => _buildNoiseCard(noise)),
          
          const SizedBox(height: 24),
          
          // 自定义白噪音
          if (_audioService.customNoises.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text('我的音频', style: LiubaiTypography.caption),
            ),
            ..._audioService.customNoises.map((noise) => _buildNoiseCard(noise)),
          ],
          
          const SizedBox(height: 24),
          
          // 导入按钮
          Center(
            child: TextButton.icon(
              onPressed: _importAudio,
              icon: const Icon(Icons.add),
              label: const Text('导入音频'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoiseCard(WhiteNoise noise) {
    final isPlaying = _audioService.currentNoise?.id == noise.id && 
                      _audioService.isPlaying;
    final isCustom = !noise.isBuiltIn;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LiubaiColors.liubaiWhite,
        border: Border.all(
          color: isPlaying ? LiubaiColors.inkBlack : LiubaiColors.lightInkGray,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Emoji图标
              Text(
                noise.emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              
              // 名称
              Expanded(
                child: Text(
                  noise.name,
                  style: LiubaiTypography.body,
                ),
              ),
              
              // 删除按钮（仅自定义音频）
              if (isCustom)
                IconButton(
                  onPressed: () => _deleteCustomNoise(noise),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: LiubaiColors.pineSmokeGray,
                  ),
                ),
              
              // 播放/暂停按钮
              IconButton(
                onPressed: () => _togglePlay(noise),
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: LiubaiColors.inkBlack,
                ),
              ),
            ],
          ),
          
          // 音量滑块（仅在播放时显示）
          if (isPlaying || _audioService.currentNoise?.id == noise.id)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.volume_down,
                    size: 16,
                    color: LiubaiColors.pineSmokeGray,
                  ),
                  Expanded(
                    child: Slider(
                      value: noise.volume,
                      onChanged: (value) => _setVolume(noise, value),
                      activeColor: LiubaiColors.inkBlack,
                      inactiveColor: LiubaiColors.lightInkGray,
                    ),
                  ),
                  const Icon(
                    Icons.volume_up,
                    size: 16,
                    color: LiubaiColors.pineSmokeGray,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(noise.volume * 100).toInt()}%',
                    style: LiubaiTypography.caption,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _togglePlay(WhiteNoise noise) async {
    try {
      await _audioService.toggle(noise);
      setState(() {});
    } catch (e) {
      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('音频播放失败，请检查音频文件'),
          ),
        );
      }
    }
  }

  Future<void> _setVolume(WhiteNoise noise, double volume) async {
    await _audioService.setVolume(volume);
    setState(() {});
  }

  Future<void> _importAudio() async {
    try {
      // 显示加载提示
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 打开文件选择器
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      // 关闭加载提示
      if (mounted) Navigator.pop(context);

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final fileName = file.name;
        final filePath = file.path!;

        // 显示文件名输入对话框
        final nameController = TextEditingController(text: fileName.split('.').first);
        
        final name = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('命名音频'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '音频名称',
                hintText: '输入音频名称',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, nameController.text),
                child: const Text('确定'),
              ),
            ],
          ),
        );

        if (name != null && name.isNotEmpty) {
          // 创建自定义白噪音
          final customNoise = WhiteNoise(
            id: _uuid.v4(),
            name: name,
            emoji: '🎵',
            type: WhiteNoiseType.custom,
            filePath: filePath,
            volume: 0.5,
          );

          // 添加到音频服务
          _audioService.addCustomNoise(customNoise);

          // 刷新界面
          setState(() {});

          // 显示成功提示
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已导入: $name')),
            );
          }
        }
      }
    } catch (e) {
      // 关闭加载提示
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 显示错误提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteCustomNoise(WhiteNoise noise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${noise.name}" 吗？'),
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
      // 如果正在播放，先停止
      if (_audioService.currentNoise?.id == noise.id) {
        await _audioService.stop();
      }

      // 删除自定义音频
      _audioService.removeCustomNoise(noise.id);

      // 刷新界面
      setState(() {});

      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除: ${noise.name}')),
        );
      }
    }
  }
}
