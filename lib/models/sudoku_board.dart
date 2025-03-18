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

  // 检查数字在行、列、宫中是否已存在
  bool isNumberExistsInRegion(int row, int col, int number) {
    // 检查行
    for (int c = 0; c < 9; c++) {
      if (c != col && 
          initialBoard[row][c] == number && 
          initialBoard[row][c] == solution[row][c]) {
        return true;
      }
    }
    
    // 检查列
    for (int r = 0; r < 9; r++) {
      if (r != row && 
          initialBoard[r][col] == number && 
          initialBoard[r][col] == solution[r][col]) {
        return true;
      }
    }
    
    // 检查3x3宫格
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if ((r != row || c != col) && 
            initialBoard[r][c] == number && 
            initialBoard[r][c] == solution[r][c]) {
          return true;
        }
      }
    }
    
    return false;
  }

  // 获取同区域中相同数字的位置
  List<int> getSameNumberPositions(int row, int col, int number) {
    List<int> positions = [];
    
    // 检查行
    for (int c = 0; c < 9; c++) {
      if (initialBoard[row][c] == number && 
          initialBoard[row][c] == solution[row][c]) {
        positions.add(row * 9 + c);
      }
    }
    
    // 检查列
    for (int r = 0; r < 9; r++) {
      if (initialBoard[r][col] == number && 
          initialBoard[r][col] == solution[r][col]) {
        positions.add(r * 9 + col);
      }
    }
    
    // 检查3x3宫格
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int r = boxRow; r < boxRow + 3; r++) {
      for (int c = boxCol; c < boxCol + 3; c++) {
        if (initialBoard[r][c] == number && 
            initialBoard[r][c] == solution[r][c]) {
          positions.add(r * 9 + c);
        }
      }
    }
    
    return positions.toSet().toList(); // 去重
  }
}