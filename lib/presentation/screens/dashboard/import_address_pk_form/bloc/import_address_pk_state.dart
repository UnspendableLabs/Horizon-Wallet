import 'package:horizon/domain/entities/imported_address.dart';

sealed class ImportAddressPkState {}

class ImportAddressPkStep1 extends ImportAddressPkState {}

class ImportAddressPkStep2 extends ImportAddressPkState {
  final Step2State state;
  ImportAddressPkStep2({required this.state});
}

abstract class Step2State {}

class Step2Initial extends Step2State {}

class Step2Loading extends Step2State {}

class Step2Error extends Step2State {
  final String error;
  Step2Error(this.error);
}

class Step2Success extends Step2State {
  final ImportedAddress address;
  Step2Success(this.address);
}
