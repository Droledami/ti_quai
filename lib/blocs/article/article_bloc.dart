import 'package:flutter_bloc/flutter_bloc.dart';

import '../../processes/article_list_requester.dart';
import 'article_events.dart';
import 'article_states.dart';

class ArticlesBloc extends Bloc<ArticleEvent, ArticleState> {
  ArticleListRequester articleListRequester = ArticleListRequester();

  ArticlesBloc() : super(ArticleInitial()) {
    on<LoadArticle>((event, emit) async {
      try {
        emit(ArticleLoading());
        final articles = await articleListRequester.getArticleData();
        emit(ArticleLoaded(articles));
      } catch (e) {
        print(e);
        emit(ArticleError(
            "Erreur de chargement des données des articles: $e \n Essayez de recharger la page, sinon relancez le service de chargement des articles sur le Raspberry Pi, puis relancez l'application"));
        emit(ArticleInitial());
      }
    });
  }
}
