import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/article/article_bloc.dart';
import '../blocs/article/article_events.dart';
import '../blocs/article/article_states.dart';
import '../custom_materials/BeachGradientDecoration.dart';
import '../custom_materials/theme.dart';
import '../custom_widgets/ArticleListTile.dart';
import '../custom_widgets/QuaiDrawer.dart';
import '../custom_widgets/SearchArticleWindow.dart';
import '../custom_widgets/TitleHeader.dart';
import '../custom_widgets/buttons/MenuButton.dart';
import '../models/Article.dart';
import '../models/SearchContent.dart';

class ArticleSearchPage extends StatefulWidget {
  const ArticleSearchPage({super.key});

  @override
  State<ArticleSearchPage> createState() => _ArticleSearchPageState();
}

class _ArticleSearchPageState extends State<ArticleSearchPage> {
  SearchContent searchContent = SearchContent.empty();

  late List<Article> articlesSearch;

  @override
  void initState() {
    //Load articles in memory once.
    if (BlocProvider.of<ArticlesBloc>(context).state is! ArticleLoaded) {
      BlocProvider.of<ArticlesBloc>(context).add(LoadArticle());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CustomColors customColors = Theme.of(context).extension<CustomColors>()!;
    return Container(
      decoration: BeachGradientDecoration(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: MenuButton(customColors: customColors),
          centerTitle: true,
          title: TitleHeader(
            customColors: customColors,
            title: "Recherche d'articles",
          ),
          backgroundColor: Colors.white.withOpacity(0.0),
        ),
        drawer: QuaiDrawer(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: kIsWeb ? 65 : 100,
              ),
              SearchArticleWindow(
                searchContent: searchContent,
                onSearchChanged: (newSearchContent) {
                  setState(() {
                    searchContent = newSearchContent;
                  });
                },
              ),
              SizedBox(
                height: 5,
              ),
              Flexible(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                        color: customColors.cardQuarterTransparency!,
                        borderRadius: BorderRadius.circular(15)),
                    child: BlocBuilder<ArticlesBloc, ArticleState>(
                        builder: (context, state) {
                          if (state is ArticleLoading) {
                            return CircularProgressIndicator();
                          } else if (state is ArticleLoaded) {
                            if (searchContent.isEmpty()) {
                              articlesSearch = state.articles;
                            } else {
                              articlesSearch = state.getArticlesBySearch(
                                  searchContent: searchContent);
                            }
                            return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: articlesSearch.length,
                                itemBuilder: (context, index) {
                                  return ArticleListTile(
                                      articleToDisplay: articlesSearch[index]);
                                });
                          } else if (state is ArticleError) {
                            return Text(state.errorMessage);
                          } else {
                            return Container();
                          }
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}