import 'package:uniparty/models/wallet_retrieve_info.dart';

abstract class DataEvent {}

class FetchDataEvent extends DataEvent {}

class SetDataEvent extends DataEvent {
  final WalletRetrieveInfo walletRetrieveInfo;
  SetDataEvent({required this.walletRetrieveInfo});
}
