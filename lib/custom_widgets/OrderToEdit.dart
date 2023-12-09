import 'dart:js_util';

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

  TextEditingController _tableNumberController = TextEditingController();

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
              textEditingController: _tableNumberController,
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
            Builder(builder: (context) {
              return addingOrderElement
                  ? AddOrderElementForm(
                      onCancel: () {
                        setState(() {
                          addingOrderElement = false;
                        });
                      },
                      onConfirmAdd: (OrderElement orderElement) {
                        setState(() {
                          addingOrderElement = false;
                          print(
                              "${orderElement.quantity} ${orderElement.articleAlpha} ${orderElement.articleNumber}, ${orderElement.articleSubAlpha}");
                          //TODO: déduire le prix via une db
                          widget.order.orderElements.add(orderElement);
                        });
                      },
                    )
                  : SizedBox.shrink();
            }),
            Builder(builder: (context) {
              if (!addingOrderElement) {
                return SizedIconButton(
                  onTap: () {
                    setState(() {
                      addingOrderElement = true;
                    });
                  },
                  color: customColors.primary!,
                  spreadColor: customColors.primaryDark!,
                  iconData: Icons.add,
                );
              } else {
                return SizedBox.shrink();
              }
            }),
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
                  if (widget.isEditMode) {
                    return Column(
                      children: [
                        TextDivider(
                            text: "Promotions", color: customColors.tertiary!),
                        Builder(builder: (context) {
                          if (hasPromotion) {
                            return Row(
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
                                    littleCardColor:
                                        customColors.secondaryLight!,
                                    height: 30,
                                    flex: 4,
                                    rightMargin: 10.0,
                                    text: "Réduction"),
                              ],
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }),
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
              onTap: () {
                print("Ajouter une promotion");
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
    required this.onConfirmAdd,
  });

  final Function onCancel;
  final Function(OrderElement) onConfirmAdd;

  @override
  State<AddOrderElementForm> createState() => _AddOrderElementFormState();
}

class _AddOrderElementFormState extends State<AddOrderElementForm> {
  OrderElement orderElement =
      OrderElement(article: Article.empty(type: ArticleType.menu), quantity: 1);

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _alphaController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _subAlphaController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _extraPriceController = TextEditingController();

  bool addingComment = false;
  bool addingExtra = false;

  @override
  void initState() {
    super.initState();
    _quantityController.text = "1";
    _quantityController.addListener(() {
      if(int.tryParse(_quantityController.text)!=null){
      orderElement.quantity = int.parse(_quantityController.text);
      }
    });
    _alphaController.addListener(() {
      orderElement.article.alpha = _alphaController.text;
    });
    _numberController.addListener(() {
      if(int.tryParse(_numberController.text)!=null){
        orderElement.article.number = int.parse(_numberController.text);
      }
    });
    _subAlphaController.addListener(() {
      orderElement.article.subAlpha = _subAlphaController.text;
    });
    _extraPriceController.addListener(() {
      if(!RegExp(r"^[0-9]+€?").hasMatch(_extraPriceController.text)){
        _extraPriceController.text = "";
      }else if(_extraPriceController.text.isNotEmpty && !_extraPriceController.text.contains("€")){
        String content = _extraPriceController.text;
        _extraPriceController.text = "$content€";
      }
    });
  }

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
                border: Border.all(color: customColors.primaryDark!, width: 3)),
            child: Builder(
              builder: (context) {
                if(!addingComment && !addingExtra){
                return Column(
                  children: [
                    Row(
                      children: ["Quantité", "Alphabet", "Numéro", "Sous-alpha"]
                          .map((header) {
                        return Expanded(
                            child: Text(
                          header,
                          textAlign: TextAlign.center,
                        ));
                      }).toList(),
                    ),
                    Row(children: [
                      EntryBox(
                        textEditingController: _quantityController,
                        orderEntryType: OrderEntry.quantity,
                        maxLength: 2,
                        placeholder: "Qté",
                        marginLeft: 10,
                        marginRight: 3,
                      ),
                      EntryBox(
                        textEditingController: _alphaController,
                        orderEntryType: OrderEntry.alpha,
                        maxLength: 1,
                        placeholder: "A-Z",
                        marginLeft: 3,
                        marginRight: 3,
                      ),
                      EntryBox(
                        textEditingController: _numberController,
                        orderEntryType: OrderEntry.number,
                        maxLength: 3,
                        placeholder: "N°",
                        marginLeft: 3,
                        marginRight: 3,
                      ),
                      EntryBox(
                        textEditingController: _subAlphaController,
                        orderEntryType: OrderEntry.subAlpha,
                        maxLength: 1,
                        placeholder: "a-z",
                        marginLeft: 3,
                      )
                    ]),
                    Row(
                      children: [
                        FlexIconButton(
                          color: customColors.primary!,
                          spreadColor: customColors.primaryDark!,
                          iconData: Icons.backspace,
                          marginLeft: 10,
                          onTap: () => widget.onCancel(),
                        ),
                        FlexIconButton(
                          color: customColors.primary!,
                          spreadColor: customColors.primaryDark!,
                          iconData: Icons.comment,
                          onTap: () {
                            orderElement.comment = _commentController.text;
                            orderElement.commentIsExtra = false;
                            setState(() {
                              addingComment= true;
                            });
                          },
                        ),
                        FlexIconButton(
                          color: customColors.primary!,
                          spreadColor: customColors.primaryDark!,
                          iconData: Icons.assignment_add,
                          onTap: () {
                            orderElement.comment = _commentController.text;
                            orderElement.commentIsExtra = true;
                            setState(() {
                              addingExtra = true;
                            });
                          },
                        ),
                        FlexIconButton(
                          color: customColors.primary!,
                          spreadColor: customColors.primaryDark!,
                          iconData: Icons.add,
                          marginRight: 0,
                          onTap: () => widget.onConfirmAdd(orderElement),
                        ),
                      ],
                    )
                  ],
                );
                }else if(addingComment || addingExtra){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${addingExtra ? "Supplément" : "Commentaire"} pour l'élément: ${orderElement.articleReference}"),
                      Row(
                        children: [
                          EntryBox(orderEntryType: OrderEntry.text, flex: 4, maxLength: 150, lines: addingExtra ? 1 : 2, textAlign: TextAlign.left, placeholder: "${addingExtra ? "Supplément" : "Commentaire"}...", textEditingController: _commentController, marginLeft: 10,),
                          Builder(builder: (context){
                            if(addingExtra){
                              return EntryBox(orderEntryType: OrderEntry.price, flex: 1, maxLength: 2, placeholder: "Prix", textEditingController: _extraPriceController, marginLeft: 6,);
                            }else{
                              return SizedBox.shrink();
                            }
                          })
                        ],
                      ),
                      Row(
                        children: [
                          FlexIconButton(onTap: (){
                            setState(() {
                              addingComment = false;
                              addingExtra = false;
                            });
                          }, color: customColors.primary!, spreadColor: customColors.primaryDark!, iconData: Icons.backspace, marginLeft: 10,),
                          Expanded(flex: 2, child: SizedBox.shrink()),
                          FlexIconButton(onTap: (){
                            orderElement.comment = _commentController.text;
                            if(addingExtra){
                              String extraPriceStr = _extraPriceController.text.replaceFirst("€", "", 1);
                              orderElement.extraPrice = double.parse(extraPriceStr);
                            }
                            setState(() {
                              addingComment = false;
                              addingExtra = false;
                            });
                          }, color: customColors.primary!, spreadColor: customColors.primaryDark!, iconData: Icons.add,),
                        ],
                      )
                    ],
                  );
                }else if(addingExtra && addingComment){
                  throw Exception("State addingExtra and addingComment are mutually exclusive, logic within widget AddOrderElementForm is wrong");
                }else{
                  throw Exception("Unexpected error");
                }
              }
            ),
          ),
        ),
      ),
    );
  }
}

class SizedIconButton extends StatelessWidget {
  const SizedIconButton(
      {super.key,
      required this.color,
      required this.spreadColor,
      required this.iconData,
      required this.onTap,
      this.iconSize = 40});

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
  const FlexIconButton(
      {super.key,
      required this.onTap,
      required this.color,
      required this.spreadColor,
      required this.iconData,
      this.flex = 1,
      this.marginLeft = 3,
      this.marginRight = 3,
      this.marginTop = 3,
      this.marginBottom = 6});

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
        padding: EdgeInsets.only(
            left: marginLeft,
            right: marginRight,
            top: marginTop,
            bottom: marginBottom),
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
