// TODO: research part of / equatable
import 'package:uniparty/domain/entities/address.dart';

abstract class OnboardingImportState {}

class NotAsked extends OnboardingImportState {}

// class Loading extends OnboardingImportState {
//   final String mnemonic;
//   final String importFormat;
//
//   Loading({required this.mnemonic, required this.importFormat});
// }

class Loading extends OnboardingImportState {}

class Success extends OnboardingImportState {
  final List<Address> addresses;

  Success({required this.addresses});
}

class Error extends OnboardingImportState {
  final String message;

  Error({required this.message});
}
