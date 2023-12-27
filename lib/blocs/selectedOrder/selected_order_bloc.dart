import 'package:flutter_bloc/flutter_bloc.dart';

import 'selected_order_events.dart';
import 'selected_order_states.dart';

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
