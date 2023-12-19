import 'dart:async';

import 'package:ti_quai/processes/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ti_quai/enums/ArticleType.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';
import 'package:ti_quai/models/Article.dart';
import 'package:ti_quai/models/CustomerOrder.dart';
import 'package:ti_quai/models/OrderElement.dart';

import '../models/Promotion.dart';

class FirestoreService {
  //Order operations
  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection("Order");

  Stream<List<CustomerOrder>> getOrders() {
    //Only get orders of the last 24 hours
    return _orderCollection
        .orderBy("date")
        .where("date",
            isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(Duration(hours: 16))))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return firebaseDataToCustomerOrder(data, doc.id);
      }).toList();
    });
  }

  CustomerOrder firebaseDataToCustomerOrder(Map<String, dynamic> data, String docId) {

    List<OrderElement> orderElementList =
        List<OrderElement>.empty(growable: true);
    for (var oe in data[CustomerOrder.keyOrderElements]) {
      OrderElement orderElementToAdd = createOrderElementFromSnapshot(oe);
      orderElementList.add(orderElementToAdd);
    }

    List<Promotion> unLinkedPromotionsList =
        List<Promotion>.empty(growable: true);
    for (var unlinkedProm in data[CustomerOrder.keyUnlinkedPromotions]) {
      Promotion unlinedPromotionToAdd = Promotion(
          discountValue: (unlinkedProm[Promotion.keyDiscountValue] as num).toDouble(),
          name: unlinkedProm[Promotion.keyName]);
      unLinkedPromotionsList.add(unlinedPromotionToAdd);
    }

    return CustomerOrder(
        id: docId,
        tableNumber: (data[CustomerOrder.keyTableNumber] as num).toInt(),
        date: (data[CustomerOrder.keyDate] as Timestamp).toDate(),
        orderElements: orderElementList,
        paymentMethod: data[CustomerOrder.keyPaymentMethod] ==
                PaymentMethod.bancontact.name
            ? PaymentMethod.bancontact
            : PaymentMethod.cash,
        unlinkedPromotions: unLinkedPromotionsList);
  }

  StreamSubscription<QuerySnapshot<Object?>> listenToOrdersStream(){
    return _orderCollection
        .orderBy("date")
        .where("date",
        isGreaterThan: Timestamp.fromDate(
            DateTime.now().subtract(Duration(hours: 16))))
        .snapshots().listen((event){});
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
        orderElementToAdd.extraPrice =
            (oe[OrderElement.keyExtraPrice] as num).toDouble();
      }
    }
    return orderElementToAdd;
  }

  void addPromotionFromSnapshotToOrderElement(
      oe, OrderElement orderElementToAdd) {
    Promotion promotion;
    if (oe[OrderElement.keyHasPromotion]) {
      promotion = Promotion(
        discountValue:
            (oe[OrderElement.keyPromotion][Promotion.keyDiscountValue] as num)
                .toDouble(),
        name: oe[OrderElement.keyPromotion][Promotion.keyName],
      );
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
            alpha: oe[OrderElement.keyArticle][Article.keyAlpha] as String,
            number: oe[OrderElement.keyArticle][Article.keyNumber],
            subAlpha:
                oe[OrderElement.keyArticle][Article.keySubAlpha] as String,
            name: oe[OrderElement.keyArticle][Article.keyName] as String,
            price: (oe[OrderElement.keyArticle][Article.keyPrice] as num)
                .toDouble());
      case ArticleType.other:
        fetchedArticle = Article.other(
            name: oe[OrderElement.keyArticle][Article.keyName] as String,
            price: (oe[OrderElement.keyArticle][Article.keyPrice] as num)
                .toDouble());
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

    List<Map<String, dynamic>> promMapList = List<Map<String, dynamic>>.empty(growable: true);

    for(Promotion prom in order.unlinkedPromotions){
      Map<String, dynamic> promMap = convertPromotionToMap(prom);

      promMapList.add(promMap);
    }

    return _orderCollection.add({
      CustomerOrder.keyTableNumber: order.tableNumber,
      CustomerOrder.keyDate: order.date,
      CustomerOrder.keyOrderElements: oeMapList,
      CustomerOrder.keyPaymentMethod: order.paymentMethod.name,
      CustomerOrder.keyUnlinkedPromotions: promMapList
    });
  }

  Future<void> updateOrder(CustomerOrder order) {
    List<Map<String, dynamic>> oeMapList =
        List<Map<String, dynamic>>.empty(growable: true);

    for (OrderElement oe in order.orderElements) {
      Map<String, dynamic> oeMap = convertOrderElementToMaps(oe);
      oeMapList.add(oeMap);
    }

    List<Map<String, dynamic>> promMapList = List<Map<String, dynamic>>.empty(growable: true);

    for(Promotion prom in order.unlinkedPromotions){
      Map<String, dynamic> promMap = convertPromotionToMap(prom);

      promMapList.add(promMap);
    }

    return _orderCollection.doc(order.id).update({
      CustomerOrder.keyTableNumber: order.tableNumber,
      CustomerOrder.keyDate: order.date,
      CustomerOrder.keyOrderElements: oeMapList,
      CustomerOrder.keyPaymentMethod: order.paymentMethod.name,
      CustomerOrder.keyUnlinkedPromotions: promMapList
    });
  }

  Future<void> deleteOrder(String orderId) {
    return _orderCollection.doc(orderId).delete();
  }
}
