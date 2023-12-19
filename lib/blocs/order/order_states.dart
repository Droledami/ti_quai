import 'package:flutter/material.dart';

import '../../models/CustomerOrder.dart';

@immutable
abstract class OrdersState {}

class OrdersInitial extends OrdersState{}

class OrdersListLoading extends OrdersState{}

class OrdersListReloading extends OrdersState{}

class OrdersListLoaded extends OrdersState{
  final List<CustomerOrder> orders;

  OrdersListLoaded(this.orders);

  CustomerOrder getOrder(String orderId){
    for(CustomerOrder order in orders){
      if(orderId == order.id){
        return order;
      }
    }
    throw Exception("Couldn't find order with ID: $orderId");
  }
}

class OrdersOperationSuccess extends OrdersState{
  final String message;

  OrdersOperationSuccess(this.message);
}

class OrdersError extends OrdersState{
  final String errorMessage;

  OrdersError(this.errorMessage);
}