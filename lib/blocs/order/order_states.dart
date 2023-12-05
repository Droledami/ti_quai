import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:ti_quai/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/CustomerOrder.dart';
import 'order_bloc.dart';
import 'order_events.dart';

@immutable
abstract class OrderState {}

class OrderInitial extends OrderState{}

class OrderLoading extends OrderState{}

class OrderLoaded extends OrderState{
  final List<CustomerOrder> orders;

  OrderLoaded(this.orders);
}

class OrderOperationSuccess extends OrderState{
  final String message;

  OrderOperationSuccess(this.message);
}

class OrderError extends OrderState{
  final String errorMessage;

  OrderError(this.errorMessage);
}