import 'package:flutter/cupertino.dart';

import '../../models/CustomerOrder.dart';

@immutable
abstract class OrderState {}

class OrderInitial extends OrderState{}

class OrderLoading extends OrderState{}

class OrderLoaded extends OrderState{
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

class OrderOperationSuccess extends OrderState{
  final String message;

  OrderOperationSuccess(this.message);
}

class OrderError extends OrderState{
  final String errorMessage;

  OrderError(this.errorMessage);
}