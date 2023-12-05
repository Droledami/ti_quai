import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/blocs/order/order_events.dart';
import 'package:ti_quai/firestore/firestore_service.dart';
import './theme.dart';
import 'BeachGradientDecoration.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/order/order_states.dart';
import 'enums/ArticleType.dart';
import 'enums/PaymentMethod.dart';
import 'firebase_options.dart';
import 'models/Article.dart';
import 'models/CustomerOrder.dart';
import 'models/OrderElement.dart';
import 'models/Promotion.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirestoreService firestoreService = FirestoreService();
  //
  // try {
  //   var oeList = List<OrderElement>.empty(growable: true);
  //   OrderElement oe = OrderElement(
  //       article: Article.menu(
  //           alpha: "B",
  //           number: 3,
  //           subAlpha: "y",
  //           name: "En selle Marcel",
  //           price: 12),
  //       quantity: 3);
  //   oe.promotion = Promotion(
  //       discountValue: 3, nameLong: "Stampit Fidélité", nameShort: "Stampit");
  //   oe.hasPromotion = true;
  //   oe.comment = "Sauce BBQ";
  //   oe.commentIsExtra = true;
  //   oe.extraPrice = 5;
  //
  //   OrderElement oe2 = OrderElement(
  //       article: Article.other(
  //           name: "Le beau bic",
  //           price: 3),
  //       quantity: 2);
  //   oe2.promotion = null;
  //   oe2.hasPromotion = false;
  //   oe2.comment = "";
  //   oe2.commentIsExtra = false;
  //   oe2.extraPrice = 0;
  //
  //   oeList.add(oe2);
  //   oeList.add(oe);
  //   firestoreService.updateOrder(CustomerOrder(
  //       id: "9RtXjsNAktg1ghWa9zGV",
  //       date: DateTime.now(),
  //       orderElements: oeList,
  //       paymentMethod: PaymentMethod.cash, tableNumber: 2));
  // } catch (e) {
  //   print(e);
  // }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(FirestoreService())),
      ],
      child: MaterialApp(
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
      ),
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

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    BlocProvider.of<OrderBloc>(context).add(LoadOrder());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final OrderBloc _orderBloc = BlocProvider.of<OrderBloc>(context);
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Container(
      decoration: BeachGradientDecoration(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        //Allows parent container's bg to display
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
        body: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is OrderLoaded) {
            return Column(
              children: [
                const SizedBox(
                  height: 65,
                ),
                Expanded(
                  flex: 7,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: state.orders.map((order) {
                        return OrderBox(order: order);
                      }).toList(),
                    ),
                  ),
                ),
                //Keeps some space at the bottom of the screen for visibility
                Expanded(flex: 1, child: SizedBox())
              ],
            );
          } else if (state is OrderOperationSuccess) {
            return Container();
          } else if (state is OrderError) {
            return Container();
          } else {
            return Container();
          }
        }),
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

class OrderBox extends StatefulWidget {
  const OrderBox({super.key, required this.order});

  final CustomerOrder order;

  @override
  State<OrderBox> createState() => _OrderBoxState();
}

class _OrderBoxState extends State<OrderBox> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    CustomerOrder order = widget.order;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selected = !_selected;
        });
      },
      child: Builder(builder: (context) {
        if (_selected) {
          return OrderDetailed(order: order);
        } else {
          return OrderSimple(order: order);
        }
      }),
    );
  }
}

class OrderDetailed extends StatefulWidget {
  const OrderDetailed({super.key, required this.order});

  final CustomerOrder order;

  @override
  State<OrderDetailed> createState() => _OrderDetailedState();
}

class _OrderDetailedState extends State<OrderDetailed> {

  bool hasOther = false;
  bool hasPromotion = false;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
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
              OrderHeader(
                tableNumber: widget.order.tableNumber,
                articleNumber: widget.order.orderElements.length,
                orderDate: widget.order.date,
              ),
              TextDivider(text: "Menu", color: customColors.tertiary!),
              Column(
                  children: widget.order.orderElements.map((orderElement) {
                if (orderElement.articleType == ArticleType.menu) {
                  return OrderLineElement(orderElement: orderElement);
                } else {
                  return SizedBox.shrink();
                }
              }).toList()),
              Column(
                children: [
                  Builder(
                    builder: (context) {
                      if(hasOther){
                        return TextDivider(text: "Autres", color: customColors.tertiary!);
                      }else{
                        return SizedBox.shrink();
                      }
                    }
                  ),
                  Column(
                      children: widget.order.orderElements.map((orderElement) {
                    if (orderElement.articleType == ArticleType.other) {
                      if(!hasOther) hasOther=true;
                      return OthersOrderLineElement(
                        productName: orderElement.articleName,
                        productPrice: orderElement.articlePrice,
                        quantity: orderElement.quantity,
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  }).toList()),
                ],
              ),
              TextDivider(text: "Promotions", color: customColors.tertiary!),
              Promotions(),
              GreatTotal(
                  paymentMethod: widget.order.paymentMethod,
                  totalPrice: widget.order.totalPrice),
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
    required this.paymentMethod,
    required this.totalPrice,
  });

