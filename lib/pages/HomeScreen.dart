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
import '../custom_widgets/QuaiDrawer.dart';
import '../custom_widgets/ScrollableOrderList.dart';
import '../custom_widgets/TitleHeader.dart';
import '../custom_widgets/buttons/MenuButton.dart';

class Homescreen extends StatefulWidget {
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  bool listingPaidOrders = false;

  @override
  void initState() {
    if (BlocProvider.of<ArticlesBloc>(context).state is! ArticleLoaded) {
      BlocProvider.of<ArticlesBloc>(context).add(LoadArticle());
    }
    BlocProvider.of<OrdersBloc>(context).add(LoadOrdersList(listingPaidOrders));
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
          actions: [
            ActionIconButton(
                iconData: listingPaidOrders ? Icons.monetization_on : Icons.monetization_on_outlined,
                onPressed: () {
                  setState(() {
                    listingPaidOrders = !listingPaidOrders;
                    _orderBloc.add(ReloadOrdersList(listingPaidOrders));
                  });
                }),
          ],
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
                    isOrderPaid: false));
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
                  child: Builder(builder: (context) {
                    if (listingPaidOrders) {
                      return ScrollableOrderList(orders: state.orders);
                    } else {
                      return ScrollableOrderList(
                          orders: state.getUnpaidOrders()
                      );
                    }
                  }),
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