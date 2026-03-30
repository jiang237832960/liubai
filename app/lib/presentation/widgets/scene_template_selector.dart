import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/logger.dart';
import '../../data/models/scene_template.dart';
import '../../services/template_service.dart';

class SceneTemplateSelector extends StatefulWidget {
  final String? selectedTemplateId;
  final Function(String?) onTemplateSelected;
  final bool showAllOption;

  const SceneTemplateSelector({
    super.key,
    this.selectedTemplateId,
    required this.onTemplateSelected,
    this.showAllOption = true,
  });

  @override
  State<SceneTemplateSelector> createState() => _SceneTemplateSelectorState();
}

class _SceneTemplateSelectorState extends State<SceneTemplateSelector> {
  final _templateService = TemplateService();
  List<SceneTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _templateService.getAllTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      Logger.e('加载场景模板失败', error: e);
      setState(() => _isLoading = false);
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (widget.showAllOption) _buildTemplateChip(
            label: '全部',
            emoji: '📋',
            isSelected: widget.selectedTemplateId == null,
            onTap: () => widget.onTemplateSelected(null),
          ),
          ..._templates.map((template) => _buildTemplateChip(
            label: template.name,
            emoji: template.emoji,
            isSelected: widget.selectedTemplateId == template.id,
            onTap: () => widget.onTemplateSelected(template.id),
          )),
        ],
      ),
    );
  }

  Widget _buildTemplateChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? LiubaiColors.inkBlack : Colors.transparent,
          border: Border.all(
            color: LiubaiColors.inkBlack,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : LiubaiColors.inkBlack,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
