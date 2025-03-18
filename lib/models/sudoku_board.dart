class SudokuBoard {
  List<List<int>> initialBoard;
  List<List<int>> solution;
  List<List<bool>> isInitialNumber;  // 添加初始数字标记
  String difficulty;

  SudokuBoard({
    required this.initialBoard,
    required this.solution,
    required this.difficulty,
  }) : isInitialNumber = List.generate(
         9,
         (i) => List.generate(
           9,
           (j) => initialBoard[i][j] != 0,  // 初始化时记录非0的位置
         ),
       );

  bool isComplete() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (initialBoard[i][j] != solution[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    try {
      print('Received JSON: $json'); // Debug output

      final newboard = json['newboard'] ;
      if (newboard == null) {
        throw Exception('Missing newboard field in data');
      }

      final grids = newboard['grids'] as List;
      if (grids.isEmpty) {
        throw Exception('No grids available');
      }

      final grid = grids[0];
      
      // Convert 2D arrays
      List<List<int>> convertToIntList(List<dynamic> list) {
        return list.map((row) => 
          (row as List<dynamic>).map((val) => val as int).toList()
        ).toList();
      }

      return SudokuBoard(
        initialBoard: convertToIntList(grid['value']),
        solution: convertToIntList(grid['solution']),
        difficulty: grid['difficulty'] as String,
      );
    } catch (e) {
      print('JSON parsing error: $e');
      print('Raw JSON: $json');
      rethrow;
    }
  }
}