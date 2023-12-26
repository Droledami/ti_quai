import 'package:flutter/material.dart';

import '../../models/CustomerOrder.dart';

@immutable
abstract class OrdersEvent{}

class LoadOrdersList extends OrdersEvent{
  final bool paidOrders;

  LoadOrdersList(this.paidOrders);
}

class ReloadOrdersList extends OrdersEvent{
  final bool paidOrders;

  ReloadOrdersList(this.paidOrders);
}

class AddOrder extends OrdersEvent{
  final CustomerOrder order;

  AddOrder(this.order);
}

class UpdateOrder extends OrdersEvent{
  final CustomerOrder order;

  UpdateOrder(this.order);
}

class DeleteOrder extends OrdersEvent{
  final CustomerOrder order;

  DeleteOrder(this.order);
}
