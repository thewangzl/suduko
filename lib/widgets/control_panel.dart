import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onHint;
  final VoidCallback onClear;
  final VoidCallback onReset;
  final bool canUndo;

  const ControlPanel({
    super.key,
    required this.onUndo,
    required this.onHint,
    required this.onClear,
    required this.onReset,
    required this.canUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: canUndo ? onUndo : null,
            tooltip: '撤销',
          ),
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: onHint,
            tooltip: '提示',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onClear,
            tooltip: '清除',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReset,
            tooltip: '重置',
          ),
        ],
      ),
    );
  }
}