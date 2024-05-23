import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_event.dart';
import 'package:uniparty/presentation/screens/dashboard/bloc/dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState()) {
    on<GetAddresses>(
      (event, emit) {
        emit(state.copyWith(addressState: AddressStateLoading()));
        // Get addresses
        emit(state.copyWith(addressState: AddressStateSuccess()));
      },
    );
  }
}
