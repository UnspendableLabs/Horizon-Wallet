import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/locked_utxo_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:logger/logger.dart';
import 'package:horizon/data/sources/network/esplora_client.dart';

final logger = Logger();

class UtxoRepositoryImpl implements UtxoRepository {
  final V2Api api;
  final LockedUtxoRepository lockedUtxoRepository;
  final EsploraApi _esploraApi;

  UtxoRepositoryImpl({
    required this.api,
    required this.lockedUtxoRepository,
    required EsploraApi esploraApi,
  }) : _esploraApi = esploraApi;

  @override
  Future<List<Utxo>> getUnspentForAddress(String address) async {
    final esploraUtxos = await _esploraApi.getUtxosForAddress(address);

    // TODO: do we want to filter out locked utxos here? or in the blocs?
    final lockedUtxos =
        await lockedUtxoRepository.getLockedUtxosForAddress(address);
    final lockedUtxoSet = lockedUtxos.map((u) => '${u.txid}:${u.vout}').toSet();

    return esploraUtxos
        .where((a) => !lockedUtxoSet.contains('${a.txid}:${a.vout}'))
        .map((a) {
      return Utxo(
        vout: a.vout,
        height: a.status.blockHeight,
        value: a.value,
        txid: a.txid,
        address: address,
        confirmed: a.status.confirmed,
      );
    }).toList();
  }
}
