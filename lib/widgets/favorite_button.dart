import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rent_app/main.dart';
import '../constants.dart';
import '../models/item.dart';
import '../services/cloud_services.dart';

class FavoriteButton extends StatefulWidget {
  final Item item;

  const FavoriteButton({super.key, required this.item});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getUserFavoriteItem(widget.item.docRef),
      builder: (context, snapshot) {
        bool isFavorite = snapshot.hasData && snapshot.data!;
        return IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          constraints: const BoxConstraints(),
          style: const ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () {
            toggleUserFavoriteItem(widget.item.docRef);
          },
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_outline,
            size: 25,
            color: isFavorite ? Colors.red : Colors.white,
          ),
        );
      },
    );
  }
}
