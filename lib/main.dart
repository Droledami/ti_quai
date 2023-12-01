import 'dart:ui';

import 'package:flutter/material.dart';
import './theme.dart';

void main() {
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
            const SizedBox(
              height: 50,
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
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
    return Scaffold(
      appBar: AppBar(
        leading: MenuButton(customColors: customColors),
        centerTitle: true,
        title: TitleHeader(customColors: customColors),
        backgroundColor: Colors.white.withOpacity(0.0),
      ),
      drawer: const QuaiDrawer(),
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: customColors.secondary!,
        child: const Icon(
          Icons.add,
          size: 40,
        ),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: const Alignment(0.00, -1.00),
            end: const Alignment(0, 1),
            stops: const [0.0, 0.08, 0.9, 1.0],
            colors: [
              customColors.tertiaryDark!,
              customColors.tertiary!,
              customColors.primaryLight!,
              customColors.special!,
            ],
          ),
        ),
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
              Row(
                children: [
                  LittleCard(leftPadding: 10.0, text: "Qté"),
                  LittleCard(text: "A-Z"),
                  LittleCard(text: "N°"),
                  LittleCard(text: "a-z"),
                  LittleCard(text: "Sup."),
                  LittleCard(flex: 3, text: "Prix U."),
                  LittleCard(flex: 3, rightPadding: 10.0, text: "Total"),
                ],
              ),
              TextDivider(text: "Menu"),
              OrderElement(),
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

class OrderElement extends StatefulWidget {
  const OrderElement({super.key});

  @override
  State<OrderElement> createState() => _OrderElementState();
}

class _OrderElementState extends State<OrderElement> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LittleCard(leftPadding: 10.0, text: "2"),
        LittleCard(text: "B"),
        LittleCard(text: "1"),
        LittleCard(empty: true,),
        LittleCard(empty: true,),
        LittleCard(flex: 3, text: "13€"),
        LittleCard(flex: 3, rightPadding: 10.0, text: "26€"),
      ],
    );
  }
}

class TextDivider extends StatelessWidget {
  const TextDivider({super.key, required this.text});

  final String text;

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
          ),
        ),
        Divider(
          height: 2,
          thickness: 3,
          indent: 10,
          endIndent: 10,
          color: customColors.tertiary!,
        ),
        SizedBox(
          height: 4,
        ),
      ],
    );
  }
}

class LittleCard extends StatelessWidget {
  const LittleCard({
    super.key,
    this.leftPadding = 3,
    this.rightPadding = 0,
    this.flex = 1,
    this.empty = false,
    this.text = "",
  });

  final double leftPadding;
  final double rightPadding;
  final int flex;
  final bool empty;
  final String text;

  @override
  Widget build(BuildContext context) {
    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;
    if (empty) {
      return Expanded( // because of flex Expanded will take the same space as if there were something
        child: Padding(
          padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
          child: SizedBox(),
        ),
      );
    }
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
        child: Container(
          padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 3),
          decoration: BoxDecoration(
            color: customColors.primaryLight!,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.w900, height: 1.0, fontSize: 16),
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
