import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../config/orientation_manager.dart';

class LudoBoard extends StatelessWidget {
  final List<List<GlobalKey>> keyReferences;
  final List<Color>? playerColors;


  // Constructor
  const LudoBoard({
    super.key,
    required this.keyReferences,
    this.playerColors
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        final boardSize = math.min(constraints.maxWidth, constraints.maxHeight);

        return Card(
          elevation: 8.0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: _BuildLudoBoard(
              boardSize: boardSize,
              keyReferences: keyReferences,
              playerColors: playerColors,
            ),
          ),
        );
      },
    );
  }
}

class _BuildLudoBoard extends StatelessWidget {
  final double boardSize;
  final List<List<GlobalKey>> keyReferences;
  final List<Color>? playerColors;

  const _BuildLudoBoard({
    required this.boardSize,
    required this.keyReferences,
    this.playerColors
  });

  @override
  Widget build(BuildContext context) {
    final cellSize = boardSize / 15;
    OrientationManager.fixedOriantation(); // stop orientation for play screen

    return Stack(
      children: [
        // Draw board base with CustomPainter
        RepaintBoundary(
          child: CustomPaint(
            size: Size(boardSize, boardSize),
            painter: LudoBoardPainter(pColors: playerColors),
          ),
        ),

        // Overlay grid for token positioning with keys
        _buildCellPositionGrid(cellSize),
      ],
    );
  }

