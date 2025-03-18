import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数独游戏'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDifficultyButton(context, '简单', 'Easy'),
            const SizedBox(height: 16),
            _buildDifficultyButton(context, '中等', 'Medium'),
            const SizedBox(height: 16),
            _buildDifficultyButton(context, '困难', 'Hard'),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String text, String difficulty) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameScreen(difficulty: difficulty),
            ),
          );
        },
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}