  final PaymentMethod paymentMethod;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    String paymentMethodString = paymentMethod.name;
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
                      text: "Règlement par $paymentMethodString"),
                  LittleCard(
                      flex: 3,
                      height: 26,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      rightMargin: 5,
                      littleCardColor: customColors.special!,
                      text: "$totalPrice€"),
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
  const OrderHeader(
      {super.key,
      required this.tableNumber,
      required this.articleNumber,
      required this.orderDate});

  final int tableNumber;
  final int articleNumber;
  final DateTime orderDate;

  @override
  Widget build(BuildContext context) {
    final orderTime = getHourAndMinuteString(orderDate);
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return GestureDetector(
      onTap: () {
        print("close details"); //TODO: fermer la commande
      },
      child: Container(
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
                'Table $tableNumber',
                style: TextStyle(
                  height: 1,
                  fontSize: 30,
                ),
              ),
              title: Text(
                articleNumber > 1
                    ? "$articleNumber articles"
                    : "$articleNumber article",
                style: TextStyle(
                  height: 1,
                  fontSize: 24,
                ),
              ),
              trailing: Text(
                orderTime,
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

class OthersOrderLineElement extends StatelessWidget {
  const OthersOrderLineElement(
      {super.key,
      required this.productName,
      required this.productPrice,
      required this.quantity});

  final int quantity;
  final String productName;
  final double productPrice;

  @override
  Widget build(BuildContext context) {
    final double totalPrice = productPrice * quantity;
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
                text: "$quantity"),
            LittleCard(
                littleCardColor: customColors.primary!,
                flex: 5,
                text: productName),
            LittleCard(
                littleCardColor: customColors.primary!,
                flex: 2,
                text: "à $productPrice€/p"),
            LittleCard(
                littleCardColor: customColors.primary!,
                flex: 3,
                rightMargin: 10.0,
                text: "$totalPrice€"),
          ],
        ),
      ],
    );
  }
}

class OrderLineElement extends StatelessWidget {
  const OrderLineElement({super.key, required this.orderElement});

  final OrderElement orderElement;

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
                text: "${orderElement.quantity}"),
            LittleCard(
                littleCardColor: customColors.primaryLight!,
                text: orderElement.articleAlpha),
            LittleCard(
                littleCardColor: customColors.primaryLight!,
                text: "${orderElement.articleNumber}"),
            LittleCard(
              //Shows the subAlpha code of the order if it exists
              littleCardColor: customColors.primaryLight!,
              empty: orderElement.articleSubAlpha.isEmpty,
              text: orderElement.articleSubAlpha,
            ),
            LittleCard(
              //Show the price of the extra if there is one
              littleCardColor: customColors.primaryLight!,
              empty: !orderElement.commentIsExtra,
              text: "${orderElement.extraPrice}€",
            ),
            LittleCard(
                //Unit price for the article
                littleCardColor: customColors.primaryLight!,
                flex: 3,
                text: "${orderElement.articlePrice}€"),
            LittleCard(
                //Total price for the orderElement
                littleCardColor: customColors.primaryLight!,
                flex: 3,
                rightMargin: 10.0,
                text: "${orderElement.price}€"),
          ],
        ),
        Builder(builder: (context) {
          if (orderElement.comment.isNotEmpty) {
            return Comment(
              comment: orderElement.comment,
              isExtra: orderElement.commentIsExtra,
            );
          } else {
            return SizedBox.shrink();
          }
        }),
      ],
    );
  }
}

class Comment extends StatelessWidget {
  const Comment({super.key, this.isExtra = false, required this.comment});

  final bool isExtra;
  final String comment;

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
          '${isExtra ? "Supplément" : "Commentaire"}: $comment',
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
          padding: EdgeInsets.only(left: 2, right: 2, top: 3, bottom: 0),
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
                fontWeight: fontWeight, height: 1, fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}

class OrderSimple extends StatelessWidget {
  const OrderSimple({super.key, required this.order});

  final CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    final numberOfArticles = order.orderElements.length;
    String orderTime = getHourAndMinuteString(order.date);
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
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
                  'Table ${order.tableNumber}',
                  style: TextStyle(
                    height: 1,
                    fontSize: 30,
                  ),
                ),
                title: Text(
                  numberOfArticles > 1
                      ? "$numberOfArticles articles"
                      : "$numberOfArticles article",
                  style: TextStyle(
                    height: 1,
                    fontSize: 24,
                  ),
                ),
                trailing: Text(
                  orderTime,
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
                    "Règlement par ${order.paymentMethod.name}",
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
                    "${order.totalPrice}€",
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

String getHourAndMinuteString(DateTime date) {
  final String time = "${date.hour}:${date.minute}";
  return time;
}
