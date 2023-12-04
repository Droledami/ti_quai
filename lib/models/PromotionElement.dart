//Used to link a Promotion to an Article within an Order object. This way, removing an Article linked to that promotion will
//allow the deletion of the Promotion associated to it and vice versa.

import 'package:ti_quai/main.dart';
import 'package:ti_quai/models/Promotion.dart';

class PromotionElement {
  static const String keyId = "id";
  static const String keyOrderElement = "orderElement";
  static const String keyPromotion = "promotion";

  PromotionElement(
      {required this.id, required this.orderElement, required this.promotion});

  String id;
  OrderLineElement orderElement;
  Promotion promotion;
}
