//The full order containing every order Element and holding the final price accounting all quantities and promotions

import 'package:ti_quai/enums/PaymentMethod.dart';

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

  //TODO: Un peu chiant ça, je le calcule déjà au dessus, allô comment faire ?
  double get totalDiscount{
    double totalDiscount = 0;
    for (OrderElement orderElement in orderElements) {
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        totalDiscount += orderElement.promotion!.discountValue;
      }
    }
    return totalDiscount;
  }

  bool get hasAnyPromotions{
    for (OrderElement orderElement in orderElements) {
      if (orderElement.hasPromotion && orderElement.promotion != null) {
        return true;
      }
    }
    return false;
  }

}
