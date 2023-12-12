import 'package:flutter/material.dart';

import '../../models/Article.dart';

@immutable
abstract class ArticleEvent{}

class LoadArticle extends ArticleEvent{}

class AddArticle extends ArticleEvent{
  final Article article;

  AddArticle(this.article);
}

class UpdateArticle extends ArticleEvent{
  final Article article;

  UpdateArticle(this.article);
}

class DeleteArticle extends ArticleEvent{
  final Article article;

  DeleteArticle(this.article);
}
