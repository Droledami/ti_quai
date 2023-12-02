import 'package:ti_quai/models/Article.dart';

class OrderElement {
  static const String keyId = "id";
  static const String keyArticle = "article";
  static const String keyQuantity = "quantity";
  static const String keyComment = "comment";
  static const String keyCommentIsExtra = "commentIsExtra";
  static const String keyExtraPrice = "extraPrice";

  OrderElement({
    required this.id,
    required this.article,
    required this.quantity,
    this.comment = "",
    this.commentIsExtra = false,
    this.extraPrice = 0,
  });

  OrderElement.comment(
      {required this.id,
      required this.article,
      required this.quantity,
      required this.comment})
      : commentIsExtra = false,
        extraPrice = 0;

  OrderElement.withExtra(
      {required this.id,
      required this.article,
      required this.quantity,
      required this.comment,
      required this.extraPrice})
      : commentIsExtra = true;

  String id;
  Article article;
  int quantity;
  String comment;
  bool commentIsExtra;
  double extraPrice;

  double get price {
    return article.price * quantity - extraPrice;
  }
}
