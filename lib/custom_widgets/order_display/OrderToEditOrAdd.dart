import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';
import 'package:ti_quai/models/Article.dart';

import '../../blocs/article/article_bloc.dart';
import '../../blocs/article/article_events.dart';
import '../../blocs/article/article_states.dart';
import '../../enums/ArticleType.dart';
import '../../models/CustomerOrder.dart';
import '../../models/OrderElement.dart';
import '../../models/Promotion.dart';
import '../../custom_materials/theme.dart';
import '../forms/AddOrEditOrderElementForm.dart';
import '../forms/AddOrEditOtherForm.dart';
import '../forms/AddOrEditPromotionForm.dart';
import '../DismissibleBackground.dart';
import '../LittleCard.dart';
import 'GreatTotal.dart';
import 'OrderHeader.dart';
import 'OrderLineElement.dart';
import '../buttons/SizedIconButton.dart';
import 'OthersOrderLineElement.dart';
import 'PromotionLine.dart';
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

  void setArticlePriceAndName(ArticleLoaded state, OrderElement orderElement) {
    Article artData = state.getArticleByReference(
        alpha: orderElement.articleAlpha,
        number: orderElement.articleNumber,
        subAlpha: orderElement.articleSubAlpha);
    orderElement.article.price = artData.price;
    orderElement.article.name = artData.name;
  }
}
