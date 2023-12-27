import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/pages/pageArguments/EditOrAddScreenArguments.dart';

import '../blocs/article/article_bloc.dart';
import '../blocs/article/article_events.dart';
import '../blocs/article/article_states.dart';
import '../blocs/order/order_bloc.dart';
import '../blocs/order/order_events.dart';
import '../blocs/order/order_states.dart';
import '../custom_materials/BeachGradientDecoration.dart';
import '../custom_materials/theme.dart';
import '../custom_widgets/buttons/ActionIconButton.dart';
import '../custom_widgets/buttons/ButtonBack.dart';
import '../custom_widgets/TitleHeader.dart';
import '../custom_widgets/order_display/OrderToEditOrAdd.dart';
import '../models/CustomerOrder.dart';
import '../processes/print_order_requester.dart';

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
    BlocProvider.of<OrdersBloc>(context).add(LoadOrdersList(false));
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
          _orderBloc.add(LoadOrdersList(false));
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
            leading: ButtonBack(customColors: customColors,),
            centerTitle: true,
            title: TitleHeader(
              customColors: customColors,
              title:
              isOrderNotNew(args) ? "Modifier" : "Ajouter",
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
                order = state.getOrder(args.orderId).copy();
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
                    BlocProvider.of<OrdersBloc>(context)
                        .add(UpdateOrder(order));
                    Navigator.of(context)
                        .popUntil(ModalRoute.withName('/home'));
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