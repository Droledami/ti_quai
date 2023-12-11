import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ti_quai/custom_widgets/EntryBox.dart';
import 'package:ti_quai/enums/EntryType.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';
import 'package:ti_quai/models/Article.dart';

import '../enums/ArticleType.dart';
import '../models/CustomerOrder.dart';
import '../models/OrderElement.dart';
import '../models/Promotion.dart';
import '../theme.dart';
import 'FlexIconButton.dart';
import 'GreatTotal.dart';
import 'LittleCard.dart';
import 'OrderHeader.dart';
import 'OrderLineElement.dart';
import 'OthersOrderLineElement.dart';
import 'PromotionLine.dart';
import 'SizedIconButton.dart';
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

  bool editingOrderElement = false;
  OrderElement? orderElementInEdition;
  int indexOrOrderElementToEdit = -1;

  Promotion? promotionInEdition;
  String? articleRefOfPromotionInEdition;

  TextEditingController _tableNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tableNumberController.text =
        widget.order.tableNumber < 1 ? "" : widget.order.tableNumber.toString();

    //Blocks anything other than a valid entry
    _tableNumberController.addListener(() {
      String content = _tableNumberController.text;
      if (RegExp(r"^[1-9][0-9]?$").hasMatch(content)) {
        widget.order.tableNumber = int.parse(content);
      } else if (content.length > 1) {
        String previousValue = content.substring(0, content.length - 1);
        _tableNumberController.value = _tableNumberController.value.copyWith(
            text: previousValue,
            selection: TextSelection(
                baseOffset: previousValue.length,
                extentOffset: previousValue.length));
      } else {
        _tableNumberController.text = "";
      }
    });
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int nbComments = widget.order.numberOfComments;
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
            SizedBox(
              height: 27.0 * widget.order.orderElements.length + 31.0 * nbComments,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.order.orderElements.length,
                  itemBuilder: (context, index){
                    if (widget.order.orderElements[index].articleType == ArticleType.menu) {
                      return GestureDetector(
                          onLongPress: () {
                            orderElementInEdition = widget.order.orderElements[index];
                            indexOrOrderElementToEdit = index;
                            print(index);
                            setState(() {
                              editingOrderElement = true;
                              addingOrderElement = false;
                            });
                          },
                          child: OrderLineElement(orderElement: widget.order.orderElements[index]));
                    } else {
                      return SizedBox.shrink();
                    }
              }),
            ),
            Builder(builder: (context) {
              if (addingOrderElement && !editingOrderElement) {
                return AddOrEditOrderElementForm(
                  onCancel: () {
                    orderElementInEdition = null;
                    setState(() {
                      editingOrderElement = false;
                      addingOrderElement = false;
                    });
                  },
                  onConfirmAdd: (OrderElement orderElement) {
                    orderElementInEdition = null;
                    setState(() {
                      editingOrderElement = false;
                      addingOrderElement = false;
                      //TODO: déduire le prix via une db ou un fichier
                      widget.order.orderElements.add(orderElement);
                    });
                  },
                );
              } else if (editingOrderElement && !addingOrderElement) {
                return AddOrEditOrderElementForm(
                  onCancel: () {
                    print("orderElementInEdition à l'annulation : $orderElementInEdition");
                    setState(() {
                      editingOrderElement = false;
                      addingOrderElement = false;
                    });
                  },
                  onConfirmAdd: (OrderElement orderElement) {
                    widget.order.orderElements[indexOrOrderElementToEdit] = orderElement;
                    print("orderElementInEdition à la validation: $orderElement");
                    setState(() {
                      orderElementInEdition = orderElement;
                      editingOrderElement = false;
                      addingOrderElement = false;
                      //TODO: c'est ici que ça bosse
                      //TODO: déduire le prix via une db ou un fichier
                    });
                  },
                  orderElementToEdit: orderElementInEdition,
                );
              } else {
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
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () {
                          if (promotionInEdition != null) return;
                          setState(() {
                            promotionInEdition = orderElement.promotion;
                            articleRefOfPromotionInEdition =
                                orderElement.articleReference;
                          });
                        },
                        child: PromotionLine(
                          onDismissed: () {
                            orderElement.deletePromotion();
                          },
                          promotion: orderElement.promotion!,
                          linkedArticle: orderElement.article,
                          key: Key(orderElement.promotion!.name +
                              orderElement.articleReference),
                        ),
                      );
                    } else if (orderElement.hasPromotion &&
                        orderElement.promotion == null) {
                      print(
                          "Error, an order element's promotion has incorrectly set values : hasPromotion is true, yet promotion is null");
                      return SizedBox();
                    } else if (!orderElement.hasPromotion &&
                        orderElement.promotion != null) {
                      print(
                          "Warning, an order element's promotion has incorrectly set values : hasPromotion is false, yet promotion has data");
                      return PromotionLine(
                        onDismissed: () {
                          orderElement.deletePromotion();
                        },
                        promotion: orderElement.promotion!,
                        linkedArticle: orderElement.article,
                        key: Key(orderElement.promotion!.name +
                            orderElement.articleReference),
                      );
                    } else {
                      return SizedBox();
                    }
                  }).toList(),
                ),
              ],
            ),
            Builder(builder: (context) {
              if (addingPromotion) {
                return AddOrEditPromotionForm(onCancel: () {
                  setState(() {
                    promotionInEdition = null;
                    addingPromotion = false;
                  });
                }, onConfirmAdd: (promotion, articleRef) {
                  setState(() {
                    promotionInEdition = null;
                    addingPromotion = false;
                  });
                  OrderElement? orderElement =
                      widget.order.getOrderElementByRef(articleRef);
                  orderElement?.promotion = promotion;
                  orderElement?.hasPromotion = true;
                });
              } else if (promotionInEdition != null) {
                return AddOrEditPromotionForm(
                  onCancel: () {
                    setState(() {
                      addingPromotion = false;
                      promotionInEdition = null;
                    });
                  },
                  onConfirmAdd: (promotion, articleRef) {
                    setState(() {
                      addingPromotion = false;
                      promotionInEdition = null;
                    });
                    OrderElement? orderElement =
                        widget.order.getOrderElementByRef(articleRef);
                    orderElement?.promotion = promotion;
                  },
                  promotionToEdit: promotionInEdition,
                  articleRefOfPromotionToEdit: articleRefOfPromotionInEdition,
                );
              } else {
                return SizedIconButton(
                  //The button is only show if we are not adding or editing anything
                  onTap: () {
                    setState(() {
                      addingPromotion = true;
                    });
                  },
                  color: customColors.secondary!,
                  spreadColor: customColors.secondaryLight!,
                  iconData: Icons.add,
                );
              }
            }),
            GreatTotal(
                onTap: () {
                  if (!widget.isEditMode) return;
                  setState(() {
                    if (widget.order.paymentMethod ==
                        PaymentMethod.bancontact) {
                      widget.order.paymentMethod = PaymentMethod.cash;
                    } else {
                      widget.order.paymentMethod = PaymentMethod.bancontact;
                    }
                  });
                },
                paymentMethod: widget.order.paymentMethod,
                totalPrice: widget.order.totalPrice),
          ],
        ),
      ),
    );
  }
}

