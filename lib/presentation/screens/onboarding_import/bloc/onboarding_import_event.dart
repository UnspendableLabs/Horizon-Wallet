
abstract class OnboardingImportEvent {} 

class DeriveAddress extends OnboardingImportEvent {
  final String mnemonic;
  final String importFormat;
  DeriveAddress({required this.mnemonic, required this.importFormat});
}
