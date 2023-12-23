import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/blocs/article/article_events.dart';
import 'package:ti_quai/blocs/article/article_states.dart';
import 'package:ti_quai/blocs/order/order_events.dart';
import 'package:ti_quai/blocs/selectedOrder/selectedOrder_bloc.dart';
import 'package:ti_quai/firestore/firestore_service.dart';
import 'package:ti_quai/models/CustomerOrder.dart';
import 'package:ti_quai/models/SearchContent.dart';
import 'package:ti_quai/processes/print_order_requester.dart';
import './theme.dart';
import 'blocs/article/article_bloc.dart';
import 'custom_materials/BeachGradientDecoration.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/order/order_states.dart';
import 'custom_materials/decoration_functions.dart';
import 'custom_widgets/ArticleListTile.dart';
import 'custom_widgets/MenuButton.dart';
import 'custom_widgets/QuaiDrawer.dart';
import 'custom_widgets/ScrollableOrderList.dart';
import 'custom_widgets/SearchArticleWindow.dart';
import 'custom_widgets/TitleHeader.dart';
import 'custom_widgets/OrderToEditOrAdd.dart';
import 'firebase_options.dart';
import 'models/Article.dart';

//TODO: add end of day mode for the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    print("coucou du web");
  } else {
    print("JE SUIS SUR ANDROID PTN JE CRIE PARCE QUE Y A TROP DE LOGS ICI !!!");
  }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final fireStoreService = FirestoreService();
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrdersBloc>(
            create: (context) => OrdersBloc(fireStoreService)),
        BlocProvider<SelectedOrderBloc>(
          create: (context) => SelectedOrderBloc(),
        ),
        BlocProvider<ArticlesBloc>(create: (context) => ArticlesBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
    if (BlocProvider.of<ArticlesBloc>(context).state is! ArticleLoaded) {
      BlocProvider.of<ArticlesBloc>(context).add(LoadArticle());
    }
    BlocProvider.of<OrdersBloc>(context).add(LoadOrdersList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final OrdersBloc _orderBloc = BlocProvider.of<OrdersBloc>(context);
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
                    isEditMode: true,
                  isOrderPaid: false
                ));
          },
          backgroundColor: customColors.secondary!,
          child: const Icon(
            Icons.add,
            size: 40,
          ),
        ),
        body: BlocBuilder<OrdersBloc, OrdersState>(builder: (context, state) {
          if (state is OrdersListLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is OrdersListLoaded) {
            return Column(
              children: [
                SizedBox(
                  height: kIsWeb ? 65 : 100,
                ),
                Expanded(
                  flex: 7,
                  child: ScrollableOrderList(orders: state.orders),
                ),
                //Keeps some space at the bottom of the screen for visibility
                Expanded(flex: 1, child: SizedBox()),
              ],
            );
          } else if (state is OrdersError) {
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
  final bool isOrderPaid;

  static const String keyDefinedLater = "-definedLater-";

  EditOrAddScreenArguments({required this.orderId, required this.isEditMode, required this.isOrderPaid});
}

class EditOrAddOrderScreen extends StatefulWidget {
  const EditOrAddOrderScreen({super.key});

  @override
  State<EditOrAddOrderScreen> createState() => _EditOrAddOrderScreenState();
}

class _EditOrAddOrderScreenState extends State<EditOrAddOrderScreen> {
  @override
  void initState() {
    //Load articles in memory once.
    if (BlocProvider.of<ArticlesBloc>(context).state is! ArticleLoaded) {
      BlocProvider.of<ArticlesBloc>(context).add(LoadArticle());
    }
    BlocProvider.of<OrdersBloc>(context).add(LoadOrdersList());
    super.initState();
  }

  late CustomerOrder order;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as EditOrAddScreenArguments;
    final OrdersBloc _orderBloc = BlocProvider.of<OrdersBloc>(context);
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Container(
      decoration: BeachGradientDecoration(),
      child: PopScope(
        onPopInvoked: (didPop) {
          _orderBloc.add(LoadOrdersList());
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          //Allows parent container's bg to display
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            actions: [
              //The print order button won't be displayed if it is a new order
              Builder(builder: (context) {
                if (isOrderNotNew(args)) {
                  return ActionIconButton(
                    iconData: Icons.print,
                    onPressed: () {
                      final printRequester = PrintOrderRequester();
                      printRequester.sendPrintRequest(order);
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              }),
              Builder(
                  //The set order as paid button won't be displayed if it is a new order
                  builder: (context) {
                if (isOrderNotNew(args) && !args.isOrderPaid) {
                  return ActionIconButton(
                      iconData: Icons.attach_money,
                      onPressed: () {
                        confirmSetOrderAsPaidDialog(context, order);
                      });
                } else {
                  return SizedBox.shrink();
                }
              }),
            ],
            //leading: BackButton(), TODO:ceci
            centerTitle: true,
            title: TitleHeader(
              customColors: customColors,
              title:
                  "${isOrderNotNew(args) ? "Modifier" : "Ajouter une"} commande",
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
              if (isOrderNotNew(args)) {
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
          body: BlocBuilder<OrdersBloc, OrdersState>(builder: (context, state) {
            if (state is OrdersListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is OrdersListLoaded) {
              if (isOrderNotNew(args)) {
                order = state.getOrder(args.orderId);
              } else {
                order = CustomerOrder.createNew();
              }
              return Column(
                children: [
                  SizedBox(
                    height: kIsWeb ? 65 : 100,
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
            } else if (state is OrdersError) {
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

  Future<void> confirmSetOrderAsPaidDialog(
      BuildContext context, CustomerOrder order) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Marquer la commande comme payée ?"),
            content: Text(
                "Cette commande n'apparaîtra plus dans la liste des commandes en cours. Elle apparaîtra toute fois dans la liste des comptes à faire en fin de journée mais ne pourra plus y être modifiée."),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Annuler")),
              TextButton(
                  onPressed: () {
                    order.isPaid = true;
                    BlocProvider.of<OrdersBloc>(context).add(UpdateOrder(order));
                    Navigator.of(context).popUntil(ModalRoute.withName('/home'));
                  },
                  child: const Text("Confirmer"))
            ],
          );
        });
  }

  bool isOrderNotNew(EditOrAddScreenArguments args) =>
      args.isEditMode &&
      args.orderId != EditOrAddScreenArguments.keyDefinedLater;
}

class ActionIconButton extends StatelessWidget {
  const ActionIconButton({
    super.key,
    required this.iconData,
    required this.onPressed,
  });

  final IconData iconData;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        height: 55,
        width: 55,
        decoration: buildAppBarDecoration(customColors),
        child: IconButton(
          onPressed: () => onPressed(),
          icon: Icon(iconData),
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
          //leading: BackButton(), TODO: le mettre ici aussi une fois qu'il est fait
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
