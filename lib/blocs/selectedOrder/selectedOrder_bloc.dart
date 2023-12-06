import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ti_quai/firestore/firestore_service.dart';

import 'selectedOrder_events.dart';
import 'selectedOrder_states.dart';

class SelectedOrderBloc extends Bloc<SelectedOrderEvent, SelectedOrderState>{

  SelectedOrderBloc() : super(NoOrderSelected()){
    on<SetSelectedOrder>((event, emit){
      emit(OrderSelected(event.orderId));
    });

    on<UnselectOrder>((event, emit){
      emit(NoOrderSelected());
    });
  }
}
