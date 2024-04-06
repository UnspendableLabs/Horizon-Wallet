import 'package:uniparty/models/wallet_retrieve_info.dart';

class DataState {
  final WalletRetrieveInfo? data;
  final bool isLoading;
  final String? error;

  DataState({this.data, this.isLoading = true, this.error});
}
