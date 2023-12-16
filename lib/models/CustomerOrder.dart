//The full order containing every order Element and holding the final price accounting all quantities and promotions

import 'package:flutter/material.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';

import '../enums/ArticleType.dart';
import '../main.dart';
import 'OrderElement.dart';
import 'Promotion.dart';

class CustomerOrder {
  //Static keys for firebase
  static const String keyId = "id";
  static const String keyTableNumber = "tableNumber";
  static const String keyDate = "date";
  static const String keyOrderElements = "orderElements";
  static const String keyPaymentMethod = "paymentMethod";
  static const String keyUnlinkedPromotions = "unlinkedPromotions";

  CustomerOrder(
      {required this.id,
      required this.tableNumber,
      required this.date,
      required this.orderElements,
      required this.paymentMethod,
      required this.unlinkedPromotions});

  CustomerOrder.createNew()
      : id = EditOrAddScreenArguments.keyDefinedLater,
        tableNumber = -1,
        date = DateTime.now(),
        orderElements = List<OrderElement>.empty(growable: true),
        paymentMethod = PaymentMethod.bancontact,
        unlinkedPromotions = List<Promotion>.empty(growable: true);

  String id;
  int tableNumber;
  DateTime date;
  List<OrderElement> orderElements;
  PaymentMethod paymentMethod;
  List<Promotion> unlinkedPromotions;

  //getters
  double get totalPrice {
    double totalPrice = 0;
    for (OrderElement orderElement in orderElements) {
      totalPrice += orderElement.price;
    }
    totalPrice = totalPrice - totalDiscount; //As requested by the client, paying in cash earns a 10% discount
    return paymentMethod == PaymentMethod.cash? totalPrice * 0.9 : totalPrice;
  }

  double get totalDiscount {
    double totalDiscount = 0;
    for (OrderElement orderElement in orderElements) {
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        totalDiscount += orderElement.promotion!.discountValue;
      }
    }
    for(Promotion prom in unlinkedPromotions){
      totalDiscount += prom.discountValue;
    }
    return totalDiscount;
  }

  bool get hasAnyPromotions {
    for (OrderElement orderElement in orderElements) {
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        return true;
      }
    }
    return unlinkedPromotions.isNotEmpty;
  }

  int get numberOfComments{
    int nbComments=0;
    for (OrderElement orderElement in orderElements){
      if(orderElement.comment != ""){
        nbComments++;
      }
    }
    return nbComments;
  }

  int get numberOfMenuArticles{
    int nb=0;
    for (OrderElement orderElement in orderElements){
      if(orderElement.article.type == ArticleType.menu){
        nb++;
      }
    }
    return nb;
  }

  int get numberOfOtherArticles{
    int nb=0;
    for (OrderElement orderElement in orderElements){
      if(orderElement.article.type == ArticleType.other){
        nb++;
      }
    }
    return nb;
  }

  OrderElement? getOrderElementByRef(String ref){
    for(OrderElement orderElement in orderElements){
      if(orderElement.articleReference == ref){
        return orderElement;
      }
    }
  }

  OrderElement? getOrderElementByUuid(UniqueKey uuid){
    for(OrderElement orderElement in orderElements){
      if(orderElement.uuid == uuid){
        return orderElement;
      }
    }
  }
}
