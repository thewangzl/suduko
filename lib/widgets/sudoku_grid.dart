import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';
import 'dart:async';  // 添加 Timer 导入

class SudokuGrid extends StatefulWidget {
  final SudokuBoard board;
  final int? selectedCell;
  final Function(int) onCellSelected;
  final int errorCount;
  final int maxErrors;
  final String formattedTime;
  final List<int>? highlightedCells;  // 添加新属性

  const SudokuGrid({
    super.key,
    required this.board,
    required this.selectedCell,
    required this.onCellSelected,
    required this.errorCount,
    required this.maxErrors,
    required this.formattedTime,
    this.highlightedCells,  
  });

  @override
  State<SudokuGrid> createState() => _SudokuGridState();
}

class _SudokuGridState extends State<SudokuGrid> with TickerProviderStateMixin {
  late AnimationController _animationController;
  int? highlightedNumber;
  Timer? _highlightTimer;  // 添加定时器

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );  // 移除自动重复
  }

  @override
  void dispose() {
    _animationController.dispose();
    _highlightTimer?.cancel();  // 清理定时器
    super.dispose();
  }

  void _handleCellTap(int index) {
    _highlightTimer?.cancel();  // 取消之前的定时器
    final row = index ~/ 9;
    final col = index % 9;
    final value = widget.board.initialBoard[row][col];
    
    setState(() {
      highlightedNumber = value != 0 ? value : null;
    });
    
    if (value != 0) {
      _animationController.reset();
      _animationController.repeat(reverse: true);
      
      // 设置新的定时器，1秒后停止动画和高亮
      _highlightTimer = Timer(const Duration(seconds: 1), () {
        _animationController.stop();
        setState(() {
          highlightedNumber = null;
        });
      });
    }
    
    widget.onCellSelected(index);
  }

  bool _shouldHighlight(int index, int value) {
    return (highlightedNumber != null && value == highlightedNumber && value != 0) ||
           (widget.highlightedCells?.contains(index) ?? false);
  }

  // 添加缺失的边框获取方法
  Border _getBorder(int index) {
    final row = index ~/ 9;
    final col = index % 9;
    const boldWidth = 2.0;
    const normalWidth = 0.5;

    return Border(
      left: BorderSide(
        width: col % 3 == 0 ? boldWidth : normalWidth,
        color: Colors.black,
      ),
      right: BorderSide(
        width: col == 8 ? boldWidth : normalWidth,
        color: Colors.black,
      ),
      top: BorderSide(
        width: row % 3 == 0 ? boldWidth : normalWidth,
        color: Colors.black,
      ),
      bottom: BorderSide(
        width: row == 8 ? boldWidth : normalWidth,
        color: Colors.black,
      ),
    );
  }

  bool _isWrongNumber(int row, int col, int value) {
    if (value == 0) return false;
    return value != widget.board.solution[row][col];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '难度: ${widget.board.difficulty}',  // 修复 board 引用
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '错误: ${widget.errorCount}/${widget.maxErrors}',  // 修复属性引用
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '时间: ${widget.formattedTime}',  // 修复属性引用
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1.0,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final value = widget.board.initialBoard[row][col];
                final isSelected = widget.selectedCell == index;
                final isInitial = widget.board.isInitialNumber[row][col];
                final isWrong = _isWrongNumber(row, col, value);
                final shouldHighlight = _shouldHighlight(index, value);  // 修改这里，添加 index 参数
                final notes = widget.board.notes[row][col];

                return GestureDetector(
                  onTap: () => _handleCellTap(index),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          border: _getBorder(index),
                          color: isWrong 
                              ? Colors.red.withOpacity(0.2)
                              : (isSelected || shouldHighlight)
                                  ? Colors.blue.withOpacity(0.2) 
                                  : null,
                        ),
                        child: value != 0 
                            ? Center(
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
                                    color: isWrong 
                                        ? Colors.red 
                                        : isInitial 
                                            ? Colors.black 
                                            : Colors.blue,
                                  ),
                                ),
                              )
                            : notes.isEmpty 
                                ? const SizedBox() 
                                : // 在 GridView.count 部分修改样式
                                  GridView.count(
                                    crossAxisCount: 3,
                                    padding: const EdgeInsets.all(1),
                                    mainAxisSpacing: 1,
                                    crossAxisSpacing: 1,
                                    physics: const NeverScrollableScrollPhysics(),
                                    children: List.generate(9, (i) {
                                      final number = i + 1;
                                      return notes.contains(number)
                                          ? Center(
                                              child: Text(
                                                number.toString(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  height: 1,
                                                ),
                                              ),
                                            )
                                          : const SizedBox();
                                    }),
                                  ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}