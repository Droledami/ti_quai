import 'package:flutter/material.dart';

import '../../models/Article.dart';

@immutable
abstract class ArticleEvent{}

class LoadArticle extends ArticleEvent{}
