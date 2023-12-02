import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './theme.dart';
import 'BeachGradientDecoration.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(extensions: <ThemeExtension<dynamic>>[
        const CustomColors(
          primary: Color(0xFF7AE582),
          //For main products and menu buttons
          primaryDark: Color(0xFF25A18E),
          primaryLight: Color(0xFF9FFFCB),
          secondary: Color(0xFFF79256),
          //For promotions and action buttons
          secondaryLight: Color(0xFFFBD1A2),
          tertiary: Color(0xFF00A5CF),
          //Main background color
          tertiaryDark: Color(0xFF004E64),
          special: Color(0xFFD4E997),
          //For special elements such as comments and supplements
          cardQuarterTransparency: Color(0x4DFFFFFF),
          //White 30% alpha
          cardHalfTransparency: Color(0x80FFFFFF), //White 50% alpha
        ),
      ]),
      home: Homescreen(),
    );
  }
}

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
              onTap: () {},
            ),
            ListTile(
              title: const Text("Gestion d'articles"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class Homescreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Container(
      decoration: BeachGradientDecoration(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent, //Allows parent container's bg to display
        appBar: AppBar(
          leading: MenuButton(customColors: customColors),
          centerTitle: true,
          title: TitleHeader(customColors: customColors),
          backgroundColor: Colors.white.withOpacity(0.0),
        ),
        drawer: const QuaiDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: customColors.secondary!,
          child: const Icon(
            Icons.add,
            size: 40,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    OrderBox(),
                    OrderBox(),
                  ],
                ),
              ),
            ),
            //Keeps some space at the bottom of the screen for visibility
            Expanded(flex: 1, child: SizedBox())
          ],
        ),
      ),
    );
  }
}

class TitleHeader extends StatelessWidget {
  const TitleHeader({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      height: 55,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.00, -1.00),
          end: const Alignment(0, 1),
          stops: const [0.5, 8.0],
          colors: [
            customColors.primaryLight!,
            customColors.primary!,
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Center(
        child: Text(
          'Accueil',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 55,
      alignment: Alignment.center,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: const Alignment(0.00, -1.00),
          end: const Alignment(0, 1),
          stops: const [0.5, 8.0],
          colors: [
            customColors.primaryLight!,
            customColors.primary!,
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Builder(builder: (context) {
        return IconButton(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(2),
          icon: const Icon(Icons.menu_rounded),
          iconSize: 55,
          color: customColors.primaryDark!,
          onPressed: () => {Scaffold.of(context).openDrawer()},
        );
      }),
    );
  }
}

class OrderBox extends StatelessWidget {
  const OrderBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: () {},
      child: Builder(builder: (context) {
        if (true) {
          return OrderDetailed(customColors: customColors);
        } else {
          return OrderSimple(customColors: customColors);
        }
      }),
    );
  }
}

class OrderDetailed extends StatelessWidget {
  const OrderDetailed({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.cardQuarterTransparency!,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderHeader(),
              TextDivider(text: "Menu", color: customColors.tertiary!),
              OrderElement(),
              TextDivider(text: "Autres", color: customColors.tertiary!),
              OthersOrderElement(),
              TextDivider(text: "Promotions", color: customColors.tertiary!),
              Promotions(),
              GreatTotal(),
            ],
          ),
        ),
      ),
    );
  }
}

class GreatTotal extends StatelessWidget {
  const GreatTotal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            color: customColors.cardHalfTransparency!,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            TextDivider(
              text: "Grand Total",
              color: customColors.tertiary!,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  LittleCard(
                      flex: 8,
                      height: 26,
                      leftMargin: 5,
                      rightMargin: 2,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      littleCardColor: customColors.special!,
                      text: "Règlement par cash"),
                  LittleCard(
                      flex: 3,
                      height: 26,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      rightMargin: 5,
                      littleCardColor: customColors.special!,
                      text: "999.50€"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderHeader extends StatelessWidget {
  const OrderHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Container(
      padding: EdgeInsets.only(left: 0, right: 0, top: 2, bottom: 5),
      decoration: BoxDecoration(
        color: customColors.cardHalfTransparency!,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
          bottomLeft: Radius.circular(5),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
            leading: Text(
              'Table 1',
              style: TextStyle(
                height: 1,
                fontSize: 30,
              ),
            ),
            title: Text(
              '4 articles',
              style: TextStyle(
                height: 1,
                fontSize: 24,
              ),
            ),
            trailing: Text(
              '22:35',
              style: TextStyle(
                height: 1,
                fontSize: 24,
              ),
            ),
          ),
          Row(
            children: [
              LittleCard(
                  littleCardColor: customColors.primaryLight!,
                  leftMargin: 10.0,
                  text: "Qté"),
              LittleCard(
                  littleCardColor: customColors.primaryLight!, text: "A-Z"),
              LittleCard(
                  littleCardColor: customColors.primaryLight!, text: "N°"),
              LittleCard(
                  littleCardColor: customColors.primaryLight!, text: "a-z"),
              LittleCard(
                  littleCardColor: customColors.primaryLight!, text: "Sup."),
              LittleCard(
                  littleCardColor: customColors.primaryLight!,
                  flex: 3,
                  text: "Prix U."),
              LittleCard(
                  littleCardColor: customColors.primaryLight!,
                  flex: 3,
                  rightMargin: 10.0,
                  text: "Total"),
            ],
          ),
        ],
      ),
    );
  }
}

