import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/firestore/firestore_service.dart';

import '../../models/CustomerOrder.dart';
import 'order_events.dart';
import 'order_states.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState>{
  final FirestoreService _firestoreService;
  final List<CustomerOrder> ordersList = List<CustomerOrder>.empty(growable: true);

  OrdersBloc(this._firestoreService) : super(OrdersInitial()){
    
    _firestoreService.listenToOrdersStream().onData((data) async {
      handleDataChanges(data);
    });

    on<ReloadOrdersList>((event,emit){
      emit(OrdersListReloading());
      add(LoadOrdersList());
    });

    on<LoadOrdersList>((event, emit) async {
      try{
        emit(OrdersListLoaded(ordersList));
      }catch(e){
        emit(OrdersError("Failed to load orders: $e"));
      }
    });

    on<AddOrder>((event, emit) async {
      try{
        await _firestoreService.addOrder(event.order);
      }catch(e){
        emit(OrdersError("Failed to add order  ${event.order.id}: $e"));
      }
    });

    on<UpdateOrder>((event, emit)async {
      try{
        await _firestoreService.updateOrder(event.order);
      }catch(e){
        emit(OrdersError('Failed to update order ${event.order.id}: $e'));
      }
    });

    on<DeleteOrder>((event, emit) async {
      try{
        await _firestoreService.deleteOrder(event.order.id);
      }catch(e){
        emit(OrdersError("Failed to delete order ${event.order.id}: $e"));
      }
    });
  }

  void handleDataChanges(QuerySnapshot<Object?> data) {
    for (var change in data.docChanges) {
      switch (change.type){
        case DocumentChangeType.added:
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          ordersList.add(_firestoreService.firebaseDataToCustomerOrder(data, change.doc.id));
          add(ReloadOrdersList());
          break;
        case DocumentChangeType.modified:
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          for (int i = 0; i< ordersList.length ; i++) {
            if(ordersList[i].id == change.doc.id){
              ordersList[i] = _firestoreService.firebaseDataToCustomerOrder(data, change.doc.id);
            }
          }
          add(ReloadOrdersList());
          break;
        case DocumentChangeType.removed:
          ordersList.removeWhere((order) => order.id == change.doc.id);
          add(ReloadOrdersList());
          break;
      }
    }
  }
}