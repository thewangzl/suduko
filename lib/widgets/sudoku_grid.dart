import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';

class SudokuGrid extends StatefulWidget {
  final SudokuBoard board;

  const SudokuGrid({
    super.key,
    required this.board,
  });

  @override
  State<SudokuGrid> createState() => _SudokuGridState();
}

class _SudokuGridState extends State<SudokuGrid> {
  int? selectedIndex;

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
            final value = widget.board.initialBoard[row][col];
            final isSelected = selectedIndex == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
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
                      fontWeight: value != 0 ? FontWeight.bold : FontWeight.normal,
                      color: value != 0 ? Colors.black : Colors.blue,
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