class Promotions extends StatelessWidget {
  const Promotions({super.key});

  @override
  Widget build(BuildContext context) {
    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          runAlignment: WrapAlignment.end,
          direction: Axis.horizontal,
          children: [
            PromotionCard(
              promotionName: "Discovery",
              discountValue: 10,
            ),
            PromotionCard(
              promotionName: "Discovery",
              discountValue: 10,
            ),
            PromotionCard(
              promotionName: "Discovery",
              discountValue: 10,
            ),
            PromotionCard(
              promotionName: "Discovery",
              discountValue: 10,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              //Offsets the other child to the end of the line
              flex: 8,
              child: SizedBox(),
            ),
            LittleCard(
              text: "-30€",
              flex: 3,
              littleCardColor: customColors.secondaryLight!,
              rightMargin: 10.0,
            )
          ],
        ),
      ],
    );
  }
}

class PromotionCard extends StatelessWidget {
  const PromotionCard(
      {super.key, required this.promotionName, required this.discountValue});

  final String promotionName;
  final double discountValue;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 0, top: 3, bottom: 2),
      child: Container(
        width: 120,
        padding: EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          color: customColors.secondary,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 3, right: 3),
              decoration: BoxDecoration(
                color: customColors.secondaryLight,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                "-$discountValue€",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text(
                promotionName,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OthersOrderElement extends StatelessWidget {
  const OthersOrderElement({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            LittleCard(
                littleCardColor: customColors.primary!,
                leftMargin: 10.0,
                text: "2"),
            LittleCard(
                littleCardColor: customColors.primary!,
                flex: 7,
                text: "Bic, Quai des Bananes"),
            LittleCard(
                littleCardColor: customColors.primary!,
                flex: 3,
                rightMargin: 10.0,
                text: "26€"),
          ],
        ),
      ],
    );
  }
}

class OrderElement extends StatelessWidget {
  const OrderElement({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            LittleCard(
                littleCardColor: customColors.primaryLight!,
                leftMargin: 10.0,
                text: "2"),
            LittleCard(littleCardColor: customColors.primaryLight!, text: "B"),
            LittleCard(littleCardColor: customColors.primaryLight!, text: "1"),
            LittleCard(
              littleCardColor: customColors.primaryLight!,
              empty: true,
            ),
            LittleCard(
              littleCardColor: customColors.primaryLight!,
              empty: true,
            ),
            LittleCard(
                littleCardColor: customColors.primaryLight!,
                flex: 3,
                text: "13€"),
            LittleCard(
                littleCardColor: customColors.primaryLight!,
                flex: 3,
                rightMargin: 10.0,
                text: "26€"),
          ],
        ),
        Comment(),
      ],
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({super.key, this.isExtra = false});

  final bool isExtra;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: EdgeInsets.only(left: 25, top: 5, bottom: 2, right: 10),
      child: Container(
        width: 450,
        padding: EdgeInsets.only(left: 2, right: 2, top: 3, bottom: 2),
        decoration: BoxDecoration(
          color: customColors.special!,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          '${isExtra ? "Supplément" : "Commentaire"}: Sauce barbecue',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class TextDivider extends StatelessWidget {
  const TextDivider({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 13,
    this.fontWeight = FontWeight.w500,
    this.endIndent = 10,
  });

  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, top: 5),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ),
        Divider(
          height: 2,
          thickness: 3,
          indent: 10,
          endIndent: endIndent,
          color: color,
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }
}

class LittleCard extends StatelessWidget {
  const LittleCard(
      {super.key,
      this.leftMargin = 3,
      this.rightMargin = 0,
      this.flex = 1,
      this.empty = false,
      this.text = "",
      this.height = 20,
      this.fontSize = 16,
      this.fontWeight = FontWeight.w900,
      required this.littleCardColor});

  final double leftMargin;
  final double rightMargin;
  final int flex;
  final bool empty;
  final String text;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final Color littleCardColor;

  @override
  Widget build(BuildContext context) {
    if (empty) {
      return Expanded(
        // because of flex Expanded will take the same space as if there were something
        child: Padding(
          padding: EdgeInsets.only(left: leftMargin, right: rightMargin),
          child: SizedBox(),
        ),
      );
    }
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(left: leftMargin, right: rightMargin),
        child: Container(
          height: height,
          padding: EdgeInsets.only(left: 2, right: 2, top: 3, bottom: 2),
          decoration: BoxDecoration(
            color: littleCardColor,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: fontWeight, height: 1.0, fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}

class OrderSimple extends StatelessWidget {
  const OrderSimple({
    super.key,
    required this.customColors,
  });

  final CustomColors customColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.cardQuarterTransparency!,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.only(
                    left: 10, right: 10, top: 0, bottom: 0),
                leading: Text(
                  'Table 1',
                  style: TextStyle(
                    height: 1,
                    fontSize: 30,
                  ),
                ),
                title: Text(
                  '4 articles',
                  style: TextStyle(
                    height: 1,
                    fontSize: 24,
                  ),
                ),
                trailing: Text(
                  '22:35',
                  style: TextStyle(
                    height: 1,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(
                    left: 10, right: 10, top: 0, bottom: 0),
                title: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: customColors.special!,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'Règlement par cash',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1,
                      fontSize: 24,
                    ),
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: customColors.special!,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '999,50€',
                    style: TextStyle(
                      height: 1,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
