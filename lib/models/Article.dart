import 'package:ti_quai/enums/ArticleType.dart';

class Article {
  static const String keyId = "id";
  static const String keyAlpha = "alpha";
  static const String keyNumber = "number";
  static const String keySubAlpha = "subAlpha";
  static const String keyName = "name";
  static const String keyType = "type";
  static const String keyPrice = "price";

  Article({
    required this.id,
    required this.alpha,
    required this.number,
    required this.subAlpha,
    required this.name,
    required this.type,
    required this.price,
  });

  String id;
  String alpha;
  int number;
  String subAlpha;
  String name;
  ArticleType type;
  double price;
}
