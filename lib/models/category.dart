import 'package:flutter/material.dart';
// import 'package:rent_app/l10n/app_localizations.dart';

import 'package:rent_app/l10n/app_localizations.dart';


enum ItemCategory {
  TOOLS('Tools', Icons.build, 0),
  SPORT('Sport', Icons.sports_basketball, 1),
  CAMPING('Camping', Icons.outdoor_grill_outlined, 2),
  KITCHEN('Kitchen', Icons.fastfood_rounded, 3),
  SCHOOL('School', Icons.school, 4),
  EVENTS('Events', Icons.groups, 5),
  TRAVEL('Travel', Icons.airplanemode_active, 6),
  ELECTRONICS('Electronics', Icons.electric_bolt_rounded, 7),
  GAMES('Games', Icons.extension, 8),
  PETS('Pets', Icons.pets, 9);

  final String title;
  final IconData icon;
  final int idx;
  const ItemCategory(this.title, this.icon, this.idx);

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
    case 'Electronics':
      return ItemCategory.ELECTRONICS;
    case 'Games':
      return ItemCategory.GAMES;
    case 'Pets':
      return ItemCategory.PETS;
  }
  return ItemCategory.PETS;
}

ItemCategory getCategoryByIdx(int idx) {
  return ItemCategory.values[idx];
}

extension ItemCategoryExtension on ItemCategory {
  String getTitle(AppLocalizations localization) {
    switch (this) {
      case ItemCategory.TOOLS:
        return localization.categoryTools;
      case ItemCategory.SPORT:
        return localization.categorySport;
      case ItemCategory.CAMPING:
        return localization.categoryCamping;
      case ItemCategory.KITCHEN:
        return localization.categoryKitchen;
      case ItemCategory.SCHOOL:
        return localization.categorySchool;
      case ItemCategory.EVENTS:
        return localization.categoryEvents;
      case ItemCategory.TRAVEL:
        return localization.categoryTravel;
      case ItemCategory.ELECTRONICS:
        return localization.categoryElectronics;
      case ItemCategory.GAMES:
        return localization.categoryGames;
      case ItemCategory.PETS:
        return localization.categoryPets;
    }
  }
}
