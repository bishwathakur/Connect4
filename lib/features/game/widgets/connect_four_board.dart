import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../bloc/game_bloc.dart';

class ConnectFourBoard extends StatelessWidget {
  const ConnectFourBoard({super.key});

  @override
  Widget build(BuildContext context) {
    // Board dimensions
    final int rows = 6;
    final int columns = 7;

    // Calculate sizes based on screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final boardWidth = screenWidth * 0.9; // 90% of screen width
    final cellSize = boardWidth / columns;
    final boardHeight = cellSize * rows;

    return Center(
      child: Container(
        width: boardWidth,
        height: boardHeight + 50, // Extra space for the column selectors
        child: Column(
          children: [
            // Column selectors (arrows)
            SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  columns,
                      (col) => _buildColumnSelector(context, col, cellSize),
                ),
              ),
            ),
            // Game board
            Container(
              width: boardWidth,
              height: boardHeight,
              decoration: BoxDecoration(
                color: AppColors.boardBlue,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Board grid with holes
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      childAspectRatio: 1,
                    ),
                    itemCount: rows * columns,
                    itemBuilder: (context, index) {
                      final row = index ~/ columns;
                      final col = index % columns;
                      return _buildCell(context, row, col, cellSize);
                    },
                  ),
                  // Game pieces (chips)
                  // This would be populated by the BLoC
                  _buildChip(2, 3, AppColors.chipRed, cellSize, columns),
                  _buildChip(3, 3, AppColors.chipYellow, cellSize, columns),
                  _buildChip(4, 3, AppColors.chipRed, cellSize, columns),
                  _buildChip(5, 3, AppColors.chipYellow, cellSize, columns),
                  _buildChip(3, 4, AppColors.chipRed, cellSize, columns),
                  _buildChip(4, 4, AppColors.chipYellow, cellSize, columns),
                  _buildChip(5, 4, AppColors.chipRed, cellSize, columns),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnSelector(BuildContext context, int column, double cellSize) {
    return GestureDetector(
      onTap: () {
        // BLoC implementation will go here
        // This would dispatch an event to drop a chip in this column
      },
      child: Container(
        width: cellSize,
        height: 40,
        child: Icon(
          Icons.arrow_drop_down,
          color: AppColors.primaryText,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col, double cellSize) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cell background
          Container(
            width: cellSize - 8,
            height: cellSize - 8,
            decoration: BoxDecoration(
              color: AppColors.boardBlue,
              shape: BoxShape.circle,
            ),
          ),
          // Cell hole (empty space)
          Container(
            width: cellSize - 16,
            height: cellSize - 16,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  spreadRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(int row, int col, Color color, double cellSize, int columns) {
    // Calculate position based on row and column
    final top = row * cellSize;
    final left = col * cellSize;

    return Positioned(
      top: top + 4,
      left: left + 4,
      child: Container(
        width: cellSize - 8,
        height: cellSize - 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.8),
              color,
            ],
            center: const Alignment(0.3, -0.3),
            focal: const Alignment(0.3, -0.3),
            radius: 0.8,
          ),
        ),
      ),
    );
  }
}

