import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/action.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/setup.dart';
import 'package:test/test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ComposeRepository composeRepository;
  late UtxoRepository utxoRepository;
  late TransactionService transactionService;
  late BitcoindService bitcoindService;

  setUp(() async {
    await setup();
    composeRepository = GetIt.I<ComposeRepository>();
    utxoRepository = GetIt.I<UtxoRepository>();
    transactionService = GetIt.I<TransactionService>();
    bitcoindService = GetIt.I<BitcoindService>();
  });

  tearDown(() async {});

  group(DispenseAction, () {
    test('should construct a valid transaction', () async {
      final utxos = await utxoRepository.getUnspentForAddress(
        'bc1q0eapk4tyqa7r2vcta6z6v2mgnqcux3kfkmurzp',
      );

      final send = await composeRepository.composeSendVerbose(
        200,
        utxos,
        ComposeSendParams(
          source: 'bc1q0eapk4tyqa7r2vcta6z6v2mgnqcux3kfkmurzp',
          destination: 'bc1qcxlwq8x9fnhyhgywlnja35l7znt58tud9duqay',
          asset: 'A4630460187535670455',
          quantity: 10,
        ),
      );

      print(send.rawtransaction);

      final utxoMap = {
        for (var utxo in utxos) utxo.txid: utxo,
      };
      final decodedSend =
          await bitcoindService.decoderawtransaction(send.rawtransaction);

      final transaction = await transactionService.constructTransaction(
        unsignedTransaction: send.rawtransaction,
        sourceAddress: 'bc1q0eapk4tyqa7r2vcta6z6v2mgnqcux3kfkmurzp',
        utxoMap: utxoMap,
        decodedTx: decodedSend,
      );

      print(transaction);
    });
  });
}