class AddOrEditOrderElementForm extends StatefulWidget {
  const AddOrEditOrderElementForm(
      {super.key,
      required this.onCancel,
      required this.onConfirmAdd,
      this.orderElementToEdit});

  final Function onCancel;
  final Function(OrderElement) onConfirmAdd;

  final OrderElement? orderElementToEdit;

  @override
  State<AddOrEditOrderElementForm> createState() =>
      _AddOrEditOrderElementFormState();
}

class _AddOrEditOrderElementFormState extends State<AddOrEditOrderElementForm> {
  OrderElement orderElement =
      OrderElement(article: Article.empty(type: ArticleType.menu), quantity: 1);

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _alphaController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _subAlphaController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _extraPriceController = TextEditingController();

  final _addOrderElementFormKey = GlobalKey<FormState>();
  final _addCommentOrExtraFormKey = GlobalKey<FormState>();

  bool addingComment = false;
  bool addingExtra = false;

  @override
  void initState() {
    super.initState();
    if (widget.orderElementToEdit == null) _quantityController.text = "1";

    if (widget.orderElementToEdit != null) {
      orderElement = widget.orderElementToEdit!.copy();

      _quantityController.text = orderElement.quantity.toString();
      _alphaController.text = orderElement.articleAlpha;
      _numberController.text = orderElement.articleNumber.toString();
      _subAlphaController.text = orderElement.articleSubAlpha;
      _commentController.text = orderElement.comment;
      _extraPriceController.text = orderElement.extraPrice > 0 ?"${orderElement.extraPrice}€" : "";
    }

    _quantityController.addListener(() {
      if (int.tryParse(_quantityController.text) != null) {
        orderElement.quantity = int.parse(_quantityController.text);
      }
    });
    _alphaController.addListener(() {
      String content = _alphaController.text.toUpperCase();
      orderElement.article.alpha = content;
      _alphaController.value = _alphaController.value.copyWith(text: content);
    });
    _numberController.addListener(() {
      if (int.tryParse(_numberController.text) != null) {
        orderElement.article.number = int.parse(_numberController.text);
      } else {
        orderElement.article.number = -1;
      }
    });
    _subAlphaController.addListener(() {
      orderElement.article.subAlpha = _subAlphaController.text.toLowerCase();
    });
    _extraPriceController.addListener(() {
      if (!RegExp(r"^[0-9]+€?").hasMatch(_extraPriceController.text)) {
        _extraPriceController.text = "";
      } else if (_extraPriceController.text.isNotEmpty &&
          !_extraPriceController.text.contains("€")) {
        String content = _extraPriceController.text;
        _extraPriceController.text = "$content€";
      }
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _alphaController.dispose();
    _numberController.dispose();
    _subAlphaController.dispose();
    _commentController.dispose();
    _extraPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool editingOrder = widget.orderElementToEdit != null;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Form(
      key: _addOrderElementFormKey,
      child: Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: customColors.primaryDark!, width: 3)),
            child: Builder(builder: (context) {
              if (!addingComment && !addingExtra) {
                return Column(
                  children: [
                    Text(
                        "${editingOrder ? "Modification" : "Ajout"} d'une commande${editingOrder ? "(${orderElement.articleReference})" : ""}"),
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
                        validator: (value) {
                          if (value != null &&
                              RegExp(r"^[1-9][0-9]*$").hasMatch(value)) {
                            return null;
                          } else {
                            return "Erreur Qté";
                          }
                        },
                        textEditingController: _quantityController,
                        orderEntryType: OrderEntry.quantity,
                        maxLength: 2,
                        placeholder: "Qté",
                        marginLeft: 10,
                        marginRight: 3,
                      ),
                      EntryBox(
                        validator: (value) {
                          if (value != null &&
                              RegExp(r"[A-Za-z]").hasMatch(value)) {
                            return null;
                          } else {
                            return "Erreur alpha";
                          }
                        },
                        textEditingController: _alphaController,
                        orderEntryType: OrderEntry.alpha,
                        maxLength: 1,
                        placeholder: "A-Z",
                        marginLeft: 3,
                        marginRight: 3,
                      ),
                      EntryBox(
                        validator: (value) {
                          if (value != null &&
                              RegExp(r"^[0-9]{1,3}$").hasMatch(value)) {
                            return null;
                          } else {
                            return "Erreur numéro";
                          }
                        },
                        textEditingController: _numberController,
                        orderEntryType: OrderEntry.number,
                        maxLength: 3,
                        placeholder: "N°",
                        marginLeft: 3,
                        marginRight: 3,
                      ),
                      EntryBox(
                        validator: (value) {
                          if (value != null &&
                              RegExp(r"^[a-zA-Z]?$").hasMatch(value)) {
                            return null;
                          } else {
                            return "Erreur s-alpha";
                          }
                        },
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
                            onTap: () => {
                              widget.onCancel()}),
                        FlexIconButton(
                          color: customColors.primary!,
                          spreadColor: customColors.primaryDark!,
                          iconData: Icons.comment,
                          onTap: () {
                            setState(() {
                              addingComment = true;
                              addingExtra = false;
                            });
                          },
                        ),
                        FlexIconButton(
                          color: customColors.primary!,
                          spreadColor: customColors.primaryDark!,
                          iconData: Icons.assignment_add,
                          onTap: () {
                            setState(() {
                              addingExtra = true;
                              addingComment = false;
                            });
                          },
                        ),
                        FlexIconButton(
                          color: customColors.primary!,
                          spreadColor: customColors.primaryDark!,
                          iconData: editingOrder? Icons.check : Icons.add,
                          marginRight: 0,
                          onTap: () {
                            print("Dans le bouton: $orderElement");
                            if (_addOrderElementFormKey.currentState!
                                .validate()) {
                              widget.onConfirmAdd(orderElement);
                            }
                          },
                        ),
                      ],
                    )
                  ],
                );
              } else if (addingComment || addingExtra) {
                return Form(
                  key: _addCommentOrExtraFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          "${addingExtra ? "Supplément" : "Commentaire"} pour l'élément: ${orderElement.articleReference}"),
                      Row(
                        children: [
                          EntryBox(
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                return null;
                              } else {
                                return "Veuillez donner la description du ${addingExtra ? "Supplément" : "Commentaire"}";
                              }
                            },
                            orderEntryType: OrderEntry.text,
                            flex: 4,
                            maxLength: 150,
                            lines: addingExtra ? 1 : 2,
                            textAlign: TextAlign.left,
                            placeholder:
                                "${addingExtra ? "Supplément" : "Commentaire"}...",
                            textEditingController: _commentController,
                            marginLeft: 10,
                          ),
                          Builder(builder: (context) {
                            if (addingExtra) {
                              return EntryBox(
                                validator: (value) {
                                  if (value != null &&
                                      RegExp(r"^[1-9][0-9]?€$")
                                          .hasMatch(value)) {
                                    return null;
                                  } else {
                                    return "Erreur sup.";
                                  }
                                },
                                orderEntryType: OrderEntry.price,
                                flex: 1,
                                maxLength: 2,
                                placeholder: "Prix",
                                textEditingController: _extraPriceController,
                                marginLeft: 6,
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          })
                        ],
                      ),
                      Row(
                        children: [
                          FlexIconButton(
                            onTap: () {
                              setState(() {
                                addingComment = false;
                                addingExtra = false;
                              });
                            },
                            color: customColors.primary!,
                            spreadColor: customColors.primaryDark!,
                            iconData: Icons.backspace,
                            marginLeft: 10,
                          ),
                          Expanded(flex: 2, child: SizedBox.shrink()),
                          FlexIconButton(
                            onTap: () {
                              if (_addCommentOrExtraFormKey.currentState!
                                  .validate()) {
                                orderElement.comment = _commentController.text;
                                if (addingExtra) {
                                  String extraPriceStr = _extraPriceController
                                      .text
                                      .replaceFirst("€", "", 1);
                                  orderElement.commentIsExtra = true;
                                  orderElement.extraPrice =
                                      double.parse(extraPriceStr);
                                }else{
                                  _extraPriceController.text = "";
                                  orderElement.commentIsExtra = false;
                                  orderElement.extraPrice = 0;
                                }
                                setState(() {
                                  addingComment = false;
                                  addingExtra = false;
                                });
                              }
                            },
                            color: customColors.primary!,
                            spreadColor: customColors.primaryDark!,
                            iconData: Icons.check,
                          ),
                        ],
                      )
                    ],
                  ),
                );
              } else if (addingExtra && addingComment) {
                throw Exception(
                    "State addingExtra and addingComment are mutually exclusive, logic within widget AddOrderElementForm is wrong");
              } else {
                throw Exception("Unexpected error");
              }
            }),
          ),
        ),
      ),
    );
  }
}

