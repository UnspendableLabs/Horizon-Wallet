import 'package:horizon/domain/entities/cursor.dart' as domain_cursor;
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class UtxoRepositoryImpl implements UtxoRepository {
  final V2Api api;

  UtxoRepositoryImpl({required this.api});

  @override
  Future<List<Utxo>> getUnspentForAddress(String address,
      [bool? unconfirmed, String? unspentTxHash, bool? verbose]) async {
    final response =
        await api.getUnspentUTXOs(address, unconfirmed, unspentTxHash, verbose);

    final List<Utxo> utxos = [];
    for (var a in response.result ?? []) {
      utxos.add(Utxo(
          vout: a.vout,
          height: a.height,
          value: a.value,
          confirmations: a.confirmations,
          amount: a.amount,
          txid: a.txid,
          address: address));
    }
    return utxos;
  }

  @override
  Future<List<Utxo>> getUnspentForAddresses(List<String> addresses,
      [bool? unconfirmed, String? unspentTxHash, bool? verbose]) async {
    List<Utxo> utxos = [];
    int limit = 50;
    domain_cursor.Cursor? cursor;

    do {
      final response = await api.getUnspentUTXOsByAddresses(
          addresses.join(','),
          unconfirmed,
          verbose,
          limit,
          domain_cursor.CursorMapper.toData(cursor));
      for (UTXO a in response.result ?? []) {
        utxos.add(Utxo(
            vout: a.vout,
            height: a.height,
            value: a.value,
            confirmations: a.confirmations,
            amount: a.amount,
            txid: a.txid,
            address: a.address!));
      }
      cursor = domain_cursor.CursorMapper.toDomain(response.nextCursor);
    } while (cursor != null);

    return utxos;
  }
}
