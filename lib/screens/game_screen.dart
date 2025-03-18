import 'package:flutter/material.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/control_panel.dart';
import '../services/api_service.dart';
import '../models/sudoku_board.dart';
import 'dart:async';  // Add this import for Timer

class GameScreen extends StatefulWidget {
  final String difficulty;

  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  SudokuBoard? _board;
  bool _isLoading = true;
  int? selectedCell;
  List<Map<String, dynamic>> _history = [];  // 添加历史记录
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _loadNewBoard();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _loadNewBoard() async {
    try {
      setState(() => _isLoading = true);
      final board = await ApiService.getNewBoard(difficulty: widget.difficulty);
      setState(() {
        _board = board;
        _isLoading = false;
      });
      _startTimer(); // 重置计时器
    } catch (e) {
      setState(() {
        _isLoading = false;
        _board = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载数独失败，请检查网络连接')),
        );
      }
    }
  }

  void handleNumberInput(int number) {
    if (selectedCell != null && _board != null) {
      final row = selectedCell! ~/ 9;
      final col = selectedCell! % 9;
      if (_board!.initialBoard[row][col] == 0) {
        // 记录当前状态
        _history.add({
          'row': row,
          'col': col,
          'oldValue': _board!.initialBoard[row][col],
          'newValue': number,
        });

        setState(() {
          _board!.initialBoard[row][col] = number;
          
          // 检查是否完成
          if (_board!.isComplete()) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('恭喜！'),
                content: const Text('你已经完成了这个数独题目！'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(); // 返回主菜单
                    },
                    child: const Text('返回主菜单'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadNewBoard(); // 开始新游戏
                    },
                    child: const Text('开始新游戏'),
                  ),
                ],
              ),
            );
          }
        });
      }
    }
  }

  void _undo() {
    if (_history.isNotEmpty && _board != null) {
      final lastMove = _history.removeLast();
      setState(() {
        _board!.initialBoard[lastMove['row']][lastMove['col']] = lastMove['oldValue'];
      });
    }
  }

  // 添加提示功能
  void _hint() {
    if (selectedCell != null && _board != null) {
      final row = selectedCell! ~/ 9;
      final col = selectedCell! % 9;
      if (_board!.initialBoard[row][col] == 0) {
        final correctValue = _board!.solution[row][col];
        _history.add({
          'row': row,
          'col': col,
          'oldValue': _board!.initialBoard[row][col],
          'newValue': correctValue,
        });
        setState(() {
          _board!.initialBoard[row][col] = correctValue;
        });
      }
    }
  }

  // 添加清除功能
  void _clear() {
    if (selectedCell != null && _board != null) {
      final row = selectedCell! ~/ 9;
      final col = selectedCell! % 9;
      if (_board!.initialBoard[row][col] != 0) {
        _history.add({
          'row': row,
          'col': col,
          'oldValue': _board!.initialBoard[row][col],
          'newValue': 0,
        });
        setState(() {
          _board!.initialBoard[row][col] = 0;
        });
      }
    }
  }

  // 添加重置功能
  void _reset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置游戏'),
        content: const Text('确定要重置游戏吗？这将清除所有已填写的数字。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadNewBoard();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('数独'),
            const Spacer(),
            Text(_formatTime(_seconds)), // 显示计时器
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _board == null
              ? const Center(child: Text('加载失败，请重试'))
              : Column(
                  children: [
                    const Spacer(),
                    Expanded(
                      flex: 6,
                      child: SudokuGrid(
                        board: _board!,
                        selectedCell: selectedCell,
                        onCellSelected: (index) {
                          setState(() {
                            selectedCell = index;
                          });
                        },
                      ),
                    ),
                    ControlPanel(
                      onUndo: _undo,
                      canUndo: _history.isNotEmpty,
                      onHint: _hint,
                      onClear: _clear,
                      onReset: _reset,
                    ),
                    Expanded(
                      flex: 2,
                      child: NumberPad(
                        onNumberSelected: handleNumberInput,
                      ),
                    ),
                  ],
                ),
    );
  }
}