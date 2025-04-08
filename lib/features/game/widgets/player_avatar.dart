import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  final Color color;
  final double size;
  final String? imageUrl;

  const PlayerAvatar({
    super.key,
    required this.color,
    this.size = 40,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.person,
              color: color,
              size: size * 0.6,
            );
          },
        ),
      )
          : Icon(
        Icons.person,
        color: color,
        size: size * 0.6,
      ),
    );
  }
}