  Widget _buildCellPositionGrid(double cellSize) {
    return Column(
      children: List.generate(15, (row) {
        return Expanded(
          child: Row(
            children: List.generate(15, (col) {
              return Expanded(
                child: SizedBox(
                  key: keyReferences[row][col],
                  height: double.infinity,
                  width: double.infinity,
                  // Uncomment for debugging cell positions
                  //child: Text('$row,$col', style: TextStyle(fontSize: 8)),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class LudoBoardPainter extends CustomPainter {
  final List<Color> playersColors;

  LudoBoardPainter({
    List<Color>? pColors,
  }) : playersColors = pColors ??
      [Colors.red, Colors.green, Colors.yellow, Colors.blue];

  // Board layout constants
  static const int gridSize = 15;
  static const int cornerSize = 6;
  static const int pathWidth = 3;
  static const int homeSize = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridSize;

    // Paints for drawing
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Base white background
    fillPaint.color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fillPaint);

    _drawPlayerCorners(canvas, cellSize, fillPaint, borderPaint);
    _drawHomeAreas(canvas, cellSize, fillPaint, borderPaint);

    // Draw the paths through the board
    _drawPaths(canvas, size, cellSize, fillPaint, borderPaint);

    // Draw the center area with colored triangles
    _drawCenterArea(canvas, cellSize, fillPaint, borderPaint);

    _drawSafeSpots(canvas, cellSize);
    _drawGridLines(canvas, size, cellSize, borderPaint);
  }

  void _drawPlayerCorners(Canvas canvas, double cellSize, Paint fillPaint, Paint borderPaint) {

    // Bottom-left (Red)
    fillPaint.color = playersColors[0]; //playerColors['red']!;
    _drawCorner(canvas, 0, cellSize * (gridSize - cornerSize), cellSize, fillPaint, borderPaint);

    // Top-left (Green)
    fillPaint.color = playersColors[1]; //playerColors['green']!;
    _drawCorner(canvas, 0, 0, cellSize, fillPaint, borderPaint);

    // Top-right (Yellow)
    fillPaint.color = playersColors[2]; //playerColors['yellow']!;
    _drawCorner(canvas, cellSize * (gridSize - cornerSize), 0, cellSize, fillPaint, borderPaint);

    // Bottom-right (Blue)
    fillPaint.color = playersColors[3]; //playerColors['blue']!;
    _drawCorner(canvas, cellSize * (gridSize - cornerSize),
        cellSize * (gridSize - cornerSize), cellSize, fillPaint, borderPaint);
  }

  void _drawCorner(Canvas canvas, double x, double y, double cellSize,
      Paint fillPaint, Paint borderPaint) {
    final rect = Rect.fromLTWH(x, y, cellSize * cornerSize, cellSize * cornerSize);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);
  }

  void _drawHomeAreas(Canvas canvas, double cellSize, Paint fillPaint, Paint borderPaint) {
    fillPaint.color = Colors.white;

    // Home area positions (each corner has one home area)
    final homePositions = [
      [1, 1],     // Green (top-left)
      [10, 1],    // Yellow (top-right)
      [1, 10],    // Red (bottom-left)
      [10, 10],   // Blue (bottom-right)
    ];

    // Draw white home rectangles with borders
    for (final pos in homePositions) {
      final rect = Rect.fromLTWH(
          cellSize * pos[0],
          cellSize * pos[1],
          cellSize * 4,
          cellSize * 4
      );

      // Draw white fill
      canvas.drawRect(rect, fillPaint);

      // Draw border around the entire home area
      canvas.drawRect(rect, borderPaint);
    }

    // Draw starting positions for tokens
    _drawTokenStartPositions(canvas, cellSize);
  }


  void _drawTokenStartPositions(Canvas canvas, double cellSize) {
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.0;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill;

    // Updated positions to be in the middle of cells rather than at grid intersections
    final tokenPositions = [
      // Red (bottom-left) - positions and color - centered in cells
      {"positions": [[2.5, 11.5], [2.5, 12.5], [3.5, 11.5], [3.5, 12.5]], "color": playersColors[0]},
      // Green (top-left) - positions and color - centered in cells
      {"positions": [[2.5, 2.5], [2.5, 3.5], [3.5, 2.5], [3.5, 3.5]], "color": playersColors[1]},

      // Yellow (top-right) - positions and color - centered in cells
      {"positions": [[11.5, 2.5], [11.5, 3.5], [12.5, 2.5], [12.5, 3.5]], "color": playersColors[2]},
      // Blue (bottom-right) - positions and color - centered in cells
      {"positions": [[11.5, 11.5], [11.5, 12.5], [12.5, 11.5], [12.5, 12.5]], "color": playersColors[3]},
    ];

    // Draw token circles
    for (final colorSet in tokenPositions) {
      fillPaint.color = (colorSet["color"] as Color).withValues(alpha: 0.2);

      for (final pos in colorSet["positions"] as List<List<double>>) {
        final center = Offset(cellSize * pos[0], cellSize * pos[1]);
        final radius = cellSize * 0.4;

        // Draw a colored fill circle for the token position
        canvas.drawCircle(center, radius, fillPaint);

        // Draw border around it
        canvas.drawCircle(center, radius, circlePaint);
      }
    }
  }

  void _drawPaths(Canvas canvas, Size size, double cellSize, Paint fillPaint, Paint borderPaint) {
    // Draw main cross paths
    fillPaint.color = Colors.white;

    // Horizontal path
    canvas.drawRect(
        Rect.fromLTWH(0, cellSize * 6, size.width, cellSize * pathWidth),
        fillPaint
    );

    // Vertical path
    canvas.drawRect(
        Rect.fromLTWH(cellSize * 6, 0, cellSize * pathWidth, size.height),
        fillPaint
    );

    // Draw colored home paths
    _drawHomePaths(canvas, cellSize, fillPaint);
  }

  void _drawHomePaths(Canvas canvas, double cellSize, Paint fillPaint) {
    // Green path to center
    fillPaint.color = Colors.yellow;
    canvas.drawRect(
        Rect.fromLTWH(cellSize * 7, cellSize, cellSize, cellSize * 5),
        fillPaint
    );

    // Yellow path to center
    fillPaint.color = Colors.blue;
    canvas.drawRect(
        Rect.fromLTWH(cellSize * 9, cellSize * 7, cellSize * 5, cellSize),
        fillPaint
    );

    // Red path to center
    fillPaint.color = Colors.red;
    canvas.drawRect(
        Rect.fromLTWH(cellSize * 7, cellSize * 9, cellSize, cellSize * 5),
        fillPaint
    );

    // Blue path to center
    fillPaint.color = Colors.green;
    canvas.drawRect(
        Rect.fromLTWH(cellSize, cellSize * 7, cellSize * 5, cellSize),
        fillPaint
    );
  }

  void _drawCenterArea(Canvas canvas, double cellSize, Paint fillPaint, Paint borderPaint) {
    // Draw center white area
    fillPaint.color = Colors.white;
    final centerRect = Rect.fromLTWH(
        cellSize * 6,
        cellSize * 6,
        cellSize * homeSize,
        cellSize * homeSize
    );
    canvas.drawRect(centerRect, fillPaint);
    canvas.drawRect(centerRect, borderPaint);

    // Draw colored triangles in center
    final centerX = cellSize * 7.5;
    final centerY = cellSize * 7.5;

    // Define corners of center area
    final topLeft = Offset(cellSize * 6, cellSize * 6);
    final topRight = Offset(cellSize * 9, cellSize * 6);
    final bottomLeft = Offset(cellSize * 6, cellSize * 9);
    final bottomRight = Offset(cellSize * 9, cellSize * 9);
    final center = Offset(centerX, centerY);

    // Draw triangles
    _drawTriangle(canvas, center, bottomRight, bottomLeft, playersColors[0] ); //playerColors['red']!);
    _drawTriangle(canvas, center, bottomLeft, topLeft, playersColors[1]); //playerColors['green']!);

    _drawTriangle(canvas, center, topLeft, topRight, playersColors[2]); //playerColors['yellow']!);
    _drawTriangle(canvas, center, topRight, bottomRight, playersColors[3]); //playerColors['blue']!);
  }

  void _drawTriangle(Canvas canvas, Offset p1, Offset p2, Offset p3, Color color) {
    final path = Path();
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    canvas.drawPath(path, paint);
  }

  void _drawSafeSpots(Canvas canvas, double cellSize) {
    // Safe spot positions on the board
    final safeSpots = [
      [6, 2], [1, 6], [6, 13], [12, 6], // Near player corners
      [8, 1], [13, 8], [8, 12], [2, 8], // Secondary safe spots
    ];

    for (final pos in safeSpots) {
      // Add half cellSize to center the star in the cell
      _drawSafeSpot(
          canvas,
          (pos[0] + 0.5) * cellSize,
          (pos[1] + 0.5) * cellSize,
          cellSize
      );
    }
  }


  void _drawSafeSpot(Canvas canvas, double x, double y, double cellSize) {
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey.withValues(alpha: 0.3);

    // Draw a gray circle background
    canvas.drawCircle(
        Offset(x, y),
        cellSize * 0.4,
        fillPaint
    );

    // Draw star or symbol
    final starPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.0;

    // Simple asterisk as safe spot marker
    final center = Offset(x, y);
    final size = cellSize * 0.3;

    // Draw diagonal lines for a star/asterisk
    canvas.drawLine(
        Offset(center.dx - size, center.dy - size),
        Offset(center.dx + size, center.dy + size),
        starPaint
    );

    canvas.drawLine(
        Offset(center.dx + size, center.dy - size),
        Offset(center.dx - size, center.dy + size),
        starPaint
    );

    canvas.drawLine(
        Offset(center.dx, center.dy - size),
        Offset(center.dx, center.dy + size),
        starPaint
    );

    canvas.drawLine(
        Offset(center.dx - size, center.dy),
        Offset(center.dx + size, center.dy),
        starPaint
    );
  }

  void _drawGridLines(Canvas canvas, Size size, double cellSize, Paint borderPaint) {
    // Draw horizontal grid lines
    for (int i = 0; i <= gridSize; i++) {
      if (i == 0 || i == gridSize) {
        // Only draw the outer border lines of the entire board
        canvas.drawLine(
            Offset(0, i * cellSize),
            Offset(size.width, i * cellSize),
            borderPaint
        );
      } else if (i >= 6 && i <= 9) {
        // Center path horizontal lines - but skip drawing across the center 3x3 area
        // Left segment
        canvas.drawLine(
            Offset(0, i * cellSize),
            Offset(6 * cellSize, i * cellSize),
            borderPaint
        );

        // Right segment
        canvas.drawLine(
            Offset(9 * cellSize, i * cellSize),
            Offset(size.width, i * cellSize),
            borderPaint
        );
      } else {
        // For other rows, only draw the path area
        canvas.drawLine(
            Offset(6 * cellSize, i * cellSize),
            Offset(9 * cellSize, i * cellSize),
            borderPaint
        );
      }
    }

    // Draw vertical grid lines
    for (int i = 0; i <= gridSize; i++) {
      if (i == 0 || i == gridSize) {
        // Only draw the outer border lines of the entire board
        canvas.drawLine(
            Offset(i * cellSize, 0),
            Offset(i * cellSize, size.height),
            borderPaint
        );
      } else if (i >= 6 && i <= 9) {
        // Center path vertical lines - but skip drawing across the center 3x3 area
        // Top segment
        canvas.drawLine(
            Offset(i * cellSize, 0),
            Offset(i * cellSize, 6 * cellSize),
            borderPaint
        );

        // Bottom segment
        canvas.drawLine(
            Offset(i * cellSize, 9 * cellSize),
            Offset(i * cellSize, size.height),
            borderPaint
        );
      } else {
        // For other columns, only draw the path area
        canvas.drawLine(
            Offset(i * cellSize, 6 * cellSize),
            Offset(i * cellSize, 9 * cellSize),
            borderPaint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

