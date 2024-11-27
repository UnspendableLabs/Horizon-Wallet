import "package:fpdart/fpdart.dart";
import 'package:horizon/data/sources/network/mempool_space_client.dart';
import "package:horizon/domain/entities/transaction_info_mempool.dart";
import "package:horizon/domain/repositories/transaction_info_repository.dart";

class TransactionInfoRepositoryMempoolSpaceImpl
    implements TransactionInfoRepository {
  final MempoolSpaceApi _mempoolSpaceApi;

  TransactionInfoRepositoryMempoolSpaceImpl(
      {required MempoolSpaceApi mempoolSpaceApi})
      : _mempoolSpaceApi = mempoolSpaceApi;

  @override
  TaskEither<String, TransactionInfoMempool> getTransactionInfo(String txid) {
    return TaskEither.tryCatch(
      () => _getTransactionInfo(txid),
      (error, stacktrace) => "GetTransactionInfo failure",
    );
  }

  Future<TransactionInfoMempool> _getTransactionInfo(String txid) async {
    final response = await _mempoolSpaceApi.getTransactionInfo(txid);

    return response.toDomain();
  }
}

extension MempoolSpaceTransactionMapper on MempoolSpaceTransaction {
  TransactionInfoMempool toDomain() {
    return TransactionInfoMempool(
      txid: txid,
      version: version,
      locktime: locktime,
      inputs: vin
          .map((input) => Input(
                txid: input.txid,
                vout: input.vout,
                address: input.prevout.scriptpubkey_address,
                value: input.prevout.value,
                isCoinbase: input.is_coinbase,
                sequence: input.sequence,
              ))
          .toList(),
      outputs: vout
          .map((output) => Output(
                address: output.scriptpubkey_address,
                value: output.value,
                scriptType: output.scriptpubkey_type,
              ))
          .toList(),
      size: size,
      weight: weight,
      fee: fee,
      status: TransactionStatusMempool(
        confirmed: status.confirmed,
        blockHeight: status.block_height,
        blockHash: status.block_hash,
        blockTime: status.block_time,
      ),
    );
  }
}
