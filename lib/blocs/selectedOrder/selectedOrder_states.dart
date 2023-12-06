
import 'package:flutter/cupertino.dart';

@immutable
abstract class SelectedOrderState{}

class NoOrderSelected extends SelectedOrderState{}

class OrderSelected extends SelectedOrderState{
  OrderSelected(this.selectedOrderId);

  final int selectedOrderId;
}
