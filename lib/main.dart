import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/blocs/order/order_events.dart';
import 'package:ti_quai/blocs/selectedOrder/selectedOrder_bloc.dart';
import 'package:ti_quai/enums/PaymentMethod.dart';
import 'package:ti_quai/firestore/firestore_service.dart';
import 'package:ti_quai/models/CustomerOrder.dart';
import 'package:ti_quai/models/OrderElement.dart';
import './theme.dart';
import 'custom_materials/BeachGradientDecoration.dart';
import 'blocs/order/order_bloc.dart';
import 'blocs/order/order_states.dart';
import 'custom_widgets/MenuButton.dart';
import 'custom_widgets/QuaiDrawer.dart';
import 'custom_widgets/ScrollableOrderList.dart';
import 'custom_widgets/TitleHeader.dart';
import 'custom_widgets/OrderToEditOrAdd.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirestoreService firestoreService = FirestoreService();
  //
  // try {
  //   var oeList = List<OrderElement>.empty(growable: true);
  //   OrderElement oe = OrderElement(
  //       article: Article.menu(
  //           alpha: "B",
  //           number: 3,
  //           subAlpha: "y",
  //           name: "En selle Marcel",
  //           price: 12),
  //       quantity: 3);
  //   oe.promotion = Promotion(
  //       discountValue: 3, nameLong: "Stampit Fidélité", nameShort: "Stampit");
  //   oe.hasPromotion = true;
  //   oe.comment = "Sauce BBQ";
  //   oe.commentIsExtra = true;
  //   oe.extraPrice = 5;
  //
  //   OrderElement oe2 = OrderElement(
  //       article: Article.other(
  //           name: "Le beau bic",
  //           price: 3),
  //       quantity: 2);
  //   oe2.promotion = null;
  //   oe2.hasPromotion = false;
  //   oe2.comment = "";
  //   oe2.commentIsExtra = false;
  //   oe2.extraPrice = 0;
  //
  //   oeList.add(oe2);
  //   oeList.add(oe);
  //   firestoreService.updateOrder(CustomerOrder(
  //       id: "9RtXjsNAktg1ghWa9zGV",
  //       date: DateTime.now(),
  //       orderElements: oeList,
  //       paymentMethod: PaymentMethod.cash, tableNumber: 2));
  // } catch (e) {
  //   print(e);
  // }

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(FirestoreService())),
        BlocProvider<SelectedOrderBloc>(
          create: (context) => SelectedOrderBloc(),
        )
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
      child: Scaffold(
        extendBodyBehindAppBar: true,
        //Allows parent container's bg to display
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          //leading: BackButton(), TODO:ceci
          centerTitle: true,
          title: TitleHeader(
            customColors: customColors,
            title: "${args.isEditMode && args.orderId != EditOrAddScreenArguments.keyDefinedLater? "Modifier" : "Ajouter"} une commande",
          ),
          backgroundColor: Colors.white.withOpacity(0.0),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if(order.tableNumber <=0){
              SnackBar errorNbTable = SnackBar(content: Text("Erreur! Numéro de table incorrect."));
              ScaffoldMessenger.of(context).showSnackBar(errorNbTable);
              return;
            }
            if(order.orderElements.isEmpty){
              SnackBar errorNoOrderElements = SnackBar(content: Text("Erreur! Ajoutez au moins un élément avant de valider la commande."));
              ScaffoldMessenger.of(context).showSnackBar(errorNoOrderElements);
              return;
            }
            if(args.isEditMode && args.orderId != EditOrAddScreenArguments.keyDefinedLater){
              _orderBloc.add(UpdateOrder(order));
            }else{
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
    );
  }
}
