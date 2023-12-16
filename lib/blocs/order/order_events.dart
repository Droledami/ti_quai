import 'package:flutter/material.dart';

import '../../models/CustomerOrder.dart';

@immutable
abstract class OrdersEvent{}

class LoadOrders extends OrdersEvent{}

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
