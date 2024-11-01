import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_state.dart';

class ComposeDispenserOnNewAddressBloc extends Bloc<
    ComposeDispenserOnNewAddressEvent, ComposeDispenserOnNewAddressState> {
  ComposeDispenserOnNewAddressBloc()
      : super(const ComposeDispenserOnNewAddressState.initial()) {
    on<CollectPassword>((event, emit) {
      emit(const ComposeDispenserOnNewAddressState.collectPassword());
    });
    on<ComposeTransactions>((event, emit) {
      emit(const ComposeDispenserOnNewAddressState.success());
    });
  }
}
