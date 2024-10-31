import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import './get_addresses_event.dart';
import './get_addresses_state.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/address_repository.dart';

class GetAddressesBloc extends Bloc<GetAddressesEvent, GetAddressesState> {
  final List<Account> accounts;
  final AddressRepository addressRepository;

  GetAddressesBloc({required this.accounts, required this.addressRepository})
      : super(GetAddressesState()) {
    on<AccountChanged>(_handleAccountChanged);
    on<GetAddressesSubmitted>(_handleGetAddressesSubmitted);
  }

  void _handleAccountChanged(
      AccountChanged event, Emitter<GetAddressesState> emit) {
    final account = AccountInput.dirty(event.accountUuid);

    emit(state.copyWith(
      account: account,
      submissionStatus: Formz.validate([account])
          ? FormzSubmissionStatus.initial
          : FormzSubmissionStatus.failure,
    ));
  }

  Future<void> _handleGetAddressesSubmitted(
      GetAddressesSubmitted event, Emitter<GetAddressesState> emit) async {
    try {
      final selectedAccountUuid = state.account.value;

      final addresses =
          await addressRepository.getAllByAccountUuid(selectedAccountUuid);

      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.success,
        addresses: addresses,
      ));
    } catch (e) {
      emit(state.copyWith(
        submissionStatus: FormzSubmissionStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
