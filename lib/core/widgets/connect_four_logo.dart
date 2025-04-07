import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ConnectFourLogo extends StatelessWidget {
  final double size;

  const ConnectFourLogo({
    super.key,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.boardBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Yellow chip
          Positioned(
            top: size * 0.25,
            left: size * 0.25,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: const BoxDecoration(
                color: AppColors.chipYellow,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Red chip
          Positioned(
            bottom: size * 0.25,
            right: size * 0.25,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: const BoxDecoration(
                color: AppColors.chipRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

