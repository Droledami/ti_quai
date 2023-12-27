import 'package:flutter/material.dart';

import '../../custom_materials/theme.dart';
import '../../enums/ArticleType.dart';
import '../../enums/EntryType.dart';
import '../../models/Article.dart';
import '../../models/OrderElement.dart';
import '../../processes/functions.dart';
import '../EntryBox.dart';
import '../buttons/FlexIconButton.dart';

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
      _extraPriceController.text =
      orderElement.extraPrice > 0 ? "${orderElement.extraPrice}€" : "";
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
      forcePriceFormat(_extraPriceController,
          firstDigitCanBeZero: true, mustBeNegative: false);
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
                        orderEntryType: QuaiEntry.quantity,
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
                        orderEntryType: QuaiEntry.alpha,
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
                        orderEntryType: QuaiEntry.number,
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
                        orderEntryType: QuaiEntry.subAlpha,
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
                            onTap: () => {widget.onCancel()}),
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
                          iconData: editingOrder ? Icons.check : Icons.add,
                          marginRight: 0,
                          onTap: () {
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
                            orderEntryType: QuaiEntry.text,
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
                                      RegExp(r"^[0-9]+[,.]?[0-9]{0,2}€$")
                                          .hasMatch(value)) {
                                    return null;
                                  } else {
                                    return "Erreur sup.";
                                  }
                                },
                                orderEntryType: QuaiEntry.price,
                                flex: 1,
                                maxLength: 5,
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
                                  double extraPrice = forcePriceFormat(
                                      _extraPriceController,
                                      firstDigitCanBeZero: true,
                                      mustBeNegative: false)!;
                                  orderElement.commentIsExtra = true;
                                  orderElement.extraPrice = extraPrice;
                                } else {
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