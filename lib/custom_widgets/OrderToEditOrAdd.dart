import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/custom_widgets/EntryBox.dart';
import 'package:ti_quai/enums/EntryType.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';
import 'package:ti_quai/processes/functions.dart';
import 'package:ti_quai/models/Article.dart';

import '../blocs/article/article_bloc.dart';
import '../blocs/article/article_events.dart';
import '../blocs/article/article_states.dart';
import '../enums/ArticleType.dart';
import '../models/CustomerOrder.dart';
import '../models/OrderElement.dart';
import '../models/Promotion.dart';
import '../theme.dart';
import 'DismissibleBackground.dart';
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
  bool addingOrderElement = false;
  bool addingPromotion = false;
  bool addingOther = false;

  bool editingOther = false;
  OrderElement? otherToEdit;
  UniqueKey? uuidOfOtherToEdit;

  bool editingOrderElement = false;
  OrderElement? orderElementInEdition;
  int indexOfOrderElementToEdit = -1;

  Promotion? promotionInEdition;
  String? articleRefOfPromotionInEdition;

  int indexOfUnlinkedPromotionToEdit = -1;

  TextEditingController _tableNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //Load articles in memory once.
    if (BlocProvider.of<ArticlesBloc>(context).state is! ArticleLoaded) {
      BlocProvider.of<ArticlesBloc>(context).add(LoadArticle());
    }
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
    final _articleBloc = BlocProvider.of<ArticlesBloc>(context);
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
        child:
            BlocBuilder<ArticlesBloc, ArticleState>(builder: (context, state) {
          if (state is ArticleLoading) {
            return CircularProgressIndicator();
          } else if (state is ArticleError) {
            return Text(state.errorMessage);
          } else if (state is ArticleLoaded) {
            return Column(
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
                  height: 27.0 * widget.order.numberOfMenuArticles +
                      31.0 * nbComments,
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: widget.order.orderElements.length,
                      itemBuilder: (context, index) {
                        if (widget.order.orderElements[index].articleType ==
                            ArticleType.menu) {
                          return GestureDetector(
                              onDoubleTap: () {
                                orderElementInEdition =
                                    widget.order.orderElements[index];
                                indexOfOrderElementToEdit = index;
                                setState(() {
                                  editingOrderElement = true;
                                  addingOrderElement = false;
                                });
                              },
                              child: Dismissible(
                                  key: UniqueKey(),
                                  background: DismissibleBackground(),
                                  onDismissed: (dismissDirection) {
                                    widget.order.orderElements = widget
                                        .order.orderElements
                                        .where((orderElement) =>
                                            orderElement.uuid !=
                                            widget.order.orderElements[index]
                                                .uuid)
                                        .toList();
                                    setState(() {});
                                  },
                                  child: OrderLineElement(
                                      orderElement:
                                          widget.order.orderElements[index])));
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
                          setArticlePriceAndName(state, orderElement);
                          widget.order.orderElements.add(orderElement);
                        });
                      },
                    );
                  } else if (editingOrderElement && !addingOrderElement) {
                    return AddOrEditOrderElementForm(
                      onCancel: () {
                        setState(() {
                          editingOrderElement = false;
                          addingOrderElement = false;
                        });
                      },
                      onConfirmAdd: (OrderElement orderElement) {
                        widget.order.orderElements[indexOfOrderElementToEdit] =
                            orderElement;
                        setState(() {
                          orderElementInEdition = orderElement;
                          editingOrderElement = false;
                          addingOrderElement = false;
                          setArticlePriceAndName(state, orderElement);
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextDivider(text: "Autres", color: customColors.tertiary!),
                    Column(
                        children:
                            widget.order.orderElements.map((otherOrderElement) {
                      if (otherOrderElement.articleType == ArticleType.other) {
                        return GestureDetector(
                          onDoubleTap: () {
                            otherToEdit = otherOrderElement;
                            uuidOfOtherToEdit = otherOrderElement.uuid;
                            setState(() {
                              addingOther = false;
                              editingOther = true;
                            });
                          },
                          child: Dismissible(
                            key: UniqueKey(),
                            background: DismissibleBackground(),
                            onDismissed: (dismissDirection) {
                              widget.order.orderElements = widget
                                  .order.orderElements
                                  .where((element) =>
                                      element.uuid != otherOrderElement.uuid)
                                  .toList();
                              setState(() {});
                            },
                            child: OthersOrderLineElement(
                              productName: otherOrderElement.articleName,
                              productPrice: otherOrderElement.articlePrice,
                              quantity: otherOrderElement.quantity,
                            ),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }).toList()),
                    Builder(builder: (context) {
                      if (addingOther && !editingOther) {
                        return AddOrEditOtherForm(
                          onConfirmAdd: (otherOrderElement) {
                            setState(() {
                              widget.order.orderElements.add(otherOrderElement);
                              addingOther = false;
                              editingOther = false;
                            });
                          },
                          onCancel: () {
                            setState(() {
                              addingOther = false;
                              editingOther = false;
                            });
                          },
                        );
                      } else if (!addingOther && editingOther) {
                        return AddOrEditOtherForm(
                          onConfirmAdd: (otherOrderElement) {
                            setState(() {
                              OrderElement? oe = widget.order
                                  .getOrderElementByUuid(uuidOfOtherToEdit!);
                              oe?.article = otherOrderElement.article;
                              oe?.quantity = otherOrderElement.quantity;
                              addingOther = false;
                              editingOther = false;
                            });
                          },
                          onCancel: () {
                            setState(() {
                              addingOther = false;
                              editingOther = false;
                            });
                          },
                          otherToEdit: otherToEdit,
                        );
                      } else {
                        return SizedIconButton(
                            color: customColors.primary!,
                            spreadColor: customColors.primaryDark!,
                            iconData: Icons.add,
                            onTap: () {
                              setState(() {
                                addingOther = true;
                              });
                            });
                      }
                    }),
                  ],
                ),
                Column(
                  children: [
                    Builder(builder: (context) {
                      if (widget.isEditMode) {
                        return Column(
                          children: [
                            TextDivider(
                                text: "Promotions",
                                color: customColors.tertiary!),
                            Builder(builder: (context) {
                              if (hasPromotion) {
                                return Row(
                                  children: [
                                    LittleCard(
                                        littleCardColor:
                                            customColors.secondary!,
                                        leftMargin: 10.0,
                                        height: 30,
                                        flex: 6,
                                        text: "Promotion"),
                                    LittleCard(
                                        littleCardColor:
                                            customColors.secondary!,
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
                      children:
                          listLinkedPromotions(widget.order.orderElements),
                    ),
                    SizedBox(
                      height: 27.0 * widget.order.unlinkedPromotions.length,
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: widget.order.unlinkedPromotions.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onDoubleTap: () {
                                if (promotionInEdition != null) return;
                                setState(() {
                                  indexOfUnlinkedPromotionToEdit = index;
                                  promotionInEdition = widget.order.unlinkedPromotions[index];
                                  articleRefOfPromotionInEdition = "";
                                });
                              },
                              child: PromotionLine(
                                onDismissed: () {
                                  widget.order.unlinkedPromotions.removeAt(index);
                                  setState(() {
                                    indexOfUnlinkedPromotionToEdit= -1;
                                    promotionInEdition = null;
                                    articleRefOfPromotionInEdition = null;
                                  });
                                },
                                promotion: widget.order.unlinkedPromotions[index],
                                key: UniqueKey(),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
                Builder(builder: (context) {
                  if (addingPromotion) {
                    return AddOrEditPromotionForm(onCancel: () {
                      setState(() {
                        indexOfUnlinkedPromotionToEdit= -1;
                        promotionInEdition = null;
                        addingPromotion = false;
                      });
                    }, onConfirmAdd: (promotion, articleRef) {
                      OrderElement? orderElement =
                          widget.order.getOrderElementByRef(articleRef);
                      orderElement?.promotion = promotion;
                      orderElement?.hasPromotion = true;
                      if (orderElement == null && articleRef.isEmpty) {
                        widget.order.unlinkedPromotions.add(promotion);
                      }
                      setState(() {
                        promotionInEdition = null;
                        addingPromotion = false;
                      });
                    });
                  } else if (promotionInEdition != null) {
                    return AddOrEditPromotionForm(
                      onCancel: () {
                        setState(() {
                          indexOfUnlinkedPromotionToEdit=-1;
                          addingPromotion = false;
                          promotionInEdition = null;
                        });
                      },
                      onConfirmAdd: (promotion, articleRef) {
                        OrderElement? orderElement =
                            widget.order.getOrderElementByRef(articleRef);
                        orderElement?.promotion = promotion;
                        if(orderElement == null){
                          widget.order.unlinkedPromotions[indexOfUnlinkedPromotionToEdit] = promotion;
                        }
                        setState(() {
                          addingPromotion = false;
                          promotionInEdition = null;
                        });
                      },
                      promotionToEdit: promotionInEdition,
                      articleRefOfPromotionToEdit:
                          articleRefOfPromotionInEdition,
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
            );
          } else {
            return Container();
          }
        }),
      ),
    );
  }

  List<Widget> listLinkedPromotions(List<OrderElement> orderElements) {
    return orderElements.map((orderElement) {
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: () {
            if (promotionInEdition != null) return;
            setState(() {
              promotionInEdition = orderElement.promotion;
              articleRefOfPromotionInEdition = orderElement.articleReference;
            });
          },
          child: PromotionLine(
            onDismissed: () {
              orderElement.deletePromotion();
              setState(() {
                promotionInEdition = null;
                articleRefOfPromotionInEdition = null;
              });
            },
            promotion: orderElement.promotion!,
            linkedArticle: orderElement.article,
            key: UniqueKey(),
          ),
        );
      } else if (orderElement.hasPromotion && orderElement.promotion == null) {
        print(
            "Error, an order element's promotion has incorrectly set values : hasPromotion is true, yet promotion is null");
        return SizedBox();
      } else if (!orderElement.hasPromotion && orderElement.promotion != null) {
        print(
            "Warning, an order element's promotion has incorrectly set values : hasPromotion is false, yet promotion has data");
        return PromotionLine(
          onDismissed: () {
            orderElement.deletePromotion();
            setState(() {
              promotionInEdition = null;
              articleRefOfPromotionInEdition = null;
            });
          },
          promotion: orderElement.promotion!,
          linkedArticle: orderElement.article,
          key: UniqueKey(),
        );
      } else {
        return SizedBox();
      }
    }).toList();
  }

  //TODO: delete
  Widget listUnlinkedPromotions(List<Promotion> promotions) {
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: promotions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () {
              if (promotionInEdition != null) return;
              setState(() {
                promotionInEdition = promotions[index];
                articleRefOfPromotionInEdition = "";
              });
            },
            child: PromotionLine(
              onDismissed: () {
                promotions.removeAt(index);
                setState(() {
                  promotionInEdition = null;
                  articleRefOfPromotionInEdition = null;
                });
              },
              promotion: promotions[index],
              key: UniqueKey(),
            ),
          );
        });
  }

  void setArticlePriceAndName(ArticleLoaded state, OrderElement orderElement) {
    Article artData = state.getArticleByReference(
        alpha: orderElement.articleAlpha,
        number: orderElement.articleNumber,
        subAlpha: orderElement.articleSubAlpha);
    orderElement.article.price = artData.price;
    orderElement.article.name = artData.name;
  }
}

class AddOrEditOtherForm extends StatefulWidget {
  const AddOrEditOtherForm(
      {super.key,
      required this.onCancel,
      required this.onConfirmAdd,
      this.otherToEdit});

  final Function onCancel;
  final Function(OrderElement) onConfirmAdd;

  final OrderElement? otherToEdit;

  @override
  State<AddOrEditOtherForm> createState() => _AddOrEditOtherFormState();
}

class _AddOrEditOtherFormState extends State<AddOrEditOtherForm> {
  OrderElement otherOrderElement =
      OrderElement(article: Article.other(name: "", price: -1), quantity: 1);

  final TextEditingController _otherProductNameController =
      TextEditingController();
  final TextEditingController _quantityOtherProductController =
      TextEditingController();
  final TextEditingController _priceOtherProductController =
      TextEditingController();

  final _addOtherFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.otherToEdit != null) {
      otherOrderElement = widget.otherToEdit!.copy();

      _otherProductNameController.text = otherOrderElement.articleName;
      _priceOtherProductController.text = "${otherOrderElement.articlePrice}€";
      _quantityOtherProductController.text =
          otherOrderElement.quantity.toString();
    }

    _otherProductNameController.addListener(() {
      otherOrderElement.article.name = _otherProductNameController.text;
    });

    _quantityOtherProductController.addListener(() {
      if (int.tryParse(_quantityOtherProductController.text) != null) {
        otherOrderElement.quantity =
            int.parse(_quantityOtherProductController.text);
      }
    });

    _priceOtherProductController.addListener(() {
      double? price = forcePriceFormat(_priceOtherProductController,
          firstDigitCanBeZero: false, mustBeNegative: false);
      if (price != null) otherOrderElement.article.price = price;
    });

    super.initState();
  }

  @override
  void dispose() {
    _quantityOtherProductController.dispose();
    _otherProductNameController.dispose();
    _priceOtherProductController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool editingOther = widget.otherToEdit != null;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Form(
      key: _addOtherFormKey,
      child: Flexible(
        fit: FlexFit.loose,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
            padding: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: customColors.primaryDark!, width: 3)),
            child: Column(
              children: [
                Text(
                    "${editingOther ? "Modification" : "Ajout"} d'un produit ${editingOther ? "(nom du produit à modifier)" : ""}"),
                Row(
                  children: [
                    EntryBox(
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return null;
                          } else {
                            return "Veuillez donner le nom du produit";
                          }
                        },
                        orderEntryType: QuaiEntry.text,
                        maxLength: 150,
                        placeholder: "Nom du produit...",
                        textEditingController: _otherProductNameController,
                        marginLeft: 10),
                  ],
                ),
                Row(
                  children: [
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            RegExp(r"^[1-9][0-9]*$").hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur Quantité";
                        }
                      },
                      orderEntryType: QuaiEntry.quantity,
                      maxLength: 2,
                      placeholder: "Quantité...",
                      textEditingController: _quantityOtherProductController,
                      marginLeft: 10,
                    ),
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            RegExp(r"^[1-9][0-9]*[,.]?[0-9]{0,2}€?$")
                                .hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur Prix";
                        }
                      },
                      orderEntryType: QuaiEntry.price,
                      maxLength: 10,
                      placeholder: "Prix du produit...",
                      textEditingController: _priceOtherProductController,
                      marginLeft: 5,
                    ),
                  ],
                ),
                Row(
                  children: [
                    FlexIconButton(
                      onTap: () => widget.onCancel(),
                      color: customColors.primary!,
                      spreadColor: customColors.primaryDark!,
                      iconData: Icons.backspace,
                      marginLeft: 10,
                    ),
                    Expanded(flex: 2, child: SizedBox.shrink()),
                    FlexIconButton(
                      onTap: () {
                        if (_addOtherFormKey.currentState!.validate()) {
                          //Apeller la validation puis si correct appeler widget.onConfirmAdd
                          widget.onConfirmAdd(otherOrderElement);
                        }
                      },
                      color: customColors.primary!,
                      spreadColor: customColors.primaryDark!,
                      iconData: editingOther ? Icons.check_outlined : Icons.add,
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

    _discountValueController.addListener(() {
      double? discountValue = forcePriceFormat(_discountValueController,
          firstDigitCanBeZero: true, mustBeNegative: true);
      if (discountValue != null) promotion.discountValue = discountValue;
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
                  orderEntryType: QuaiEntry.text,
                  maxLength: 80,
                  placeholder: "Nom de la promotion...",
                  textEditingController: _promotionNameController,
                  marginLeft: 10,
                ),
                Row(
                  children: [
                    EntryBox(
                      // validator: (value) {
                      //   if (value != null &&
                      //       RegExp(r"^[a-zA-Z][0-9]+[a-zA-Z]?$")
                      //           .hasMatch(value)) {
                      //     return null;
                      //   } else {
                      //     return "Erreur référence";
                      //   }
                      // },
                      flex: 4,
                      orderEntryType: QuaiEntry.text,
                      maxLength: 5,
                      placeholder: "Article associé (ex:A2b)",
                      textEditingController: _linkedArticleController,
                      marginLeft: 10,
                    ),
                    EntryBox(
                      validator: (value) {
                        if (value != null &&
                            RegExp(r"^-[0-9]+[,.]?[0-9]{0,2}?€$")
                                .hasMatch(value)) {
                          return null;
                        } else {
                          return "Erreur réduction";
                        }
                      },
                      flex: 2,
                      orderEntryType: QuaiEntry.price,
                      maxLength: 7,
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
