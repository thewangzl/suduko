import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';

class SudokuGrid extends StatelessWidget {
  final SudokuBoard board;
  final int? selectedCell;
  final Function(int) onCellSelected;

  const SudokuGrid({
    super.key,
    required this.board,
    required this.selectedCell,
    required this.onCellSelected,
  });

  Border _getBorder(int index) {
    final row = index ~/ 9;
    final col = index % 9;
    const thin = BorderSide(color: Colors.grey, width: 0.5);
    const thick = BorderSide(color: Colors.black, width: 2.0);

    return Border(
      left: col % 3 == 0 ? thick : thin,
      right: col == 8 ? thick : thin,
      top: row % 3 == 0 ? thick : thin,
      bottom: row == 8 ? thick : thin,
    );
  }

  bool _isWrongNumber(int row, int col, int value) {
    if (value == 0) return false;
    return value != board.solution[row][col];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            final value = board.initialBoard[row][col];
            final isSelected = selectedCell == index;
            final isInitial = board.isInitialNumber[row][col];
            final isWrong = _isWrongNumber(row, col, value);

            return GestureDetector(
              onTap: () => onCellSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  border: _getBorder(index),
                  color: isWrong 
                      ? Colors.red.withOpacity(0.2)
                      : isSelected 
                          ? Colors.blue.withOpacity(0.2) 
                          : null,
                ),
                child: Center(
                  child: Text(
                    value != 0 ? value.toString() : '',
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}