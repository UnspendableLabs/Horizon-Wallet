abstract class ComposeIssuanceState {}

class ComposeIssuanceInitial extends ComposeIssuanceState {}

class ComposeIssuanceLoading extends ComposeIssuanceState {}

class ComposeIssuanceSuccess extends ComposeIssuanceState {}

class ComposeIssuanceError extends ComposeIssuanceState {
  final String message;

  ComposeIssuanceError({required this.message});
}
