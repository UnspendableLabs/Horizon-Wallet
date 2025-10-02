import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:equatable/equatable.dart';
import 'package:horizon/domain/usecases/get_all_balances.dart';

class TokenSelectorOption extends Equatable {
  final String name;
  final String? description;

  final Option<AssetBalanceSummary> balance;

  const TokenSelectorOption(
      {required this.name, required this.description, required this.balance});

  TokenSelectorOption copyWith({
    String? name,
    String? description,
    Option<AssetBalanceSummary>? balance,
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
  final BalancesSet balancesSet;
  final bool includeMempool;
  final TokenSelectorInput tokenSelectorInput;
  final FormzSubmissionStatus submissionStatus;

  TokenSelectorFormModel(
      {required this.includeMempool,
      required this.balancesSet,
      required this.tokenSelectorInput,
      required this.submissionStatus});

  @override
  List<FormzInput> get inputs => [tokenSelectorInput];

  List<TokenSelectorOption> get balances {
    final balances = includeMempool
        ? balancesSet.projected.summarizeOrdered()
        : balancesSet.confirmed.summarizeOrdered();

    return balances
        .map((balance) => TokenSelectorOption(
              name: balance.asset,
              description: "",
              balance: Option.of(balance),
            ))
        .toList();
  }

  TokenSelectorFormModel copyWith({
    // List<TokenSelectorOption>? balances,
    bool? includeMempool,
    BalancesSet? balancesSet,
    TokenSelectorInput? tokenSelectorInput,
    FormzSubmissionStatus? submissionStatus,
  }) {
    return TokenSelectorFormModel(
      includeMempool: includeMempool ?? this.includeMempool,
      balancesSet: balancesSet ?? this.balancesSet,
      tokenSelectorInput: tokenSelectorInput ?? this.tokenSelectorInput,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
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

class IncludeMempoolChanged extends TokenSelectorFormEvent {
  final bool includeMempool;
  const IncludeMempoolChanged(this.includeMempool);
}

class TokenSelectorFormBloc
    extends Bloc<TokenSelectorFormEvent, TokenSelectorFormModel> {
  TokenSelectorFormBloc({
    required BalancesSet balancesSet,
  }) : super(TokenSelectorFormModel(
            includeMempool: true,
            balancesSet: balancesSet,
            tokenSelectorInput: const TokenSelectorInput.pure(),
            submissionStatus: FormzSubmissionStatus.initial)) {
    on<TokenSelected>(_handleTokenSelected);
    on<SubmitClicked>(_handleSubmitClicked);
    on<IncludeMempoolChanged>(_handleIncludeMempoolChanged);
  }

  _handleIncludeMempoolChanged(
      IncludeMempoolChanged event, Emitter<TokenSelectorFormModel> emit) {
    emit(state.copyWith(
      includeMempool: event.includeMempool,
      tokenSelectorInput: TokenSelectorInput.pure(),
    ));
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
