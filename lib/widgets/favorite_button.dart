import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/cloud_services.dart';

class FavoriteButton extends StatelessWidget {
  final Item item;

  const FavoriteButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getUserFavoriteItem(item.docRef),
      builder: (context, snapshot) {
        bool isFavorite = snapshot.hasData && snapshot.data!;
        return Icon(
          isFavorite ? Icons.favorite : Icons.favorite_outline,
          size: 25,
          color: isFavorite ? Colors.red : Colors.white,
        );
      },
    );
  }
}
