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
  int? selectedCell; // 添加选中格子的索引

  // 添加处理数字输入的方法
  void handleNumberInput(int number) {
    if (selectedCell != null && _board != null) {
      final row = selectedCell! ~/ 9;
      final col = selectedCell! % 9;
      if (_board!.initialBoard[row][col] == 0) {
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