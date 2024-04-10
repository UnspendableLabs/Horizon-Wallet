import 'package:uniparty/models/wallet_retrieve_info.dart';

abstract class DataEvent {}

class FetchDataEvent extends DataEvent {}

class SetDataEvent extends DataEvent {
  final WalletRetrieveInfo data;
  SetDataEvent({required this.data});
}

class WriteDataEvent extends DataEvent {
  final WalletRetrieveInfo data;
  WriteDataEvent({required this.data});
}
