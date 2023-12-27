import 'package:flutter/material.dart';

import '../models/Article.dart';
import '../custom_materials/theme.dart';
import 'QuaiTextContainer.dart';

class ArticleListTile extends StatelessWidget {
  const ArticleListTile({super.key, required this.articleToDisplay});

  final Article articleToDisplay;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 3, left: 8, right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.primaryDark!,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                QuaiTextContainer(color: customColors.primaryLight!, text: articleToDisplay.name),
              ],
            ),
            Row(
              children: [
                QuaiTextContainer(text: articleToDisplay.reference, color: customColors.primaryLight!, marginBottom: 4,),
                QuaiTextContainer(text: "${articleToDisplay.price}€", color: customColors.primaryLight!, marginBottom: 4,)
              ],
            )
          ],
        ),
      ),
    );
  }
}