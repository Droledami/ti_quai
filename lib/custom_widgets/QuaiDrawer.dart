import 'package:flutter/material.dart';

import '../custom_materials/theme.dart';
import 'order_display/TextDivider.dart';

class QuaiDrawer extends StatelessWidget {
  const QuaiDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0.00, -1.00),
            end: const Alignment(0, 1),
            stops: const [0.5, 8.0],
            colors: [
              customColors.primaryLight!,
              customColors.primary!,
            ],
          ),
        ),
        child: ListView(
          children: [
            SizedBox(
              height: 50,
              child: TextDivider(
                text: "Menu",
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: customColors.primaryDark!,
                endIndent: 175,
              ),
            ),
            ListTile(
              title: const Text("Accueil"),
              onTap: () {
                //Pop twice because drawer being opened counts as being on the stack
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, "/home");
              },
            ),
            ListTile(
              title: const Text("Gestion d'articles"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pushNamed(context, "/articles");
              },
            ),
          ],
        ),
      ),
    );
  }
}