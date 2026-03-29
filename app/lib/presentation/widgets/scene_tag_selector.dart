import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/models.dart';
import '../../data/database.dart';

/// 场景标签选择器
class SceneTagSelector extends StatefulWidget {
  final int? selectedTagId;
  final Function(int?) onTagSelected;
  final bool showAddButton;

  const SceneTagSelector({
    super.key,
    this.selectedTagId,
    required this.onTagSelected,
    this.showAddButton = true,
  });

  @override
  State<SceneTagSelector> createState() => _SceneTagSelectorState();
}

class _SceneTagSelectorState extends State<SceneTagSelector> {
  List<SceneTag> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final tags = await DatabaseHelper.instance.getAllSceneTags();
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 无标签选项
        _buildTagChip(
          label: '无标签',
          isSelected: widget.selectedTagId == null,
          onTap: () => widget.onTagSelected(null),
        ),
        // 标签列表
        ..._tags.map((tag) => _buildTagChip(
          label: tag.name,
          color: tag.colorValue,
          isSelected: widget.selectedTagId == tag.id,
          onTap: () => widget.onTagSelected(tag.id),
        )),
        // 添加按钮
        if (widget.showAddButton)
          _buildAddButton(),
      ],
    );
  }

  Widget _buildTagChip({
    required String label,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final bgColor = color ?? LiubaiColors.pineSmokeGray;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? bgColor : Colors.transparent,
          border: Border.all(
            color: bgColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : bgColor,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _showAddTagDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: LiubaiColors.lightInkGray,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 16,
              color: LiubaiColors.pineSmokeGray,
            ),
            SizedBox(width: 4),
            Text(
              '添加',
              style: TextStyle(
                fontSize: 14,
                color: LiubaiColors.pineSmokeGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    final textController = TextEditingController();
    Color selectedColor = const Color(0xFF4A90D9);

    final List<Color> presetColors = [
      const Color(0xFF4A90D9), // 蓝色
      const Color(0xFFE74C3C), // 红色
      const Color(0xFF27AE60), // 绿色
      const Color(0xFFF39C12), // 橙色
      const Color(0xFF9B59B6), // 紫色
      const Color(0xFF1ABC9C), // 青色
      const Color(0xFF34495E), // 深蓝灰
      const Color(0xFFE91E63), // 粉色
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('添加标签'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: '标签名称',
                  border: OutlineInputBorder(),
                ),
                maxLength: 10,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presetColors.map((color) => GestureDetector(
                  onTap: () {
                    setDialogState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: selectedColor == color
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = textController.text.trim();
                if (name.isNotEmpty) {
                  final tag = SceneTag(
                    name: name,
                    color: selectedColor.value,
                    createdAt: DateTime.now(),
                  );
                  await DatabaseHelper.instance.insertSceneTag(tag);
                  await _loadTags();
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 场景标签显示组件
class SceneTagChip extends StatelessWidget {
  final SceneTag? tag;
  final VoidCallback? onTap;
  final bool isSmall;

  const SceneTagChip({
    super.key,
    this.tag,
    this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tag == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 8,
          vertical: isSmall ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: tag!.colorValue.withOpacity(0.1),
          border: Border.all(
            color: tag!.colorValue.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(isSmall ? 4 : 8),
        ),
        child: Text(
          tag!.name,
          style: TextStyle(
            fontSize: isSmall ? 11 : 12,
            color: tag!.colorValue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
