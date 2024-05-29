import 'package:clothes_tracker/src/models/category.dart';
import 'package:clothes_tracker/src/models/db_entry.dart';
import 'package:clothes_tracker/src/ui/display_card.dart';
import 'package:clothes_tracker/src/utils/app_page_controller.dart';
import 'package:flutter/material.dart';

class CommonPageLayout extends StatelessWidget {
  final List<DbEntry> data;
  final Map<int, Category> categoryMap;
  final AppPageController controller;

  const CommonPageLayout(
      {super.key,
      required this.data,
      required this.controller,
      required this.categoryMap});

  @override
  Widget build(BuildContext context) {
    // Make an empty list of categories
    Map<Category, List<DbEntry>> localData = {};

    // Only add categories that have items in the list
    for (DbEntry entry in data) {
      Category category = categoryMap[entry.categoryId]!;
      if (localData.containsKey(category)) {
        if (localData[category] != null) {
          localData[category]!.add(entry);
        } else {
          localData[category] = [entry];
        }
      } else {
        localData[category] = [entry];
      }
    }

    // Sort the categories by their id
    List<Category> sortedCategories = localData.keys.toList();
    sortedCategories.sort((a, b) => a.id.compareTo(b.id));

    // Map a list of cards to each category
    Map<Category, List<Widget>> categoryCards = {};
    for (Category category in sortedCategories) {
      List<Widget> cards = [];
      for (DbEntry entry in localData[category]!) {
        cards.add(
          Dismissible(
            key: Key(entry.id.toString()),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                controller.moveToBasket(entry.id);
              } else {
                controller.moveToCloset(entry.id);
              }
            },
            background: Container(
              color: Colors.green,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Icon(
                    Icons.door_sliding_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.shopping_basket,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            child: DisplayCard(data: entry),
          ),
        );
      }
      categoryCards[category] = cards;
    }

    // Return a ListView of the categories
    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, idx) {
        Category category = sortedCategories[idx];
        return ExpansionTile(
          initiallyExpanded: false,
          title: Text(
            category.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: categoryCards[category]!,
        );
      },
    );
  }
}
