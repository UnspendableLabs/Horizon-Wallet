import 'package:uniparty/models/wallet_retrieve_info.dart';

class DataState {
  final Initial? initial;
  final Loading? loading;
  final Success? success;
  final Failure? failure;

  DataState({this.initial, this.success, this.loading, this.failure});
}

class Initial {}

class Loading {}

class Success {
  final WalletRetrieveInfo data;
  Success({
    required this.data,
  });
}

class Failure {
  final String message;
  Failure({required this.message});
}
