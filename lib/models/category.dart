import 'package:flutter/material.dart';

enum ItemCategory {
  TOOLS('Tools', Icons.build),
  SPORT('Sport', Icons.sports_basketball),
  CAMPING('Camping', Icons.outdoor_grill_outlined),
  KITCHEN('Kitchen', Icons.fastfood_rounded),
  SCHOOL('School', Icons.school),
  EVENTS('Events', Icons.groups),
  TRAVEL('Travel', Icons.airplanemode_active),
  BOATS('Boats', Icons.directions_boat),
  GAMES('Games', Icons.extension),
  PETS('Pets', Icons.pets);

  final String title;
  final IconData icon;
  const ItemCategory(this.title, this.icon);

  String getTitle() {
    return title;
  }

  IconData getIcon() {
    return icon;
  }
}

ItemCategory getCategoryBtTitle(String title) {
  switch (title) {
    case 'Tools':
      return ItemCategory.TOOLS;
    case 'Sport':
      return ItemCategory.SPORT;
    case 'Camping':
      return ItemCategory.CAMPING;
    case 'Kitchen':
      return ItemCategory.KITCHEN;
    case 'School':
      return ItemCategory.SCHOOL;
    case 'Events':
      return ItemCategory.EVENTS;
    case 'Travel':
      return ItemCategory.TRAVEL;
    case 'Boats':
      return ItemCategory.BOATS;
    case 'Games':
      return ItemCategory.GAMES;
    case 'Pets':
      return ItemCategory.PETS;
  }
  return ItemCategory.PETS;
}
