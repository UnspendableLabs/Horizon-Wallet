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
  final Address address;

  Success({required this.address});
}

class Error extends OnboardingImportState {
  final String message;

  Error({required this.message});
}
