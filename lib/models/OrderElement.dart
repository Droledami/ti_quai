import 'package:ti_quai/models/Article.dart';

import 'package:ti_quai/models/Promotion.dart';

import '../enums/ArticleType.dart';

class OrderElement {
  static const String keyArticle = "article";
  static const String keyQuantity = "quantity";
  static const String keyComment = "comment";
  static const String keyCommentIsExtra = "commentIsExtra";
  static const String keyExtraPrice = "extraPrice";
  static const String keyHasPromotion = "hasPromotion";
  static const String keyPromotion = "promotion";

  OrderElement(
      {required this.article,
      required this.quantity,
      this.comment = "",
      this.commentIsExtra = false,
      this.extraPrice = 0,
      this.hasPromotion = false,
      this.promotion});

  OrderElement.comment(
      {required this.article, required this.quantity, required this.comment})
      : commentIsExtra = false,
        extraPrice = 0,
        hasPromotion = false;

  OrderElement.withExtra(
      {required this.article,
      required this.quantity,
      required this.comment,
      required this.extraPrice})
      : commentIsExtra = true,
        hasPromotion = false;

  OrderElement.withPromotion(
      {required this.article, required this.quantity, required this.promotion})
      : comment = "",
        commentIsExtra = false,
        extraPrice = 0,
        hasPromotion = true;

  Article article;
  int quantity;
  String comment;
  bool commentIsExtra;
  double extraPrice;
  bool hasPromotion;
  Promotion? promotion;

  String get fullDescription{
    return "$quantity $articleReference $comment";
  }

  double get price {
    return article.price * quantity + extraPrice;
  }

  String get articleReference {
    return "${article.alpha.isEmpty ? "?" : article.alpha}${article.number.isNegative ? "?" : article.number.toString()}${article.subAlpha}";
  }

  String get articleName {
    return article.name;
  }

  String get articleAlpha {
    return article.alpha;
  }

  String get articleSubAlpha {
    return article.subAlpha;
  }

  int get articleNumber {
    return article.number;
  }

  ArticleType get articleType {
    return article.type;
  }

  double get articlePrice {
    return article.price;
  }

  String? get promotionName {
    if (promotion != null) {
      return promotion!.name;
    }
    return null;
  }

  double? get promotionDiscountValue {
    if (promotion != null) {
      return promotion!.discountValue;
    }
    return null;
  }

  void deletePromotion(){
    promotion = null;
    hasPromotion = false;
  }
}
