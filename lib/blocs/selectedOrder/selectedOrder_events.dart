import 'package:flutter/cupertino.dart';

@immutable
abstract class SelectedOrderEvent{}

class SetSelectedOrder extends SelectedOrderEvent{
  SetSelectedOrder(this.orderId);

  final int orderId;
}

class UnselectOrder extends SelectedOrderEvent{}