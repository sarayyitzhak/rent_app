import 'package:flutter/material.dart';
import 'package:rent_app/screens/category_screen.dart';

import '../constants.dart';
import '../models/category.dart';
import '../services/firebase_services.dart';

class CategoryListTile extends StatelessWidget {
  ItemCategory category;
  CategoryListTile({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(child: Icon(category.icon, color: Colors.black54,), backgroundColor: kActiveButtonColor),
        title: Text(
          category.title,
        ),
        tileColor: kPastelYellowOpacity,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
          Future.delayed(Duration(milliseconds: 180), () {
            Navigator.pushNamed(context, CategoryScreen.id, arguments: CategoryScreenArguments(category));
          });
          // Navigator.pushNamed(context, CategoryScreen.id, arguments: CategoryScreenArguments(category));
        },
      ),
    );
  }
}
