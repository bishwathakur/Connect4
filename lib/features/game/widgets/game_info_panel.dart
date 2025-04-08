import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class GameInfoPanel extends StatelessWidget {
  final bool isPlayerTurn;
  final int turnNumber;
  final Color currentPlayerColor;

  const GameInfoPanel({
    super.key,
    required this.isPlayerTurn,
    required this.turnNumber,
    required this.currentPlayerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Turn indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: currentPlayerColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: currentPlayerColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Turn status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPlayerTurn ? 'Your Turn' : 'Opponent\'s Turn',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Turn $turnNumber',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Timer (optional)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: AppColors.secondaryText,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '0:30',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

