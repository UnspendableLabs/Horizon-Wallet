// TODO: research part of / equatable

abstract class OnboardingImportState {}

class NotAsked extends OnboardingImportState {}

class Loading extends OnboardingImportState {
  final String mnemonic;
  final String importFormat;

  Loading({required this.mnemonic, required this.importFormat});
}

class Success extends OnboardingImportState {
  final String address;

  Success({required this.address});
}

class Error extends OnboardingImportState {
  final String message;

  Error({required this.message});
}
