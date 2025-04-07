import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PlayerInfo extends StatelessWidget {
  final String name;
  final Color color;
  final bool isCurrentTurn;
  final CrossAxisAlignment alignment;

  const PlayerInfo({
    super.key,
    required this.name,
    required this.color,
    required this.isCurrentTurn,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentTurn
            ? AppColors.backgroundLight
            : AppColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentTurn
            ? Border.all(color: color, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: alignment == CrossAxisAlignment.start
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (alignment == CrossAxisAlignment.start)
                _buildPlayerChip(),
              Text(
                name,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (alignment == CrossAxisAlignment.end)
                _buildPlayerChip(),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isCurrentTurn ? "Your turn" : "Waiting...",
            style: TextStyle(
              color: isCurrentTurn
                  ? color
                  : AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerChip() {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

