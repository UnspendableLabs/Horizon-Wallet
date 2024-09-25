import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';

class Case {
  String addressType;
  int ins;
  int outs;
  String rawTransaction;
  int expectedVBytes;

  Case({
    required this.addressType,
    required this.ins,
    required this.outs,
    required this.rawTransaction,
    required this.expectedVBytes,
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TransactionService.getVirtualSize', () {
    late TransactionService transactionService;

    setUpAll(() async {
      await setup();
      transactionService = GetIt.instance<TransactionService>();
    });

    final testCases = [
      Case(
        addressType: "legacy",
        ins: 1,
        outs: 2,
        rawTransaction:
            '01000000012511d89764c4232506298da2229ed0a3e8559bfbd3936824fc35d5f66f577fb3010000001976a914a9055398b92818794b38b15794096f752167e25f88acffffffff02e8030000000000001600142388ceef5d82f48ba5c46ef6c7d75a97ace00e83b3090100000000001976a914a9055398b92818794b38b15794096f752167e25f88ac00000000',
        expectedVBytes: 1 * 148 + 2 * 34 + 10,
      ),
      Case(
        addressType: "legacy",
        ins: 5,
        outs: 1,
        rawTransaction:
            "01000000052511d89764c4232506298da2229ed0a3e8559bfbd3936824fc35d5f66f577fb3010000001976a914a9055398b92818794b38b15794096f752167e25f88acffffffffb026d89a64169f1ff61730478d71f1b7ffd2b0f98c577ad79f89bc7fbc3f516c010000001976a914a9055398b92818794b38b15794096f752167e25f88acffffffffec133cbf51356d60b15690734f0654053ab47e9334d23625b472d4249b66d678010000001976a914a9055398b92818794b38b15794096f752167e25f88acffffffffc3818dbe741192bd0389e0923f9b4265dcf64387a24c92bc88d6d3861a743f09010000001976a914a9055398b92818794b38b15794096f752167e25f88acffffffff542e35e1a95c277714cfaee8eaefae435a30ed91c3ead6fe0aaffa375a6162e6000000001976a914a9055398b92818794b38b15794096f752167e25f88acffffffff01ee150200000000001600142388ceef5d82f48ba5c46ef6c7d75a97ace00e8300000000",
        expectedVBytes: 5 * 148 + 1 * 34 + 10,
      ),
      Case(
        addressType: "segwit",
        ins: 1,
        outs: 2,
        rawTransaction:
            "02000000000101b546872a75b23a09fd314cc000257528045b6562efb8b9ccd0d9141948b23a52010000001600140d3c342fbaa82ee9b3c133e97e0ea2bdbf3b99c3ffffffff02e8030000000000001600142388ceef5d82f48ba5c46ef6c7d75a97ace00e83267c0000000000001600140d3c342fbaa82ee9b3c133e97e0ea2bdbf3b99c302000000000000",
        expectedVBytes: 137,
      ),
      Case(
        addressType: "segwit",
        ins: 1,
        outs: 1,
        rawTransaction:
            "02000000000101b546872a75b23a09fd314cc000257528045b6562efb8b9ccd0d9141948b23a52010000001600140d3c342fbaa82ee9b3c133e97e0ea2bdbf3b99c3ffffffff0106960000000000001600142388ceef5d82f48ba5c46ef6c7d75a97ace00e8302000000000000",
        expectedVBytes: 106,
      ),
    ];

    for (var i = 0; i < testCases.length; i++) {
      final testCase = testCases[i];
      testWidgets(
          'getVirtualSize - ${testCase.addressType} (${testCase.ins} in, ${testCase.outs} out)',
          (WidgetTester tester) async {
        await tester.pumpWidget(MyApp());

        final virtualSize =
            transactionService.getVirtualSize(testCase.rawTransaction);

        expect(virtualSize, equals(testCase.expectedVBytes),
            reason:
                'Failed for ${testCase.addressType} transaction with ${testCase.ins} input(s) and ${testCase.outs} output(s)');

        await tester.pumpAndSettle();
      });
    }
  });
}
