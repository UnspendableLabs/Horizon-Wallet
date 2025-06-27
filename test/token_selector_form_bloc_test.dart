import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/screens/send/bloc/token_selector_form_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:formz/formz.dart';

void main() {
  group('TokenSelectorFormBloc', () {
    late TokenSelectorFormBloc bloc;
    late List<MultiAddressBalance> mockBalances;

    setUp(() {
      mockBalances = [
        MultiAddressBalance(
          asset: 'PEPECASH',
          assetLongname: '',
          total: 100000000,
          totalNormalized: '1.00000000',
          entries: [
            MultiAddressBalanceEntry(
              address: 'address1',
              quantity: 100000000,
              quantityNormalized: '1.00000000',
              utxo: null,
              utxoAddress: null,
            ),
          ],
          assetInfo: const AssetInfo(
            assetLongname: '',
            description: '',
            divisible: true,
            owner: null,
            locked: false,
          ),
        ),
        MultiAddressBalance(
          asset: 'XCP',
          assetLongname: '',
          total: 50000000,
          totalNormalized: '0.50000000',
          entries: [
            MultiAddressBalanceEntry(
              address: 'address1',
              quantity: 50000000,
              quantityNormalized: '0.50000000',
              utxo: null,
              utxoAddress: null,
            ),
          ],
          assetInfo: const AssetInfo(
            assetLongname: '',
            description: '',
            divisible: true,
            owner: null,
            locked: false,
          ),
        ),
      ];

      bloc = TokenSelectorFormBloc(initialBalances: mockBalances);
    });

    // tearDown(() {
    //   bloc.close();
    // });

    test('initial state is correct', () {
      expect(bloc.state.balances.length, equals(2));
      expect(bloc.state.tokenSelectorInput.isPure, isTrue);
      expect(bloc.state.tokenSelectorInput.value, isNull);
      expect(bloc.state.submissionStatus, equals(FormzSubmissionStatus.initial));
      expect(bloc.state.disabled, isTrue);
    });

    test('TokenSelected event updates state correctly', () async {
      final option = TokenSelectorOption(
        name: 'PEPECASH',
        description: '',
        balance: Option.of(mockBalances[0]),
      );

      bloc.add(TokenSelected(option));
      
      await Future.delayed(Duration.zero);

      expect(bloc.state.tokenSelectorInput.value, equals(option));
      expect(bloc.state.disabled, isFalse);
    });

    test('SubmitClicked event with no selection does not change submission status', () {
      bloc.add(SubmitClicked());
      
      expect(bloc.state.submissionStatus, equals(FormzSubmissionStatus.initial));
    });

    test('SubmitClicked event with selection updates submission status', () async {
      final option = TokenSelectorOption(
        name: 'PEPECASH',
        description: '',
        balance: Option.of(mockBalances[0]),
      );

      bloc.add(TokenSelected(option));
      bloc.add(SubmitClicked());

      await Future.delayed(Duration.zero);

      expect(bloc.state.submissionStatus, equals(FormzSubmissionStatus.success));
    });

    test('TokenSelectorInput validation works correctly', () {
      final input = TokenSelectorInput.pure();
      expect(input.error, equals(TokenSelectorInputError.required));

      final option = TokenSelectorOption(
        name: 'PEPECASH',
        description: '',
        balance: Option.of(mockBalances[0]),
      );
      final dirtyInput = TokenSelectorInput.dirty(value: option);
      expect(dirtyInput.error, isNull);
    });

    test('TokenSelectorOption copyWith works correctly', () {
      final original = TokenSelectorOption(
        name: 'PEPECASH',
        description: '',
        balance: Option.of(mockBalances[0]),
      );

      final updated = original.copyWith(
        name: 'XCP',
        description: 'counterparty',
        balance: Option.of(mockBalances[1]),
      );
      expect(updated.name, equals('XCP'));
      expect(updated.description, equals('counterparty'));
      expect(updated.balance, equals(Option.of(mockBalances[1])));
    });
  });
}
