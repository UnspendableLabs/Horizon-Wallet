import 'package:horizon/common/constants.dart';

abstract class OnboardingImportPKEvent {}

class PKChanged extends OnboardingImportPKEvent {
  final String pk;
  PKChanged({required this.pk});
}

class KeyTypeChanged extends OnboardingImportPKEvent {
  final KeyType keyType;
  KeyTypeChanged({required this.keyType});
}

class ImportFormatChanged extends OnboardingImportPKEvent {
  final String importFormat;
  ImportFormatChanged({required this.importFormat});
}

class PKSubmit extends OnboardingImportPKEvent {
  final KeyType keyType;
  final String importFormat;
  final String pk;
  PKSubmit(
      {required this.importFormat, required this.pk, required this.keyType});
}

class ImportWallet extends OnboardingImportPKEvent {
  final String password;
  ImportWallet({required this.password});
}
