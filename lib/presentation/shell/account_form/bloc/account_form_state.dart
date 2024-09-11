import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/domain/entities/account.dart';

part 'account_form_state.freezed.dart';

@freezed
class AccountFormState with _$AccountFormState {
  const factory AccountFormState.initial() = _Initial;
  const factory AccountFormState.loading() = _Loading;
  const factory AccountFormState.success(Account account) = _Success;
  const factory AccountFormState.finalize() = _Finalize;
  const factory AccountFormState.error(String error) = _Error;
}
