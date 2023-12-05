import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/firestore/firestore_service.dart';

import 'order_events.dart';
import 'order_states.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState>{
  final FirestoreService _firestoreService;

  OrderBloc(this._firestoreService) : super(OrderInitial()){
    on<LoadOrder>((event, emit) async {
      try{
        emit(OrderLoading());
        final orders = await _firestoreService.getOrders().first;
        emit(OrderLoaded(orders));
      }catch(e){
        emit(OrderError("Failed to load orders: $e"));
      }
    });

    on<AddOrder>((event, emit) async {
      try{
        emit(OrderLoading());
        await _firestoreService.addOrder(event.order);
        emit(OrderOperationSuccess("Successfully added order: ${event.order.id}"));
      }catch(e){
        emit(OrderError("Failed to add order  ${event.order.id}: $e"));
      }
    });

    on<UpdateOrder>((event, emit)async {
      try{
        emit(OrderLoading());
        await _firestoreService.updateOrder(event.order);
        emit(OrderOperationSuccess("Successfully updated order: ${event.order.id}"));
      }catch(e){
        emit(OrderError('Failed to update order ${event.order.id}: $e'));
      }
    });

    on<DeleteOrder>((event, emit) async {
      try{
        emit(OrderLoading());
        await _firestoreService.deleteOrder(event.order.id);
        emit(OrderOperationSuccess("Successfully deleted order: ${event.order.id}"));
      }catch(e){
        emit(OrderError("Failed to delete order ${event.order.id}: $e"));
      }
    });
  }
}