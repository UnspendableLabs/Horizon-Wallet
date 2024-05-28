import 'package:horizon/domain/entities/address.dart';

abstract class OnboardingImportEvent {}

class PasswordSubmit extends OnboardingImportEvent {
  final String password;
  final String passwordConfirmation;
  PasswordSubmit({required this.password, required this.passwordConfirmation});
}

class MnemonicChanged extends OnboardingImportEvent {
  final String mnemonic;
  MnemonicChanged({required this.mnemonic});
}

class ImportFormatChanged extends OnboardingImportEvent {
  final String importFormat;
  ImportFormatChanged({required this.importFormat});
}

class AddressMapChanged extends OnboardingImportEvent {
  final Address address;
  final bool isChecked;
  AddressMapChanged({required this.address, required this.isChecked});
}

class ImportAddresses extends OnboardingImportEvent {}