import 'package:flutter/material.dart';

enum ItemCategory {
  TOOLS('Tools', Icons.build, 0),
  SPORT('Sport', Icons.sports_basketball, 1),
  CAMPING('Camping', Icons.outdoor_grill_outlined, 2),
  KITCHEN('Kitchen', Icons.fastfood_rounded, 3),
  SCHOOL('School', Icons.school, 4),
  EVENTS('Events', Icons.groups, 5),
  TRAVEL('Travel', Icons.airplanemode_active, 6),
  BOATS('Electronics', Icons.electric_bolt_rounded, 7),
  GAMES('Games', Icons.extension, 8),
  PETS('Pets', Icons.pets, 9);

  final String title;
  final IconData icon;
  final int idx;
  const ItemCategory(this.title, this.icon, this.idx);

  String getTitle() {
    return title;
  }

  IconData getIcon() {
    return icon;
  }
}

ItemCategory getCategoryByTitle(String title) {
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

ItemCategory getCategoryByIdx(int idx) {
  switch (idx) {
    case 0:
      return ItemCategory.TOOLS;
    case 1:
      return ItemCategory.SPORT;
    case 2:
      return ItemCategory.CAMPING;
    case 3:
      return ItemCategory.KITCHEN;
    case 4:
      return ItemCategory.SCHOOL;
    case 5:
      return ItemCategory.EVENTS;
    case 6:
      return ItemCategory.TRAVEL;
    case 7:
      return ItemCategory.BOATS;
    case 8:
      return ItemCategory.GAMES;
    case 9:
      return ItemCategory.PETS;
  }
  return ItemCategory.PETS;
}