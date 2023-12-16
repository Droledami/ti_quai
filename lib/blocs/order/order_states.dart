import 'package:flutter/material.dart';

import '../../models/CustomerOrder.dart';

@immutable
abstract class OrdersState {}

class OrderInitial extends OrdersState{}

class OrderLoading extends OrdersState{}

class OrderLoaded extends OrdersState{
  final List<CustomerOrder> orders;

  OrderLoaded(this.orders);

  CustomerOrder getOrder(String orderId){
    for(CustomerOrder order in orders){
      if(orderId == order.id){
        return order;
      }
    }
    throw Exception("Couldn't find order with ID: $orderId");
  }
}

class OrderOperationSuccess extends OrdersState{
  final String message;

  OrderOperationSuccess(this.message);
}

class OrderError extends OrdersState{
  final String errorMessage;

  OrderError(this.errorMessage);
}