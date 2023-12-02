//The full order containing every order Element and holding the final price accounting all quantities and promotions

import 'package:ti_quai/enums/PaymentMethod.dart';

import 'OrderElement.dart';
import 'PromotionElement.dart';

class Order {
  static const String keyId = "id";
  static const String keyDate = "date";
  static const String keyOrderElements = "orderElements";
  static const String keyPromotionElements = "promotionElements";
  static const String keyPaymentMethod = "paymentMethod";

  Order(
      {required this.id,
      required this.date,
      required this.orderElements,
      required this.promotionElements,
      required this.paymentMethod});

  String id;
  DateTime date;
  List<OrderElement> orderElements;
  List<PromotionElement> promotionElements;
  PaymentMethod paymentMethod;

  //getters
  double get totalPrice {
    double totalPrice = 0;
    double totalDiscount = 0;
    for (OrderElement orderElement in orderElements) {
      totalPrice += orderElement.price;
    }
    for (PromotionElement promotionElement in promotionElements) {
      totalDiscount += promotionElement.promotion.discountValue;
    }
    return totalPrice - totalDiscount;
  }
}
