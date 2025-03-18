import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onUndo;
  final bool canUndo;
  final VoidCallback onHint;
  final VoidCallback onClear;
  final VoidCallback onReset;
  final bool isNoteMode;  // 添加笔记模式状态
  final VoidCallback onToggleNoteMode;  // 添加切换笔记模式的回调

  const ControlPanel({
    super.key,
    required this.onUndo,
    required this.canUndo,
    required this.onHint,
    required this.onClear,
    required this.onReset,
    required this.isNoteMode,  // 新增
    required this.onToggleNoteMode,  // 新增
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: canUndo ? onUndo : null,
          icon: const Icon(Icons.undo),
        ),
        IconButton(
          onPressed: onHint,
          icon: const Icon(Icons.lightbulb_outline),
        ),
        IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.clear),
        ),
        IconButton(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
        ),
        IconButton(
          onPressed: onToggleNoteMode,
          icon: Icon(
            Icons.edit_note,
            color: isNoteMode ? Colors.blue : null,
          ),
        ),
      ],
    );
  }
}