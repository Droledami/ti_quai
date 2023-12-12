import 'package:flutter/material.dart';

import '../../models/Article.dart';

@immutable
abstract class ArticleState {}

class ArticleInitial extends ArticleState{}

class ArticleLoading extends ArticleState{}

class ArticleLoaded extends ArticleState{
  final List<Article> articles;

  ArticleLoaded(this.articles);

  Article getArticleById(String articleId){
    for(Article article in articles){
      if(articleId == article.id){
        return article;
      }
    }
    throw Exception("Couldn't find article with ID: $articleId");
  }

  Article getArticleByReference({required String alpha, required int number, String subAlpha=""}){
    for(Article article in articles){
      if(article.alpha == alpha && article.number == number && article.subAlpha == subAlpha){
        return article;
      }
    }
    throw Exception("Couln't find any article with reference $alpha$number$subAlpha");
  }
}

class ArticleOperationSuccess extends ArticleState{
  final String message;

  ArticleOperationSuccess(this.message);
}

class ArticleError extends ArticleState{
  final String errorMessage;

  ArticleError(this.errorMessage);
}