class AddOrEditPromotionForm extends StatefulWidget {
  const AddOrEditPromotionForm(
      {super.key,
      required this.onCancel,
      required this.onConfirmAdd,
      this.promotionToEdit,
      this.articleRefOfPromotionToEdit})
      : assert(
            (promotionToEdit != null && articleRefOfPromotionToEdit != null) ||
                (promotionToEdit == null &&
                    articleRefOfPromotionToEdit == null),
            "When editing, both the promotion and the articleReference must be not null");

  final Function onCancel;
  final Function(Promotion, String) onConfirmAdd;

  final Promotion? promotionToEdit;
  final String? articleRefOfPromotionToEdit;

  @override
  State<AddOrEditPromotionForm> createState() => _AddOrEditPromotionFormState();
}

class _AddOrEditPromotionFormState extends State<AddOrEditPromotionForm> {
  final _discountValueController = TextEditingController();
  final _promotionNameController = TextEditingController();
  final _linkedArticleController = TextEditingController();

  final _addPromotionFormKey = GlobalKey<FormState>();

  Promotion promotion = Promotion(discountValue: 0, name: "");

  @override
  void initState() {
    super.initState();

    if (widget.promotionToEdit != null) {
      promotion.name = widget.promotionToEdit!.name;
      promotion.discountValue = widget.promotionToEdit!.discountValue;

      _promotionNameController.text = widget.promotionToEdit!.name;
      _discountValueController.text =
          "-${widget.promotionToEdit!.discountValue}€";
      _linkedArticleController.text = widget.articleRefOfPromotionToEdit!;
    }

    _promotionNameController.addListener(() {
      promotion.name = _promotionNameController.text;
    });
    //forces -XX€ format and always sets cursor position at before last
    _discountValueController.addListener(() {
      if (RegExp(r"^-?[1-9][0-9]*€?$")
              .hasMatch(_discountValueController.text) &&
          _discountValueController.text.isNotEmpty) {
        String content = _discountValueController.text;
        if (!content.contains("-")) {
          content = "-$content";
        }
        if (!content.contains("€")) {
          content = "$content€";
        }
        _discountValueController.value = _discountValueController.value
            .copyWith(
                text: content,
                selection: TextSelection(
                    baseOffset: content.length - 1,
                    extentOffset: content.length - 1));
        double discountValue =
            double.parse(content.substring(1, content.length - 1));
        promotion.discountValue = discountValue;
      } else {
        _discountValueController.text = "";
      }
    });
    //Forces case specific format like A followed by any number with the optionnal subalpha (ex: A326b or Z78)
    _linkedArticleController.addListener(() {
      if (RegExp(r"^[a-zA-Z][0-9]+[a-zA-Z]?$")
              .hasMatch(_linkedArticleController.text) &&
          _linkedArticleController.text.length > 1) {
        String content = _linkedArticleController.text;
        if (content.length > 2) {
          String contentUpper =
              content.substring(0, content.length - 1).toUpperCase();
          String contentLower = content
              .substring(content.length - 1, content.length)
              .toLowerCase();
          content = contentUpper + contentLower;
        }
        _linkedArticleController.value = _linkedArticleController.value
            .copyWith(
                text: content,
                selection: TextSelection(
                    baseOffset: content.length, extentOffset: content.length));
      }
    });
  }

