import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberSelected;
  final SudokuBoard board;

  const NumberPad({
    super.key,
    required this.onNumberSelected,
    required this.board,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,  // 设置固定高度
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          childAspectRatio: 1.0,  // 调整为正方形
          mainAxisSpacing: 2,      // 减小间距
          crossAxisSpacing: 2,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final number = index + 1;
          final remaining = board.getRemainingCount(number);
          
          if (remaining == 0) {
            return const SizedBox.shrink();
          }
          
          return GestureDetector(
            onTap: () => onNumberSelected(number),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),  // 减小圆角
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,  // 添加这行
                children: [
                  Text(
                    number.toString(),
                    style: const TextStyle(fontSize: 18),  // 稍微减小字号
                  ),
                  Text(
                    remaining.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}