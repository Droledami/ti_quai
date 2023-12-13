import 'package:ti_quai/enums/ArticleType.dart';

class Article {
  static const String keyId = "id";
  static const String keyAlpha = "alpha";
  static const String keyNumber = "number";
  static const String keySubAlpha = "subAlpha";
  static const String keyName = "name";
  static const String keyType = "type";
  static const String keyPrice = "price";

  Article._({
    this.id = "firebaseDefined",
    required this.alpha,
    required this.number,
    required this.subAlpha,
    required this.name,
    required this.type,
    required this.price,
  });

  Article.empty({this.id = "toBeDefined", required this.type}) : alpha = "", number = -1, subAlpha="", name="", price=-1;

  Article.menu({
    this.id = "firebaseDefined",
    required this.alpha,
    required this.number,
    required this.subAlpha,
    required this.name,
    required this.price,
  }) : type = ArticleType.menu;

  Article.other({this.id = "firebaseDefined", required this.name, required this.price})
      : alpha = "",
        number = 0,
        subAlpha = "",
        type = ArticleType.other;

  String id; //For firebase
  String alpha;
  int number;
  String subAlpha;
  String name;
  ArticleType type;
  double price;

  String get reference{
    return "$alpha$number$subAlpha";
  }

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
