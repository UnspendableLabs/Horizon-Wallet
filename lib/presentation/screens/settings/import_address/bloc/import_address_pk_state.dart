import 'package:horizon/domain/entities/imported_address.dart';

sealed class ImportAddressPkState {}

class ImportAddressPkInitial extends ImportAddressPkState {}

class ImportAddressPkLoading extends ImportAddressPkState {}

class ImportAddressPkError extends ImportAddressPkState {
  final String error;
  ImportAddressPkError(this.error);
}

class ImportAddressPkSuccess extends ImportAddressPkState {
  final ImportedAddress address;
  ImportAddressPkSuccess(this.address);
}
