import 'package:flutter/cupertino.dart';

import '../../models/CustomerOrder.dart';

@immutable
abstract class OrderEvent{}

class LoadOrder extends OrderEvent{}

class AddOrder extends OrderEvent{
  final CustomerOrder order;

  AddOrder(this.order);
}

class UpdateOrder extends OrderEvent{
  final CustomerOrder order;

  UpdateOrder(this.order);
}

class DeleteOrder extends OrderEvent{
  final CustomerOrder order;

  DeleteOrder(this.order);
}
