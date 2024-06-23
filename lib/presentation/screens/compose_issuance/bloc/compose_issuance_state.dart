import 'package:horizon/domain/entities/compose_issuance.dart';

abstract class ComposeIssuanceState {}

class ComposeIssuanceInitial extends ComposeIssuanceState {}

class ComposeIssuanceLoading extends ComposeIssuanceState {}

class ComposeIssuanceSuccess extends ComposeIssuanceState {
  final ComposeIssuance composeIssuance;

  ComposeIssuanceSuccess({required this.composeIssuance});
}

class ComposeIssuanceError extends ComposeIssuanceState {
  final String message;

  ComposeIssuanceError({required this.message});
}
