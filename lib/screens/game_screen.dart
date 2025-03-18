import 'package:flutter/material.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../services/api_service.dart';
import '../models/sudoku_board.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNewBoard();
  }

  Future<void> _loadNewBoard() async {
    try {
      setState(() => _isLoading = true);
      final board = await ApiService.getNewBoard(difficulty: widget.difficulty);
      setState(() {
        _board = board;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _history.isEmpty ? null : _undo,
            tooltip: '撤销',
          ),
        ],
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