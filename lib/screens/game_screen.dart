import 'package:flutter/material.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/control_panel.dart';
import '../services/api_service.dart';
import '../models/sudoku_board.dart';
import 'dart:async';  // Add this import for Timer
import '../services/database_service.dart';

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
  static const int maxErrors = 3;  // 最大错误次数
  int _errorCount = 0;  // 当前错误次数
  bool _isNoteMode = false;  // 添加笔记模式状态
  List<int>? highlightedCells;  // 添加高亮格子列表

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
      setState(() {
        _isLoading = true;
        _errorCount = 0;  // 重置错误次数
        _history.clear(); // 清空历史记录
      });
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

  void _showGameCompleteDialog() async {
    _timer?.cancel();
    final bestTime = await DatabaseService.getBestTime(widget.difficulty);
    await DatabaseService.updateBestTime(widget.difficulty, _seconds);
    
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('恭喜！'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('你已经完成了这个数独题目！'),
              const SizedBox(height: 8),
              Text('本次用时: ${_formatTime(_seconds)}'),
              if (bestTime != null) Text('最佳记录: ${_formatTime(bestTime)}'),
              if (bestTime == null || _seconds < bestTime)
                const Text('新纪录！', style: TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('返回主菜单'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadNewBoard();
              },
              child: const Text('开始新游戏'),
            ),
          ],
        ),
      );
    }
  }

  void handleNumberInput(int number) {
    if (selectedCell != null && _board != null) {
      final row = selectedCell! ~/ 9;
      final col = selectedCell! % 9;
      
      if (_board!.isInitialNumber[row][col]) return;

      if (_isNoteMode) {
        // 检查数字是否已存在于相关区域
        if (_board!.isNumberExistsInRegion(row, col, number)) {
          // 获取需要高亮的位置
          final positions = _board!.getSameNumberPositions(row, col, number);
          // 通知 SudokuGrid 高亮这些位置
          setState(() {
            highlightedCells = positions;
          });
          return;
        }
        
        setState(() {
          _board!.toggleNote(row, col, number);
          highlightedCells = null;  // 清除高亮
        });
      } else {
        // 普通模式：填写数字
        if (_board!.initialBoard[row][col] != 0) {
          _board!.clearNotes(row, col);  // 清除笔记
        }
        
        final isCorrect = _board!.solution[row][col] == number;
        if (!isCorrect) {
          setState(() {
            _errorCount++;
          });
          
          if (_errorCount >= maxErrors) {
            _timer?.cancel();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('游戏结束'),
                content: const Text('已达到最大错误次数，游戏失败！'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('返回主菜单'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _loadNewBoard();
                    },
                    child: const Text('重新开始'),
                  ),
                ],
              ),
            );
            return;
          }
        }

        _history.add({
          'row': row,
          'col': col,
          'oldValue': _board!.initialBoard[row][col],
          'oldNotes': Set<int>.from(_board!.notes[row][col]),
          'newValue': number,
        });

        setState(() {
          _board!.initialBoard[row][col] = number;
          _board!.clearNotes(row, col);
          highlightedCells = null;  // 清除高亮
          
          if (_board!.isComplete()) {
            _showGameCompleteDialog();
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
        _board!.notes[lastMove['row']][lastMove['col']] = lastMove['oldNotes'] ?? <int>{};  // 恢复笔记状态
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
      // 检查是否为初始数字
      if (!_board!.isInitialNumber[row][col]) {
        _history.add({
          'row': row,
          'col': col,
          'oldValue': _board!.initialBoard[row][col],
          'oldNotes': Set<int>.from(_board!.notes[row][col]),  // 保存笔记状态
          'newValue': 0,
        });
        setState(() {
          _board!.initialBoard[row][col] = 0;
          _board!.clearNotes(row, col);  // 清除笔记
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
        title: const Text('数独'),
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
                            highlightedCells = null;  // 点击格子时清除高亮
                          });
                        },
                        errorCount: _errorCount,
                        maxErrors: maxErrors,
                        formattedTime: _formatTime(_seconds),
                        highlightedCells: highlightedCells,  // 传递高亮格子列表
                      ),
                    ),
                    ControlPanel(
                      onUndo: _undo,
                      canUndo: _history.isNotEmpty,
                      onHint: _hint,
                      onClear: _clear,
                      onReset: _reset,
                      isNoteMode: _isNoteMode,  // 新增
                      onToggleNoteMode: () {
                        setState(() {
                          _isNoteMode = !_isNoteMode;
                        });
                      },
                    ),
                    Expanded(
                      flex: 2,
                      child: NumberPad(
                        onNumberSelected: handleNumberInput,
                        board: _board!,
                      ),
                    ),
                  ],
                ),
    );
  }
}