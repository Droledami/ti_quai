import 'package:flutter/material.dart';

@immutable
abstract class SelectedOrderEvent{}

class SetSelectedOrder extends SelectedOrderEvent{
  SetSelectedOrder(this.orderId);

  final int orderId;
}

class UnselectOrder extends SelectedOrderEvent{}