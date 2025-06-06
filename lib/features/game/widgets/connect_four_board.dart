import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ConnectFourBoard extends StatelessWidget {
  final List<List<int?>> board;
  final Offset? lastMove;
  final bool isPlayerTurn;
  final AnimationController dropAnimationController;
  final Function(int) onColumnTapped;

  const ConnectFourBoard({
    super.key,
    required this.board,
    this.lastMove,
    required this.isPlayerTurn,
    required this.dropAnimationController,
    required this.onColumnTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Board dimensions
    final int rows = board.length;
    final int columns = board[0].length;

    // Calculate sizes based on screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final boardWidth = screenWidth * 0.9; // 90% of screen width
    final cellSize = boardWidth / columns;
    final boardHeight = cellSize * rows;

    return Center(
      child: Column(
        children: [
          // Column selectors (arrows)
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                for (int row = 0; row < rows; row++)
                  for (int col = 0; col < columns; col++)
                    if (board[row][col] != null && board[row][col] != 0)
                      _buildChip(
                        row,
                        col,
                        board[row][col] == 1 ? AppColors.chipRed : AppColors.chipYellow,
                        cellSize,
                        columns,
                        isHighlighted: lastMove != null &&
                            lastMove!.dy.toInt() == row &&
                            lastMove!.dx.toInt() == col,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnSelector(BuildContext context, int column, double cellSize) {
    final bool isColumnFull = !board.any((row) => row[column] == 0);

    return GestureDetector(
      onTap: isPlayerTurn && !isColumnFull
          ? () => onColumnTapped(column)
          : null,
      child: Container(
        width: cellSize,
        height: 40,
        child: Icon(
          Icons.arrow_drop_down,
          color: isPlayerTurn && !isColumnFull
              ? AppColors.primaryText
              : AppColors.secondaryText.withOpacity(0.3),
          size: 40,
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int row, int col, double cellSize) {
    final value = board[row][col];

    Color fillColor;
    if (value == 1) {
      fillColor = AppColors.chipRed;
    } else if (value == 2) {
      fillColor = AppColors.chipYellow;
    } else {
      fillColor = AppColors.primaryText; // empty/null = black
    }

    return GestureDetector(
      onTap: () => onColumnTapped(col),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.boardBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: cellSize * 0.6,
            height: cellSize * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              boxShadow: [
                if (value != null)
                  BoxShadow(
                    color: fillColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildChip(
      int row,
      int col,
      Color color,
      double cellSize,
      int columns,
      {bool isHighlighted = false}
      ) {
    // Calculate position based on row and column
    final top = row * cellSize;
    final left = col * cellSize;

    return Positioned(
      top: top + 4,
      left: left + 4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
          border: isHighlighted
              ? Border.all(
            color: Colors.white,
            width: 2,
          )
              : null,
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

