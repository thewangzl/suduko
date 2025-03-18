import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function(int) onNumberSelected;

  const NumberPad({
    super.key,
    required this.onNumberSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (index) {
          return SizedBox(
            width: 40,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => onNumberSelected(index + 1),
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          );
        }),
      ),
    );
  }
}