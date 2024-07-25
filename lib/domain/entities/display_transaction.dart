import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/transaction_info.dart';




class DisplayTransaction extends Equatable {
  final String hash;
  final TransactionInfo info;
  const DisplayTransaction({required this.hash, required this.info});

  @override
  List<Object> get props => [hash];
}
