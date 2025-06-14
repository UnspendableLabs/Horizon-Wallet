import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:equatable/equatable.dart';

class TokenSelectorOption extends Equatable {
  final String name;
  final String? description;

  final Option<MultiAddressBalance> balance;

  const TokenSelectorOption(
      {required this.name, required this.description, required this.balance});

  TokenSelectorOption copyWith({
    String? name,
    String? description,
    Option<MultiAddressBalance>? balance,
  }) {
    return TokenSelectorOption(
      name: name ?? this.name,
      description: description ?? this.description,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [name, description, balance];
}


enum TokenSelectorInputError {
  required,
}

class TokenSelectorInput
    extends FormzInput<TokenSelectorOption?, TokenSelectorInputError> {
  const TokenSelectorInput.dirty({required TokenSelectorOption value})
      : super.dirty(value);

  const TokenSelectorInput.pure() : super.pure(null);

  @override
  TokenSelectorInputError? validator(TokenSelectorOption? value) {
    if (value == null) {
      return TokenSelectorInputError.required;
    }
    return null;
  }
}

class TokenSelectorFormModel with FormzMixin {
  final List<TokenSelectorOption> balances;
  final TokenSelectorInput tokenSelectorInput;
  final FormzSubmissionStatus submissionStatus;

  TokenSelectorFormModel(
      {required this.balances,
      required this.tokenSelectorInput,
      required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [tokenSelectorInput];

  TokenSelectorFormModel copyWith({
    List<TokenSelectorOption>? balances,
    TokenSelectorInput? tokenSelectorInput,
    FormzSubmissionStatus? submissionStatus,
  }) {
    return TokenSelectorFormModel(
      balances: balances ?? this.balances,
      tokenSelectorInput: tokenSelectorInput ?? this.tokenSelectorInput,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }

  bool get disabled {
    return tokenSelectorInput.value == null;
  }
}

class TokenSelectorFormEvent extends Equatable {
  const TokenSelectorFormEvent();

  @override
  List<Object?> get props => [];
}

class TokenSelected extends TokenSelectorFormEvent {
  final TokenSelectorOption option;
  const TokenSelected(this.option);
}

class SubmitClicked extends TokenSelectorFormEvent {
  const SubmitClicked();
}

class TokenSelectorFormBloc
    extends Bloc<TokenSelectorFormEvent, TokenSelectorFormModel> {
  TokenSelectorFormBloc({
    required List<MultiAddressBalance> initialBalances,
  }) : super(TokenSelectorFormModel(
            balances: initialBalances
                .map((balance) => TokenSelectorOption(
                      name: balance.asset,
                      description: balance.assetInfo.description,
                      balance: Option.of(balance),
                    ))
                .toList(),
            tokenSelectorInput: const TokenSelectorInput.pure(),
            submissionStatus: FormzSubmissionStatus.initial)) {
    on<TokenSelected>(_handleTokenSelected);
    on<SubmitClicked>(_handleSubmitClicked);
  }

  _handleTokenSelected(
      TokenSelected event, Emitter<TokenSelectorFormModel> emit) {
    emit(state.copyWith(
        tokenSelectorInput: TokenSelectorInput.dirty(value: event.option)));
  }

  _handleSubmitClicked(
      SubmitClicked event, Emitter<TokenSelectorFormModel> emit) {
    if (state.tokenSelectorInput.value == null) {
      return;
    }
    emit(state.copyWith(submissionStatus: FormzSubmissionStatus.success));
  }
}
