import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/firestore/firestore_service.dart';

import 'article_events.dart';
import 'article_states.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState>{
  final FirestoreService _firestoreService;

  ArticleBloc(this._firestoreService) : super(ArticleInitial()){
    on<LoadArticle>((event, emit) async {
      try{
        emit(ArticleLoading());
        final articles = await _firestoreService.getArticles().first;
        emit(ArticleLoaded(articles));
      }catch(e){
        emit(ArticleError("Failed to load articles: $e"));
      }
    });

    on<AddArticle>((event, emit) async {
      try{
        emit(ArticleLoading());
        await _firestoreService.addArticle(event.article);
        emit(ArticleOperationSuccess("Successfully added article: ${event.article.id}"));
      }catch(e){
        emit(ArticleError("Failed to add article  ${event.article.id}: $e"));
      }
    });

    on<UpdateArticle>((event, emit)async {
      try{
        emit(ArticleLoading());
        await _firestoreService.updateArticle(event.article);
        emit(ArticleOperationSuccess("Successfully updated article: ${event.article.id}"));
      }catch(e){
        emit(ArticleError('Failed to update article ${event.article.id}: $e'));
      }
    });

    on<DeleteArticle>((event, emit) async {
      try{
        emit(ArticleLoading());
        await _firestoreService.deleteArticle(event.article.id);
        emit(ArticleOperationSuccess("Successfully deleted article: ${event.article.id}"));
      }catch(e){
        emit(ArticleError("Failed to delete article ${event.article.id}: $e"));
      }
    });
  }
}