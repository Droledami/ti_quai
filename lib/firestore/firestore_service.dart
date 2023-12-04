import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ti_quai/enums/ArticleType.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';
import 'package:ti_quai/models/Article.dart';
import 'package:ti_quai/models/CustomerOrder.dart';
import 'package:ti_quai/models/OrderElement.dart';

import '../models/Promotion.dart';

class FirestoreService {
  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection("Order");

//CRUD FOR ORDERS
  Stream<List<CustomerOrder>> getOrders() {
    return _orderCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        List<OrderElement> orderElementList =
            List<OrderElement>.empty(growable: true);
        for (var oe in data[CustomerOrder.keyOrderElements]) {
          OrderElement orderElementToAdd = createOrderElementFromSnapshot(oe);
          orderElementList.add(orderElementToAdd);
        }
        return CustomerOrder(
            id: doc.id,
            date: (data[CustomerOrder.keyDate] as Timestamp).toDate(),
            orderElements: orderElementList,
            paymentMethod: data[CustomerOrder.keyPaymentMethod] ==
                    PaymentMethod.bancontact.name
                ? PaymentMethod.bancontact
                : PaymentMethod.cash);
      }).toList();
    });
  }

  OrderElement createOrderElementFromSnapshot(oe) {
    OrderElement orderElementToAdd;

    Article article = createArticleFromSnapshot(oe);

    orderElementToAdd = OrderElement(
        article: article, quantity: oe[OrderElement.keyQuantity]);

    createPromotionFromSnapshot(oe, orderElementToAdd);

    if (oe[OrderElement.keyComment] != "") {
      orderElementToAdd.comment == oe[OrderElement.keyComment];
      if (oe[OrderElement.keyCommentIsExtra]) {
        orderElementToAdd.commentIsExtra = true;
        orderElementToAdd.extraPrice = oe[OrderElement.keyExtraPrice];
      }
    }
    return orderElementToAdd;
  }

  void createPromotionFromSnapshot(oe, OrderElement orderElementToAdd) {
    Promotion promotion;
    if (oe[OrderElement.keyHasPromotion]) {
      promotion = Promotion(
          discountValue: oe[OrderElement.keyPromotion]
              [Promotion.keyDiscountValue],
          nameLong: oe[OrderElement.keyPromotion][Promotion.keyNameLong],
          nameShort: oe[OrderElement.keyPromotion]
              [Promotion.keyNameShort]);
      orderElementToAdd.hasPromotion = true;
      orderElementToAdd.promotion = promotion;
    }
  }

  Article createArticleFromSnapshot(oe) {
    Article fetchedArticle = Article(
        alpha: oe[OrderElement.keyArticle][Article.keyAlpha],
        number: oe[OrderElement.keyArticle][Article.keyNumber],
        subAlpha: oe[OrderElement.keyArticle][Article.keySubAlpha],
        name: oe[OrderElement.keyArticle][Article.keyName],
        type: oe[OrderElement.keyArticle][Article.keyType] ==
                ArticleType.menu.name
            ? ArticleType.menu
            : ArticleType.other,
        price: oe[OrderElement.keyArticle][Article.keyPrice]);
    return fetchedArticle;
  }

  Future<void> addOrder(CustomerOrder order) {
    return _orderCollection.add({
      CustomerOrder.keyDate: order.date,
      CustomerOrder.keyOrderElements: order.orderElements,
      CustomerOrder.keyPaymentMethod: order.paymentMethod
    });
  }

  Future<void> updateOrder(CustomerOrder order) {
    return _orderCollection.doc(order.id).update({
      CustomerOrder.keyDate: order.date,
      CustomerOrder.keyOrderElements: order.orderElements,
      CustomerOrder.keyPaymentMethod: order.paymentMethod
    });
  }

  Future<void> deleteOrder(String orderId) {
    return _orderCollection.doc(orderId).delete();
  }
}