  @override
  void dispose() {
    _discountValueController.dispose();
    _promotionNameController.dispose();
    _linkedArticleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool editingPromotion = widget.promotionToEdit != null;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Form(
      key: _addPromotionFormKey,
      child: Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
          child: Container(
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: customColors.primaryDark!, width: 3)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${editingPromotion ? "Modification" : "Ajout"} d'une promotion",
                ),
                EntryBox(
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      return null;
                    } else {
                      return "Veuillez entrer le nom de la promotion";
                    }
                  },
                  orderEntryType: OrderEntry.text,
                  maxLength: 80,
                  placeholder: "Nom de la promotion...",
                  textEditingController: _promotionNameController,
                  marginLeft: 10,
                ),
                Row(
                  children: [
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            RegExp(r"^[a-zA-Z][0-9]+[a-zA-Z]?$")
                                .hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur référence";
                        }
                      },
                      flex: 4,
                      orderEntryType: OrderEntry.text,
                      maxLength: 5,
                      placeholder: "Article associé (ex:A2b)",
                      textEditingController: _linkedArticleController,
                      marginLeft: 10,
                    ),
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            RegExp(r"^-[1-9][0-9]?€$").hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur réduction";
                        }
                      },
                      flex: 1,
                      orderEntryType: OrderEntry.price,
                      maxLength: 4,
                      placeholder: "-?€",
                      textEditingController: _discountValueController,
                      marginLeft: 10,
                    )
                  ],
                ),
                Row(
                  children: [
                    FlexIconButton(
                      onTap: () => widget.onCancel(),
                      color: customColors.secondary!,
                      spreadColor: customColors.secondaryLight!,
                      iconData: Icons.backspace,
                      marginLeft: 10,
                    ),
                    Expanded(flex: 2, child: SizedBox.shrink()),
                    FlexIconButton(
                      onTap: () {
                        if (_addPromotionFormKey.currentState!.validate()) {
                          widget.onConfirmAdd(
                              promotion, _linkedArticleController.text);
                        }
                      },
                      color: customColors.secondary!,
                      spreadColor: customColors.secondaryLight!,
                      iconData:
                          editingPromotion ? Icons.check_outlined : Icons.add,
                    ),
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
