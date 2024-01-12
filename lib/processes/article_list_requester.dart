import 'package:http/http.dart';
import 'package:http/retry.dart';
import 'dart:convert';
import '../models/Article.dart';

String addressLAN = "192.168.1.128:65139";
String addressWiFi = "192.168.1.129:65139";
String localhost = "localhost:65139";

class ArticleListRequester {
  final client = RetryClient(Client());
  var url = Uri.http(addressWiFi, '/articles');

  Future<List<Article>> getArticleData() async {
    List<Article> articleList = List<Article>.empty(growable: true);
    try {
      var response = await client.get(url);
      var json = jsonDecode(response.body);
      json.forEach((articleData) {
        Article articleToAdd = Article.menu(
            alpha: articleData[Article.keyAlpha],
            number: int.parse(articleData[Article.keyNumber]),
            subAlpha: articleData[Article.keySubAlpha].toLowerCase(),
            name: articleData[Article.keyName],
            price: double.parse(articleData[Article.keyPrice]));
        articleList.add(articleToAdd);
      });
      return articleList;
    } finally {
      client.close();
    }
  }
}
