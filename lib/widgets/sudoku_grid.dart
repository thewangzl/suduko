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
            final isInitialValue = board.initialBoard[row][col] != 0;

            return GestureDetector(
              onTap: () => onCellSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  border: _getBorder(index),
                  color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                ),
                child: Center(
                  child: Text(
                    value != 0 ? value.toString() : '',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: isInitialValue ? FontWeight.bold : FontWeight.normal,
                      color: isInitialValue ? Colors.black : Colors.blue,
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