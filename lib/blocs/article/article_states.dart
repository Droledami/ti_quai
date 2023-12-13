import 'package:flutter/material.dart';
import 'package:ti_quai/models/SearchContent.dart';

import '../../models/Article.dart';

@immutable
abstract class ArticleState {}

class ArticleInitial extends ArticleState {}

class ArticleLoading extends ArticleState {}

class ArticleLoaded extends ArticleState {
  final List<Article> articles;

  ArticleLoaded(this.articles);

  Article getArticleById(String articleId) {
    for (Article article in articles) {
      if (articleId == article.id) {
        return article;
      }
    }
    throw Exception("Couldn't find article with ID: $articleId");
  }

  Article getArticleByReference(
      {required String alpha, required int number, String subAlpha = ""}) {
    for (Article article in articles) {
      if (article.alpha == alpha &&
          article.number == number &&
          article.subAlpha == subAlpha) {
        return article;
      }
    }
    throw Exception(
        "Couln't find any article with reference $alpha$number$subAlpha");
  }

  List<Article> getArticlesBySearch({required SearchContent searchContent}) {
    int? searchNumber = int.tryParse(searchContent.number);

    return articles.where((article) {
      bool alphaTest = searchContent.alpha.isEmpty? true : article.alpha.toLowerCase() == searchContent.alpha.toLowerCase();
      bool numberTest = searchNumber != null ? article.number == searchNumber : true;
      bool subAlphaTest = searchContent.alpha.isEmpty? true : article.subAlpha == searchContent.subAlpha;
      bool nameTest = article.name.toLowerCase().contains(searchContent.name.toLowerCase());

      return alphaTest && numberTest && subAlphaTest && nameTest;

    }).toList(growable: false);
  }
}

class ArticleOperationSuccess extends ArticleState {
  final String message;

  ArticleOperationSuccess(this.message);
}

class ArticleError extends ArticleState {
  final String errorMessage;

  ArticleError(this.errorMessage);
}
