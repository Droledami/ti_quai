import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ti_quai/custom_widgets/EntryBox.dart';
import 'package:ti_quai/enums/EntryType.dart';
import 'package:ti_quai/models/Article.dart';

import '../enums/ArticleType.dart';
import '../models/CustomerOrder.dart';
import '../models/OrderElement.dart';
import '../theme.dart';
import 'GreatTotal.dart';
import 'LittleCard.dart';
import 'OrderHeader.dart';
import 'OrderLineElement.dart';
import 'OthersOrderLineElement.dart';
import 'PromotionLineLong.dart';
import 'TextDivider.dart';

class OrderToEditOrAdd extends StatefulWidget {
  const OrderToEditOrAdd(
      {super.key, required this.order, required this.isEditMode});

  final CustomerOrder order;
  final bool isEditMode;

  @override
  State<OrderToEditOrAdd> createState() => _OrderToEditOrAddState();
}

class _OrderToEditOrAddState extends State<OrderToEditOrAdd> {
  bool hasOther = false;

  bool addingOrderElement = false;
  bool addingPromotion = false;

  @override
  Widget build(BuildContext context) {
    final hasPromotion = widget.order.hasAnyPromotions;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.cardQuarterTransparency!,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            OrderHeader(
              tableNumber: widget.order.tableNumber,
              articleNumber: widget.order.orderElements.length,
              orderDate: widget.order.date,
              isEditMode: widget.isEditMode,
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
            Builder(
              builder: (context) {
                return addingOrderElement ? AddOrderElementForm(onCancel: (){
                  setState(() {
                    addingOrderElement = false;
                  });
                },
                  onConfirmAdd: (){
                  setState(() {
                    addingOrderElement = false;
                    //TODO:ajouter un orderElement
                  });
                  },
                  onOpenComment: (){
                  //TODO: gérer l'ajout de commentaire p-e un état
                  },
                  onOpenExtra: (){
                  //TODO: gérer l'ajout de supplément p-e un état
                  },
                ) : SizedBox.shrink() ;
              }
            ),
            Builder(
              builder: (context) {
                if(!addingOrderElement){
                return SizedIconButton(
                  onTap: (){
                    setState(() {
                      addingOrderElement=true;
                    });
                  },
                  color: customColors.primary!,
                  spreadColor: customColors.primaryDark!,
                  iconData: Icons.add,
                );
                }else{
                  return SizedBox.shrink();
                }
              }
            ),
            Column(
              children: [
                Builder(builder: (context) {
                  if (hasOther) {
                    return TextDivider(
                        text: "Autres", color: customColors.tertiary!);
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                Column(
                    children: widget.order.orderElements.map((orderElement) {
                  if (orderElement.articleType == ArticleType.other) {
                    if (!hasOther) hasOther = true;
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
            Column(
              children: [
                Builder(builder: (context) {
                  if (hasPromotion || !widget.isEditMode) {
                    return Column(
                      children: [
                        TextDivider(
                            text: "Promotions", color: customColors.tertiary!),
                        Row(
                          children: [
                            LittleCard(
                                littleCardColor: customColors.secondary!,
                                leftMargin: 10.0,
                                height: 30,
                                flex: 6,
                                text: "Promotion"),
                            LittleCard(
                                littleCardColor: customColors.secondary!,
                                flex: 2,
                                fontSize: 13,
                                maxLines: 2,
                                height: 30,
                                text: "Article \n associé"),
                            LittleCard(
                                littleCardColor: customColors.secondaryLight!,
                                height: 30,
                                flex: 4,
                                rightMargin: 10.0,
                                text: "Réduction"),
                          ],
                        ),
                        SizedBox(height: 15),
                      ],
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                Column(
                  children: widget.order.orderElements.map((orderElement) {
                    if (orderElement.hasPromotion &&
                        orderElement.promotion != null) {
                      return PromotionLineLong(
                          promotion: orderElement.promotion!,
                          linkedArticle: orderElement.article);
                    } else if (orderElement.hasPromotion &&
                        orderElement.promotion == null) {
                      print(
                          "Error, a promotion has incorrectly set values : hasPromotion is true, yet promotion is null");
                      return SizedBox();
                    } else if (!orderElement.hasPromotion &&
                        orderElement.promotion != null) {
                      print(
                          "Warning, a promotion has incorrectly set values : hasPromotion is false, yet promotion has data");
                      return PromotionLineLong(
                          promotion: orderElement.promotion!,
                          linkedArticle: orderElement.article);
                    } else {
                      return SizedBox();
                    }
                  }).toList(),
                ),
              ],
            ),
            SizedIconButton(
              onTap: (){
                print("coucou");
              },
                color: customColors.secondary!,
                spreadColor: customColors.secondaryLight!,
              iconData: Icons.add,
            ),
            GreatTotal(
                paymentMethod: widget.order.paymentMethod,
                totalPrice: widget.order.totalPrice),
          ],
        ),
      ),
    );
  }
}

class AddOrderElementForm extends StatefulWidget {
  const AddOrderElementForm({
    super.key,
    required this.onCancel,
    required this.onOpenComment,
    required this.onOpenExtra,
    required this.onConfirmAdd
  });

  final Function onCancel;
  final Function onOpenComment;
  final Function onOpenExtra;
  final Function onConfirmAdd;

  @override
  State<AddOrderElementForm> createState() => _AddOrderElementFormState();
}

class _AddOrderElementFormState extends State<AddOrderElementForm> {

  OrderElement orderElement = OrderElement(article: Article.empty(type: ArticleType.menu), quantity: 1);

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
    Theme.of(context).extension<CustomColors>()!;
    return Form(
      child: Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: customColors.primaryDark!, width: 3)
            ),
            child: Column(
              children: [
                Row(
                  children: ["Quantité","Alphabet","Numéro","Sous-alpha"].map((header){
                    return Expanded(child: Text(header, textAlign: TextAlign.center,));
                  }).toList(),
                ),
                Row(
                  children: [
                    EntryBox(orderEntryType: OrderEntry.quantity, initialValue: "1", maxLength: 2, placeholder: "Qté", marginLeft: 10, marginRight: 3,),
                    EntryBox(orderEntryType: OrderEntry.alpha, initialValue: "", maxLength: 1, placeholder: "A-Z", marginLeft: 3,marginRight: 3,),
                    EntryBox(orderEntryType: OrderEntry.number, initialValue: "", maxLength: 3, placeholder: "N°", marginLeft: 3,marginRight: 3,),
                    EntryBox(orderEntryType: OrderEntry.subAlpha, initialValue: "", maxLength: 1, placeholder: "a-z", marginLeft: 3,)
                  ]
                ),
                Row(
                  children: [
                    FlexIconButton(color: customColors.primary!, spreadColor: customColors.primaryDark!, iconData: Icons.backspace, marginLeft: 10, onTap: ()=> widget.onCancel(),),
                    FlexIconButton(color: customColors.primary!, spreadColor: customColors.primaryDark!, iconData: Icons.comment, onTap: ()=> widget.onOpenComment(),),
                    FlexIconButton(color: customColors.primary!, spreadColor: customColors.primaryDark!, iconData: Icons.assignment_add, onTap: ()=> widget.onOpenExtra(),),
                    FlexIconButton(color: customColors.primary!, spreadColor: customColors.primaryDark!, iconData: Icons.add, marginRight: 0,onTap: ()=> widget.onConfirmAdd(),),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SizedIconButton extends StatelessWidget {
  const SizedIconButton({super.key, required this.color, required this.spreadColor, required this.iconData, required this.onTap, this.iconSize = 40});

  final Color color;
  final Color spreadColor;
  final IconData iconData;
  final Function onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 5),
      child: Container(
        width: 90,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
                color: Colors.black45,
                offset: Offset.fromDirection(1, 4),
                blurStyle: BlurStyle.normal,
                blurRadius: 4)
          ],
        ),
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(7),
          child: InkWell(
              borderRadius: BorderRadius.circular(7),
              splashColor: spreadColor,
              onTap: () => onTap(),
              child: Icon(
                iconData,
                size: iconSize,
              )),
        ),
      ),
    );
  }
}

class FlexIconButton extends StatelessWidget {
  const FlexIconButton({super.key, required this.onTap, required this.color, required this.spreadColor, required this.iconData, this.flex = 1, this.marginLeft = 3, this.marginRight = 3, this.marginTop = 3, this.marginBottom = 6});

  final Function onTap;
  final Color color;
  final Color spreadColor;
  final IconData iconData;
  final int flex;
  final double marginLeft;
  final double marginRight;
  final double marginTop;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: flex,
        child: Padding(
          padding: EdgeInsets.only(left: marginLeft, right: marginRight, top: marginTop, bottom: marginBottom),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                    color: Colors.black45,
                    offset: Offset.fromDirection(1, 4),
                    blurStyle: BlurStyle.normal,
                    blurRadius: 4)
              ],
            ),
            child: Material(
              color: color,
              borderRadius: BorderRadius.circular(7),
              child: InkWell(
                  borderRadius: BorderRadius.circular(7),
                  splashColor: spreadColor,
                  onTap: () => onTap(),
                  child: Icon(
                    iconData,
                    size: 40,
                  )),
            ),
          ),
        ),
      );
  }
}