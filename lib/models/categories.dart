
import 'package:flutter/material.dart';

class Category{
  String title;
  IconData icon;
  Category({required this.title, required this.icon});
}

List<Category> categories = [
  Category(title: 'Tools', icon: Icons.build),
  Category(title: 'Sport', icon: Icons.sports_basketball),
  Category(title: 'Camping', icon: Icons.outdoor_grill_outlined),
  Category(title: 'Kitchen', icon: Icons.fastfood_rounded),
  Category(title: 'School', icon: Icons.school),
  Category(title: 'Events', icon: Icons.groups),
  Category(title: 'Travel', icon: Icons.airplanemode_active),
  Category(title: 'Boats', icon: Icons.directions_boat),
  Category(title: 'Games', icon: Icons.extension),
  Category(title: 'Pets', icon: Icons.pets),
];

