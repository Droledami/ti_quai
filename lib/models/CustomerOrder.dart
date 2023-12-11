//The full order containing every order Element and holding the final price accounting all quantities and promotions

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';

import '../enums/ArticleType.dart';
import '../main.dart';
import 'OrderElement.dart';

class CustomerOrder {
  static const String keyId = "id";
  static const String keyTableNumber = "tableNumber";
  static const String keyDate = "date";
  static const String keyOrderElements = "orderElements";
  static const String keyPaymentMethod = "paymentMethod";

  CustomerOrder(
      {required this.id,
      required this.tableNumber,
      required this.date,
      required this.orderElements,
      required this.paymentMethod});

  CustomerOrder.createNew()
      : id = EditOrAddScreenArguments.keyDefinedLater,
        tableNumber = -1,
        date = DateTime.now(),
        orderElements = List<OrderElement>.empty(growable: true),
        paymentMethod = PaymentMethod.bancontact;

  String id;
  int tableNumber;
  DateTime date;
  List<OrderElement> orderElements;
  PaymentMethod paymentMethod;

  //getters
  double get totalPrice {
    double totalDiscount = 0;
    double totalPrice = 0;
    for (OrderElement orderElement in orderElements) {
      totalPrice += orderElement.price;
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        totalDiscount += orderElement.promotion!.discountValue;
      }
    }
    return totalPrice - totalDiscount;
  }

  double get totalDiscount {
    double totalDiscount = 0;
    for (OrderElement orderElement in orderElements) {
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        totalDiscount += orderElement.promotion!.discountValue;
      }
    }
    return totalDiscount;
  }

  bool get hasAnyPromotions {
    for (OrderElement orderElement in orderElements) {
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        return true;
      }
    }
    return false;
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
    print(nb);
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
}
