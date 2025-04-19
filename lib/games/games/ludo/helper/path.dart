import 'enums.dart';

class PathHelper {
  static const List<List<int>> greenPath = [
    [6,1],[6,2],[6,3],[6,4],[6,5],
    [5,6],[4,6],[3,6],[2,6],[1,6],[0,6],[0,7],[0,8],[1,8],
    [2,8],[3,8],[4,8],[5,8],[6,9],[6,10],[6,11],[6,12],[6,13],
    [6,14],[7,14],[8,14],[8,13],[8,12],[8,11],[8,10],[8,9],
    [9,8],[10,8],[11,8],[12,8],[13,8],[14,8],[14,7],[14,6],
    [13,6],[12,6],[11,6],[10,6],[9,6],[8,5],[8,4],[8,3],[8,2],
    [8,1],[8,0],[7,0],[7,1],[7,2],[7,3],[7,4],[7,5],[7,6]
  ];

  static const List<List<int>> yellowPath = [
    [1,8],[2,8],[3,8],[4,8],[5,8],
    [6,9],[6,10],[6,11],[6,12],[6,13],[6,14],[7,14],[8,14],
    [8,13],[8,12],[8,11],[8,10],[8,9],[9,8],[10,8],[11,8],
    [12,8],[13,8],[14,8],[14,7],[14,6],[13,6],[12,6],[11,6],
    [10,6],[9,6],[8,5],[8,4],[8,3],[8,2],[8,1],[8,0],[7,0],
    [6,0],[6,1],[6,2],[6,3],[6,4],[6,5],[5,6],[4,6],[3,6],
    [2,6],[1,6],[0,6],[0,7],[1,7],[2,7],[3,7],[4,7],[5,7],
    [6,7]
  ];

  static const List<List<int>> bluePath = [
    [8,13],[8,12],[8,11],[8,10],[8,9],
    [9,8],[10,8],[11,8],[12,8],[13,8],[14,8],[14,7],[14,6],
    [13,6],[12,6],[11,6],[10,6],[9,6],[8,5],[8,4],[8,3],[8,2],
    [8,1],[8,0],[7,0],[6,0],[6,1],[6,2],[6,3],[6,4],[6,5],
    [5,6],[4,6],[3,6],[2,6],[1,6],[0,6],[0,7],[0,8],[1,8],
    [2,8],[3,8],[4,8],[5,8],[6,9],[6,10],[6,11],[6,12],[6,13],
    [6,14],[7,14],[7,13],[7,12],[7,11],[7,10],[7,9],[7,8]
  ];

  static const List<List<int>> redPath = [
    [13,6],[12,6],[11,6],[10,6],[9,6],
    [8,5],[8,4],[8,3],[8,2],[8,1],[8,0],[7,0],[6,0],[6,1],
    [6,2],[6,3],[6,4],[6,5],[5,6],[4,6],[3,6],[2,6],[1,6],
    [0,6],[0,7],[0,8],[1,8],[2,8],[3,8],[4,8],[5,8],[6,9],
    [6,10],[6,11],[6,12],[6,13],[6,14],[7,14],[8,14],[8,13],
    [8,12],[8,11],[8,10],[8,9],[9,8],[10,8],[11,8],[12,8],
    [13,8],[14,8],[14,7],[13,7],[12,7],[11,7],[10,7],[9,7],
    [8,7]
  ];

  static const Map<TokenType, List<List<int>>> paths = {
    TokenType.green: greenPath,
    TokenType.blue: bluePath,
    TokenType.red: redPath,
    TokenType.yellow: yellowPath,
  };

  // Use a lazy-initialized cache for paths
  static final Map<TokenType, List<List<int>>> _pathCache = {};

  // Method to get path for a specific token type
  // This ensures paths are available when needed
  static List<List<int>> getPath(TokenType type) {
    if (!_pathCache.containsKey(type)) {
      switch (type) {
        case TokenType.green:
          _pathCache[type] = greenPath;
          break;
        case TokenType.yellow:
          _pathCache[type] = yellowPath;
          break;
        case TokenType.blue:
          _pathCache[type] = bluePath;
          break;
        case TokenType.red:
          _pathCache[type] = redPath;
          break;
      }
    }
    return _pathCache[type]!;
  }

  // Initialize all paths - call this when game starts
  static void initializePaths() {
    _pathCache[TokenType.green] = greenPath;
    _pathCache[TokenType.yellow] = yellowPath;
    _pathCache[TokenType.blue] = bluePath;
    _pathCache[TokenType.red] = redPath;
  }

  // Helper method to safely get a path position
  static List<int>? getPathPosition(TokenType type, int step) {
    final path = getPath(type);
    if (step < 0 || step >= path.length) {
      return null;
    }
    return path[step];
  }


}