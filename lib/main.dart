import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/blocs/article/article_events.dart';
import 'package:ti_quai/blocs/article/article_states.dart';
import 'package:ti_quai/blocs/order/order_events.dart';
import 'package:ti_quai/blocs/selectedOrder/selectedOrder_bloc.dart';
import 'package:ti_quai/custom_widgets/EntryBox.dart';
import 'package:ti_quai/enums/EntryType.dart';
import 'package:ti_quai/firestore/firestore_service.dart';
import 'package:ti_quai/models/CustomerOrder.dart';
import 'package:ti_quai/models/SearchContent.dart';
import './theme.dart';
import 'blocs/article/article_bloc.dart';
import 'custom_materials/BeachGradientDecoration.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/order/order_states.dart';
import 'custom_widgets/ArticleListTile.dart';
import 'custom_widgets/MenuButton.dart';
import 'custom_widgets/QuaiDrawer.dart';
import 'custom_widgets/QuaiTextContainer.dart';
import 'custom_widgets/ScrollableOrderList.dart';
import 'custom_widgets/SearchArticleWindow.dart';
import 'custom_widgets/TitleHeader.dart';
import 'custom_widgets/OrderToEditOrAdd.dart';
import 'firebase_options.dart';
import 'models/Article.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final fireStoreService = FirestoreService();
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(fireStoreService)),
        BlocProvider<SelectedOrderBloc>(
          create: (context) => SelectedOrderBloc(),
        ),
        BlocProvider<ArticleBloc>(create: (context) => ArticleBloc(fireStoreService)),
      ],
      child: MaterialApp(
        theme: ThemeData.light().copyWith(extensions: <ThemeExtension<dynamic>>[
          const CustomColors(
            primary: Color(0xFF7AE582),
            //For main products and menu buttons
            primaryDark: Color(0xFF25A18E),
            primaryLight: Color(0xFF9FFFCB),
            secondary: Color(0xFFF79256),
            //For promotions and action buttons
            secondaryLight: Color(0xFFFBD1A2),
            tertiary: Color(0xFF00A5CF),
            //Main background color
            tertiaryDark: Color(0xFF004E64),
            special: Color(0xFFD4E997),
            //For special elements such as comments and supplements
            cardQuarterTransparency: Color(0x4DFFFFFF),
            //White 30% alpha
            cardHalfTransparency: Color(0x80FFFFFF), //White 50% alpha
          ),
        ]),
        initialRoute: "/home",
        routes: {
          "/home": (context) => Homescreen(),
          "/order": (context) => EditOrAddOrderScreen(),
          "/articles": (context) => ArticleSearchPage(),
        },
      ),
    );
  }
}

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    BlocProvider.of<OrderBloc>(context).add(LoadOrder());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final OrderBloc _orderBloc = BlocProvider.of<OrderBloc>(context);
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Container(
      decoration: BeachGradientDecoration(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        //Allows parent container's bg to display
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: MenuButton(customColors: customColors),
          centerTitle: true,
          title: TitleHeader(
            customColors: customColors,
            title: "Accueil",
          ),
          backgroundColor: Colors.white.withOpacity(0.0),
        ),
        drawer: const QuaiDrawer(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, "/order",
                arguments: EditOrAddScreenArguments(
                    orderId: EditOrAddScreenArguments.keyDefinedLater,
                    isEditMode: true));
          },
          backgroundColor: customColors.secondary!,
          child: const Icon(
            Icons.add,
            size: 40,
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is OrderLoaded) {
            return Column(
              children: [
                const SizedBox(
                  height: 65,
                ),
                Expanded(
                  flex: 7,
                  child: ScrollableOrderList(orders: state.orders),
                ),
                //Keeps some space at the bottom of the screen for visibility
                Expanded(flex: 1, child: SizedBox())
              ],
            );
          } else if (state is OrderOperationSuccess) {
            _orderBloc.add(LoadOrder());
            return Container();
          } else if (state is OrderError) {
            return Text(state.errorMessage);
          } else {
            return Container();
          }
        }),
      ),
    );
  }
}

class EditOrAddScreenArguments {
  final String orderId;
  final bool isEditMode;

  static const String keyDefinedLater = "-definedLater-";

  EditOrAddScreenArguments({required this.orderId, required this.isEditMode});
}

class EditOrAddOrderScreen extends StatefulWidget {
  const EditOrAddOrderScreen({super.key});

  @override
  State<EditOrAddOrderScreen> createState() => _EditOrAddOrderScreenState();
}

class _EditOrAddOrderScreenState extends State<EditOrAddOrderScreen> {
  @override
  void initState() {
    BlocProvider.of<OrderBloc>(context).add(LoadOrder());
    super.initState();
  }

