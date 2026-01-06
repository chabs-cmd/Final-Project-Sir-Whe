import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        widget.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: widget.isFavorite ? Colors.red : Colors.grey,
        size: 28,
      ),
      onPressed: widget.onPressed,
    );
  }
}

