class SudokuBoard {
  final List<List<int>> initialBoard;
  final List<List<int>> solution;
  final String difficulty;

  SudokuBoard({
    required this.initialBoard,
    required this.solution,
    required this.difficulty,
  });

  factory SudokuBoard.fromJson(Map<String, dynamic> json) {
    try {
      print('Received JSON: $json'); // Debug output

      final newboard = json['newboard'];
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