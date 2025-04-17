import 'package:fpdart/fpdart.dart';
import 'package:horizon/core/logging/logger.dart';

import 'package:horizon/data/models/asset_info.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/data/sources/repositories/events_repository_impl.dart';
import 'package:decimal/decimal.dart';

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockLogger extends Mock implements Logger {}

class MockBitcoinTx extends Mock implements BitcoinTx {
  @override
  final String txid;
  @override
  final List<Vin> vin;
  @override
  final List<Vout> vout;

  MockBitcoinTx({
    required this.txid,
    required this.vin,
    required this.vout,
  });
}

void main() {
  late MockBitcoinRepository mockBitcoinRepository;
  late VerboseEventMapper eventMapper;

  setUp(() {
    mockBitcoinRepository = MockBitcoinRepository();
    eventMapper = VerboseEventMapper(bitcoinRepository: mockBitcoinRepository);
    registerFallbackValue(MockBitcoinTx(txid: "txid", vin: [], vout: []));
    registerFallbackValue(MockLogger());
  });

  group('parseSwapFromMoveToUtxo', () {
    test('should return regular MoveToUtxo event when not a swap transaction',
        () async {
      // Arrange
      final apiEvent = api.VerboseMoveToUtxoEvent(
        eventIndex: 1,
        event: "UTXO_MOVE",
        txHash: "txHash123",
        blockIndex: 100,
        blockTime: 1234567890,
        params: api.VerboseMoveToUtxoParams(
          asset: "ASSET",
          blockIndex: 100,
          destination: "destination123",
          msgIndex: 0,
          quantity: 1000000,
          source: "source123",
          status: "valid",
          txHash: "txHash123",
          txIndex: 0,
          blockTime: 1234567890,
          quantityNormalized: "1.00000000",
          assetInfo: AssetInfoModel(
            divisible: true,
            description: "description",
            locked: false,
          ),
        ),
      );

      final mockTx = MockBitcoinTx(
        txid: "txHash123",
        vin: [
          Vin(
            txid: "vinTxid1",
            vout: 0,
            prevout: Prevout(
              scriptpubkey: "scriptpubkey1",
              scriptpubkeyAsm: "asm1",
              scriptpubkeyType: "type1",
              scriptpubkeyAddress: "address1",
              value: 100000,
            ),
            scriptsig: "scriptsig1",
            scriptsigAsm: "scriptsigAsm1",
            witness: [],
            isCoinbase: false,
            sequence: 0,
          ),
        ],
        vout: [
          Vout(
            scriptpubkey: "scriptpubkey2",
            scriptpubkeyAsm: "asm2",
            scriptpubkeyType: "type2",
            scriptpubkeyAddress: "destination123",
            value: 100000,
          ),
        ],
      );

      when(() => mockBitcoinRepository.getTransaction("txHash123"))
          .thenAnswer((_) async => Right(mockTx));

      // Act
      final result = await eventMapper.toDomain(apiEvent);

      // Assert
      expect(result, isA<VerboseMoveToUtxoEvent>());
      expect(result is AtomicSwapEvent, isFalse);
    });

    test('should return AtomicSwap event when transaction is a swap', () async {
      // Arrange
      final apiEvent = api.VerboseMoveToUtxoEvent(
        eventIndex: 1,
        event: "UTXO_MOVE",
        txHash: "swapTxHash",
        blockIndex: 100,
        blockTime: 1234567890,
        params: api.VerboseMoveToUtxoParams(
          asset: "ASSET",
          blockIndex: 100,
          destination: "swapDestination",
          msgIndex: 0,
          quantity: 1000000,
          source: "swapSource",
          status: "valid",
          txHash: "swapTxHash",
          txIndex: 0,
          blockTime: 1234567890,
          quantityNormalized: "1.00000000",
          assetInfo: AssetInfoModel(
            divisible: true,
            description: "description",
            locked: false,
          ),
        ),
      );

      final mockTx = MockBitcoinTx(
        txid: "swapTxHash",
        vin: [
          Vin(
            txid: "vinTxid1",
            vout: 0,
            prevout: Prevout(
              scriptpubkey: "scriptpubkey1",
              scriptpubkeyAsm: "asm1",
              scriptpubkeyType: "type1",
              scriptpubkeyAddress: "address1",
              value: 100000,
            ),
            scriptsig: "scriptsig1",
            scriptsigAsm: "scriptsigAsm1",
            witness: [],
            isCoinbase: false,
            sequence: 0,
          ),
          Vin(
            txid: "vinTxid2",
            vout: 1,
            prevout: Prevout(
              scriptpubkey: "scriptpubkey2",
              scriptpubkeyAsm: "asm2",
              scriptpubkeyType: "type2",
              scriptpubkeyAddress: "address2",
              value: 200000,
            ),
            scriptsig: "scriptsig2",
            scriptsigAsm: "scriptsigAsm2",
            witness: [],
            isCoinbase: false,
            sequence: 0,
          ),
        ],
        vout: [
          Vout(
            scriptpubkey: "scriptpubkey3",
            scriptpubkeyAsm: "asm3",
            scriptpubkeyType: "type3",
            scriptpubkeyAddress: "swapDestination",
            value: 100000,
          ),
          Vout(
            scriptpubkey: "scriptpubkey2",
            scriptpubkeyAsm: "asm2",
            scriptpubkeyType: "type2",
            scriptpubkeyAddress: "address2",
            value: 100000,
          ),
          Vout(
            scriptpubkey: "scriptpubkey3",
            scriptpubkeyAsm: "asm3",
            scriptpubkeyType: "type3",
            scriptpubkeyAddress: "swapDestination",
            value: 547,
          ),
        ],
      );

      when(() => mockBitcoinRepository.getTransaction("swapTxHash"))
          .thenAnswer((_) async => Right(mockTx));

      when(() => mockTx.isCounterpartyTx(any())).thenReturn(true);

      when(() => mockTx.getAmountSentNormalized(["swapDestination"]))
          .thenReturn(Decimal.parse("0.5")); // 0.5 BTC swap amount

      // Act
      final result = await eventMapper.toDomain(apiEvent);

      // Assert
      expect(result, isA<AtomicSwapEvent>());
      expect(result is VerboseMoveToUtxoEvent, isFalse);
    });

    test('should throw exception when bitcoin transaction fetch fails',
        () async {
      // Arrange
      final apiEvent = api.VerboseMoveToUtxoEvent(
        eventIndex: 1,
        event: "UTXO_MOVE",
        txHash: "failTxHash",
        blockIndex: 100,
        blockTime: 1234567890,
        params: api.VerboseMoveToUtxoParams(
          asset: "ASSET",
          blockIndex: 100,
          destination: "destination123",
          msgIndex: 0,
          quantity: 1000000,
          source: "source123",
          status: "valid",
          txHash: "failTxHash",
          txIndex: 0,
          blockTime: 1234567890,
          quantityNormalized: "1.00000000",
          assetInfo: AssetInfoModel(
            divisible: true,
            description: "description",
            locked: false,
          ),
        ),
      );

      when(() => mockBitcoinRepository.getTransaction("failTxHash"))
          .thenThrow(Exception("Failed to fetch transaction"));

      // Act & Assert
      expect(
        () => eventMapper.toDomain(apiEvent),
        throwsException,
      );
    });
  }, skip: true);
}
