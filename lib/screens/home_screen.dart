import 'package:flutter/material.dart';
import 'game_screen.dart';
import '../services/database_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatTime(int? seconds) {
    if (seconds == null) return '-';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildDifficultyButton(BuildContext context, String difficulty, String label) {
    return FutureBuilder<int?>(
      future: DatabaseService.getBestTime(difficulty),
      builder: (context, snapshot) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameScreen(difficulty: difficulty),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 改为两端对齐
              children: [
                SizedBox(
                  width: 80,  // 固定难度文字宽度
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.yellow[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '最佳: ${_formatTime(snapshot.data)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
            _buildDifficultyButton(context, 'Easy', '简单'),
            _buildDifficultyButton(context, 'Medium', '中等'),
            _buildDifficultyButton(context, 'Hard', '困难'),
          ],
        ),
      ),
    );
  }
}