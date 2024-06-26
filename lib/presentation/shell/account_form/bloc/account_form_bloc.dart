import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";
import "package:horizon/remote_data_bloc/remote_data_state.dart";
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/common/uuid.dart';

class AccountFormBloc extends Bloc<AccountFormEvent, RemoteDataState<Account>> {
  final accountRepository = GetIt.I<AccountRepository>();

  AccountFormBloc() : super(const RemoteDataState.initial()) {
    on<Submit>((event, emit) async {
      try {
        final account = Account(
          name: event.name,
          uuid: uuid.v4(),
          walletUuid: event.walletUuid,
          purpose: event.purpose,
          coinType: event.coinType,
          accountIndex: event.accountIndex,
        );

        await accountRepository.insert(account);

        emit(RemoteDataState.success(account));
      } catch (e) {
        emit(RemoteDataState.error(e.toString()));
      }
    });
  }
}
