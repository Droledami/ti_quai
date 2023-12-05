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
            tableNumber: data[CustomerOrder.keyTableNumber],
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

    orderElementToAdd =
        OrderElement(article: article, quantity: oe[OrderElement.keyQuantity]);

    addPromotionFromSnapshotToOrderElement(oe, orderElementToAdd);

    if (oe[OrderElement.keyComment] != "") {
      orderElementToAdd.comment = oe[OrderElement.keyComment];
      if (oe[OrderElement.keyCommentIsExtra]) {
        orderElementToAdd.commentIsExtra = true;
        orderElementToAdd.extraPrice = oe[OrderElement.keyExtraPrice];
      }
    }
    return orderElementToAdd;
  }

  void addPromotionFromSnapshotToOrderElement(oe, OrderElement orderElementToAdd) {
    Promotion promotion;
    if (oe[OrderElement.keyHasPromotion]) {
      promotion = Promotion(
          discountValue: oe[OrderElement.keyPromotion]
              [Promotion.keyDiscountValue],
          nameLong: oe[OrderElement.keyPromotion][Promotion.keyNameLong],
          nameShort: oe[OrderElement.keyPromotion][Promotion.keyNameShort]);
      orderElementToAdd.hasPromotion = true;
      orderElementToAdd.promotion = promotion;
    }
  }

  Article createArticleFromSnapshot(oe) {
    ArticleType articleType =
        oe[OrderElement.keyArticle][Article.keyType] == ArticleType.menu.name
            ? ArticleType.menu
            : ArticleType.other;

    Article fetchedArticle;
    switch (articleType) {
      case ArticleType.menu:
        fetchedArticle = Article.menu(
            alpha: oe[OrderElement.keyArticle][Article.keyAlpha],
            number: oe[OrderElement.keyArticle][Article.keyNumber],
            subAlpha: oe[OrderElement.keyArticle][Article.keySubAlpha],
            name: oe[OrderElement.keyArticle][Article.keyName],
            price: oe[OrderElement.keyArticle][Article.keyPrice]);
      case ArticleType.other:
        fetchedArticle = Article.other(
            name: oe[OrderElement.keyArticle][Article.keyName],
            price: oe[OrderElement.keyArticle][Article.keyPrice]);
    }

    return fetchedArticle;
  }

  Future<void> addOrder(CustomerOrder order) {
    List<Map<String, dynamic>> oeMapList =
        List<Map<String, dynamic>>.empty(growable: true);

    for (OrderElement oe in order.orderElements) {
      Map<String, dynamic> oeMap = convertOrderElementToMaps(oe);
      oeMapList.add(oeMap);
    }

    return _orderCollection.add({
      CustomerOrder.keyTableNumber: order.tableNumber,
      CustomerOrder.keyDate: order.date,
      CustomerOrder.keyOrderElements: oeMapList,
      CustomerOrder.keyPaymentMethod: order.paymentMethod.name
    });
  }

  Map<String, dynamic> convertOrderElementToMaps(OrderElement oe) {
    Map<String, dynamic> oeMap = <String, dynamic>{};
    Map<String, dynamic> artMap = <String, dynamic>{};
    Map<String, dynamic> promMap = <String, dynamic>{};

    oeMap[OrderElement.keyQuantity] = oe.quantity;
    oeMap[OrderElement.keyComment] = oe.comment;
    oeMap[OrderElement.keyCommentIsExtra] = oe.commentIsExtra;
    oeMap[OrderElement.keyExtraPrice] = oe.extraPrice;
    oeMap[OrderElement.keyHasPromotion] = oe.hasPromotion;

    artMap[Article.keyAlpha] = oe.articleAlpha;
    artMap[Article.keyNumber] = oe.articleNumber;
    artMap[Article.keySubAlpha] = oe.articleSubAlpha;
    artMap[Article.keyName] = oe.articleName;
    artMap[Article.keyType] = oe.articleType.name;
    artMap[Article.keyPrice] = oe.articlePrice;

    oeMap[OrderElement.keyArticle] = artMap;

    if (oe.hasPromotion) {
      promMap[Promotion.keyDiscountValue] = oe.promotionDiscountValue;
      promMap[Promotion.keyNameLong] = oe.promotionNameLong;
      promMap[Promotion.keyNameShort] = oe.promotionNameShort;
      oeMap[OrderElement.keyPromotion] = promMap;
    }
    return oeMap;
  }

  Future<void> updateOrder(CustomerOrder order) {
    List<Map<String, dynamic>> oeMapList =
        List<Map<String, dynamic>>.empty(growable: true);

    for (OrderElement oe in order.orderElements) {
      Map<String, dynamic> oeMap = convertOrderElementToMaps(oe);
      oeMapList.add(oeMap);
    }

    return _orderCollection.doc(order.id).update({
      CustomerOrder.keyTableNumber: order.tableNumber,
      CustomerOrder.keyDate: order.date,
      CustomerOrder.keyOrderElements: oeMapList,
      CustomerOrder.keyPaymentMethod: order.paymentMethod.name
    });
  }

  Future<void> deleteOrder(String orderId) {
    return _orderCollection.doc(orderId).delete();
  }

}
