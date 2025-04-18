sealed class AccountFormState {}

class AccountFormStep1 extends AccountFormState {}

class AccountFormStep2 extends AccountFormState {
  final Step2State state;
  AccountFormStep2({required this.state});
}

abstract class Step2State {}

class Step2Initial extends Step2State {}

class Step2Loading extends Step2State {}

class Step2Error extends Step2State {
  final String error;
  Step2Error(this.error);
}

class AccountFormSuccess extends AccountFormState {
  AccountFormSuccess();
}