  late CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as EditOrAddScreenArguments;
    final OrderBloc _orderBloc = BlocProvider.of<OrderBloc>(context);
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Container(
      decoration: BeachGradientDecoration(),
      child: PopScope(
        onPopInvoked: (didPop) {
          _orderBloc.add(LoadOrder());
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          //Allows parent container's bg to display
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            //leading: BackButton(), TODO:ceci
            centerTitle: true,
            title: TitleHeader(
              customColors: customColors,
              title:
                  "${args.isEditMode && args.orderId != EditOrAddScreenArguments.keyDefinedLater ? "Modifier" : "Ajouter"} une commande",
            ),
            backgroundColor: Colors.white.withOpacity(0.0),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (order.tableNumber <= 0) {
                SnackBar errorNbTable = SnackBar(
                    content: Text("Erreur! Numéro de table incorrect."));
                ScaffoldMessenger.of(context).showSnackBar(errorNbTable);
                return;
              }
              if (order.orderElements.isEmpty) {
                SnackBar errorNoOrderElements = SnackBar(
                    content: Text(
                        "Erreur! Ajoutez au moins un élément avant de valider la commande."));
                ScaffoldMessenger.of(context)
                    .showSnackBar(errorNoOrderElements);
                return;
              }
              if (args.isEditMode &&
                  args.orderId != EditOrAddScreenArguments.keyDefinedLater) {
                _orderBloc.add(UpdateOrder(order));
              } else {
                _orderBloc.add(AddOrder(order));
              }
              Navigator.pop(context);
            },
            backgroundColor: customColors.secondary!,
            child: const Icon(
              Icons.check_outlined,
              size: 40,
            ),
          ),
          body: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is OrderLoaded) {
              if (args.isEditMode &&
                  args.orderId != EditOrAddScreenArguments.keyDefinedLater) {
                order = state.getOrder(args.orderId);
              } else {
                order = CustomerOrder.createNew();
              }
              return Column(
                children: [
                  const SizedBox(
                    height: 65,
                  ),
                  Expanded(
                    flex: 7,
                    child: SingleChildScrollView(
                        child: OrderToEditOrAdd(
                      order: order,
                      isEditMode: args.isEditMode,
                    )),
                  ),
                  Expanded(flex: 1, child: SizedBox()),
                ],
              );
            } else if (state is OrderOperationSuccess) {
              return Container();
            } else if (state is OrderError) {
              print(state.errorMessage);
              return Container();
            } else {
              return Container();
            }
          }),
        ),
      ),
    );
  }
}

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
    BlocProvider.of<ArticleBloc>(context).add(LoadArticle());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    final _articleBloc = BlocProvider.of<ArticleBloc>(context);
    return Container(
      decoration: BeachGradientDecoration(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          //leading: BackButton(), TODO: le mettre ici aussi une fois qu'il est fait
          centerTitle: true,
          title: TitleHeader(
            customColors: customColors,
            title: "Gestion d'articles",
          ),
          backgroundColor: Colors.white.withOpacity(0.0),
        ),
        drawer: QuaiDrawer(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(flex: 2,child: SizedBox.shrink()),
              SearchArticleWindow(
                searchContent: searchContent,
                onSearchChanged: (newSearchContent){
                  setState(() {
                    searchContent = newSearchContent;
                  });
                  //TODO: manage list of article returned from the form
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
              Flexible(
                flex: 6,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: customColors.cardQuarterTransparency!,
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: BlocBuilder<ArticleBloc, ArticleState>(builder: (context, state){
                      if(state is ArticleLoading){
                        return CircularProgressIndicator();
                      }else if (state is ArticleLoaded){
                        if(searchContent.isEmpty()){
                          articlesSearch = state.articles;
                        }else{
                          articlesSearch = state.getArticlesBySearch(searchContent: searchContent);
                        }
                        return ListView.builder(padding: EdgeInsets.zero, itemCount: articlesSearch.length, itemBuilder: (context, index){
                          return ArticleListTile(articleToDisplay: articlesSearch[index]);
                        });
                      }else if (state is ArticleError){
                        return Text(state.errorMessage);
                      }else if (state is ArticleOperationSuccess){
                        _articleBloc.add(LoadArticle());
                        return Container();
                      }else{
                        return Container();
                      }
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("Navigate to add Article Page");
            //TODO: Navigate to add article page
          },
          backgroundColor: customColors.secondary!,
          child: const Icon(
            Icons.add,
            size: 40,
          ),
        ),
      ),
    );
  }
}