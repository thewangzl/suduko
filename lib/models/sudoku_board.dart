class SudokuBoard {
  List<List<int>> initialBoard;
  List<List<int>> solution;
  List<List<bool>> isInitialNumber;
  List<List<Set<int>>> notes;  // 添加笔记数据
  String difficulty;

  SudokuBoard({
    required this.initialBoard,
    required this.solution,
    required this.difficulty,
  }) : isInitialNumber = List.generate(
         9,
         (i) => List.generate(
           9,
           (j) => initialBoard[i][j] != 0,
         ),
       ),
       notes = List.generate(  // 初始化笔记数据
         9,
         (i) => List.generate(
           9,
           (j) => <int>{},
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

  int getRemainingCount(int number) {
    int count = 9;  // 每个数字最多出现9次
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (initialBoard[i][j] == number && !_isWrongNumber(i, j, number)) {
          count--;
        }
      }
    }
    return count;
  }

  bool _isWrongNumber(int row, int col, int value) {
    if (value == 0) return false;
    return value != solution[row][col];
  }

  // 添加笔记相关方法
  void toggleNote(int row, int col, int number) {
    if (isInitialNumber[row][col] || initialBoard[row][col] != 0) return;
    
    if (notes[row][col].contains(number)) {
      notes[row][col].remove(number);
    } else {
      notes[row][col].add(number);
    }
  }

  void clearNotes(int row, int col) {
    notes[row][col].clear();
  }
}