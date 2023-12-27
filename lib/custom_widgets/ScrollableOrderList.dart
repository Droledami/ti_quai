import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/selectedOrder/selected_order_bloc.dart';
import '../blocs/selectedOrder/selected_order_events.dart';
import '../blocs/selectedOrder/selected_order_states.dart';
import '../models/CustomerOrder.dart';
import 'order_display/OrderDetailed.dart';
import 'order_display/OrderSimple.dart';

class ScrollableOrderList extends StatefulWidget {
  const ScrollableOrderList({super.key, required this.orders});

  final List<CustomerOrder> orders;

  @override
  State<ScrollableOrderList> createState() => _ScrollableOrderListState();
}

class _ScrollableOrderListState extends State<ScrollableOrderList> {
  @override
  Widget build(BuildContext context) {
    int orderBoxId = -1;
    return SingleChildScrollView(
      child: BlocBuilder<SelectedOrderBloc, SelectedOrderState>(
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widget.orders.map((order) {
                orderBoxId++;
                if (state is OrderSelected) {
                  if(orderBoxId == state.selectedOrderId){
                    return OrderDetailed(order: order, orderBoxId: orderBoxId, closeSelection: () {
                      setState(() {
                        BlocProvider.of<SelectedOrderBloc>(context)
                            .add(UnselectOrder());
                      });
                    });
                  }else{
                    return OrderSimple(order: order, changeSelection: (orderBoxId) {
                      setState(() {
                        BlocProvider.of<SelectedOrderBloc>(context)
                            .add(SetSelectedOrder(orderBoxId));
                      });
                    }, orderBoxId: orderBoxId);
                  }
                } else if (state is NoOrderSelected) {
                  return OrderSimple(order: order, changeSelection: (orderBoxId) {
                    setState(() {
                      BlocProvider.of<SelectedOrderBloc>(context)
                          .add(SetSelectedOrder(orderBoxId));
                    });
                  }, orderBoxId: orderBoxId);
                } else {
                  return SizedBox.shrink();
                }
              }).toList(),
            );
          }),
    );
  }
}