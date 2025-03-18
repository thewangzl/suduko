import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sudoku_board.dart';

class ApiService {
  static const String _baseUrl = 'https://sudoku-api.vercel.app/api/dosuku';

  static Future<SudokuBoard> getNewBoard() async {
    try {
      final query = '''{newboard(limit:1){grids{value,solution,difficulty}}}''';

      final response = await http.get(
        Uri.parse('$_baseUrl?query=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print('API Response: $decodedResponse'); // 用于调试
        return SudokuBoard.fromJson(decodedResponse);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('服务器响应错误: ${response.statusCode}');
      }
    } catch (e) {
      print('API Exception: $e');
      throw Exception('获取数独数据失败: $e');
    }
  }
}