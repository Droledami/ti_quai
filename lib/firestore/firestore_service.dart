import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ti_quai/models/Article.dart';
import 'package:ti_quai/models/Promotion.dart';

class FirestoreService {
  final CollectionReference _articleCollection =
  FirebaseFirestore.instance.collection("Article");
  final CollectionReference _promotionCollection =
  FirebaseFirestore.instance.collection("Promotion");
  final CollectionReference _orderElementCollection =
  FirebaseFirestore.instance.collection("OrderElement");
  final CollectionReference _promotioinElementCollection =
  FirebaseFirestore.instance.collection("PromotionElement");
  final CollectionReference _orderCollection =
  FirebaseFirestore.instance.collection("Order");


  //TODO: test all actions
  //CRUD FOR ARTICLES
  Stream<List<Article>> getArticles() {
    return _articleCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Article(
            id: doc.id,
            alpha: data[Article.keyAlpha],
            number: data[Article.keyNumber],
            subAlpha: data[Article.keySubAlpha],
            name: data[Article.keyName],
            type: data[Article.keyType],
            price: data[Article.keyPrice]);
      }).toList();
    });
  }

  Future<void> addArticle(Article article) {
    return _articleCollection.add({
      Article.keyAlpha: article.alpha,
      Article.keyNumber: article.number,
      Article.keySubAlpha: article.subAlpha,
      Article.keyName: article.name,
      Article.keyType: article.type.name,
      Article.keyPrice: article.price
    });
  }

  Future<void> updateArticle(Article article) {
    return _articleCollection.doc(article.id).update({
      Article.keyAlpha: article.alpha,
      Article.keyNumber: article.number,
      Article.keySubAlpha: article.subAlpha,
      Article.keyName: article.name,
      Article.keyType: article.type.name,
      Article.keyPrice: article.price
    });
  }

  Future<void> deleteArticle(String articleId) {
    return _articleCollection.doc(articleId).delete();
  }

//CRUD FOR PROMOTIONS
  Stream<List<Promotion>> getPromotions() {
    return _promotionCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Promotion(id: doc.id,
            discountValue: data[Promotion.keyDiscountValue],
            nameLong: data[Promotion.keyNameLong],
            nameShort: data[Promotion.keyNameShort]);
      }).toList();
    });
  }
  
  Future<void> addPromotion(Promotion promotion){
    return _promotionCollection.add({
      Promotion.keyDiscountValue: promotion.discountValue,
      Promotion.keyNameLong: promotion.nameLong,
      Promotion.keyNameShort: promotion.nameShort
    });
  }

  Future<void> updatePromotion(Promotion promotion){
    return _promotionCollection.doc(promotion.id).update({
      Promotion.keyDiscountValue: promotion.discountValue,
      Promotion.keyNameLong: promotion.nameLong,
      Promotion.keyNameShort: promotion.nameShort
    });
  }

  Future<void> deletePromotion(String promotionId){
    return _promotionCollection.doc(promotionId).delete();
  }

  //TODO: coucou viens ici
//CRUD FOR ORDER ELEMENTS

//CRUD FOR PROMOTION ELEMENTS

//CRUD FOR ORDERS

}
