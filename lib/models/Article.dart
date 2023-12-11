import 'package:ti_quai/enums/ArticleType.dart';

class Article {
  static const String keyAlpha = "alpha";
  static const String keyNumber = "number";
  static const String keySubAlpha = "subAlpha";
  static const String keyName = "name";
  static const String keyType = "type";
  static const String keyPrice = "price";

  Article._({
    required this.alpha,
    required this.number,
    required this.subAlpha,
    required this.name,
    required this.type,
    required this.price,
  });

  Article.empty({required this.type}) : alpha = "", number = -1, subAlpha="", name="", price=-1;

  Article.menu({
    required this.alpha,
    required this.number,
    required this.subAlpha,
    required this.name,
    required this.price,
  }) : type = ArticleType.menu;

  Article.other({required this.name, required this.price})
      : alpha = "",
        number = 0,
        subAlpha = "",
        type = ArticleType.other;

  String alpha;
  int number;
  String subAlpha;
  String name;
  ArticleType type;
  double price;

  Article copy(Article article){
    return Article._(
      alpha: article.alpha,
      number: article.number,
      subAlpha: article.subAlpha,
      name: article.name,
      type: article.type,
      price: article.price,
    );
  }
}
