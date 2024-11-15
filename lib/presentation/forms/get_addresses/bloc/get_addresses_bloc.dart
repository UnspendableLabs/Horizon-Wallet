import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import './get_addresses_event.dart';
import './get_addresses_state.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';

class GetAddressesBloc extends Bloc<GetAddressesEvent, GetAddressesState> {
  final List<Account> accounts;
  final AddressRepository addressRepository;
  final ImportedAddressRepository importedAddressRepository;

  GetAddressesBloc(
      {required this.accounts,
      required this.addressRepository,
      required this.importedAddressRepository})
      : super(GetAddressesState()) {
    on<AccountChanged>(_handleAccountChanged);
    on<GetAddressesSubmitted>(_handleGetAddressesSubmitted);
    on<AddressSelectionModeChanged>(_handleAddressSelectionModeChanged);
    on<ImportedAddressSelected>(_handleImportedAddressSelected);
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

      List<Address> addresses;

      if (state.addressSelectionMode == AddressSelectionMode.byAccount) {
        addresses =
            await addressRepository.getAllByAccountUuid(selectedAccountUuid);
      } else {
        addresses = [
          Address(
              address: state.importedAddress.value,
              accountUuid: "-1",
              index:
                  -1) // Cast an imported address to an address ( accountUuid and index do not matter )
        ]; // Wrap the single selected address in a list
      }

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

  void _handleAddressSelectionModeChanged(AddressSelectionModeChanged event,
      Emitter<GetAddressesState> emit) async {
    if (event.mode == AddressSelectionMode.importedAddresses) {
      final importedAddresses = await importedAddressRepository.getAll();
      emit(state.copyWith(
          addressSelectionMode: event.mode,
          importedAddresses: importedAddresses));
    } else {
      emit(state.copyWith(addressSelectionMode: event.mode));
    }
  }

  void _handleImportedAddressSelected(
      ImportedAddressSelected event, Emitter<GetAddressesState> emit) {
    final importedAddress = ImportedAddressInput.dirty(event.address);
    emit(state.copyWith(
      importedAddress: importedAddress,
      submissionStatus: Formz.validate([importedAddress])
          ? FormzSubmissionStatus.initial
          : FormzSubmissionStatus.failure,
    ));
  }
}
