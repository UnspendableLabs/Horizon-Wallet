import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';

/// Every compose method of [V2Api], invoked with every positional slot
/// filled with a non-null value, so that any query parameter the method can
/// emit is actually emitted.
///
/// [allowsUnconfirmed] is the value passed to the `allowUnconfirmedInputs`
/// slot, or null when the method has no such slot.
class _ComposeCall {
  const _ComposeCall(this.name, this.call, {this.allowsUnconfirmed});

  final String name;
  final Future<Object?> Function(V2Api api) call;
  final bool? allowsUnconfirmed;
}

const _address = 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
const _inputs = 'aa:0,bb:1';

List<_ComposeCall> _composeCalls(bool allowed) => [
      _ComposeCall(
        'composeSend',
        (api) =>
            api.composeSend(_address, _address, 'XCP', 1, allowed, 2, true),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeSendVerbose',
        (api) => api.composeSendVerbose(_address, _address, 'XCP', 1, allowed,
            2, _inputs, true, false, true),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeMpmaSend',
        (api) => api.composeMpmaSend(
            _address, _address, 'XCP', '1', allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeIssuance',
        (api) => api.composeIssuance(_address, 'ASSET', 1, _address, true,
            false, false, 'd', allowed, true),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeIssuanceVerbose',
        (api) => api.composeIssuanceVerbose(_address, 'ASSET', 1, _address,
            true, false, false, 'd', allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeFairmintVerbose',
        (api) => api.composeFairmintVerbose(
            _address, 'ASSET', 1, 2, _inputs, true, false),
      ),
      _ComposeCall(
        'composeFairminterVerbose',
        (api) => api.composeFairminterVerbose(_address, 'ASSET', 'PARENT', true,
            1, 2, 3, 4, 2, false, _inputs, true, false),
      ),
      _ComposeCall(
        'composeDispenserVerbose',
        (api) => api.composeDispenserVerbose(_address, 'ASSET', 1, 2, 3, 0,
            _address, _address, allowed, 5, 2, _inputs, true, false, true),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeOrder',
        (api) => api.composeOrder(_address, 'XCP', 1, 'ASSET', 2, 100, 0,
            allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeCancel',
        (api) => api.composeCancel(
            _address, 'hash', allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeDispense',
        (api) => api.composeDispense(
            _address, _address, 1, allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeAttachUtxo',
        (api) => api.composeAttachUtxo(
            _address, 'ASSET', 1, '0', false, allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeDetachUtxo',
        (api) => api.composeDetachUtxo(
            'aa:0', _address, false, allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeMoveToUtxo',
        (api) => api.composeMoveToUtxo(
            'aa:0', _address, false, allowed, 2, _inputs, true, false),
        allowsUnconfirmed: allowed,
      ),
      _ComposeCall(
        'composeDestroy',
        (api) => api.composeDestroy(
            _address, 'ASSET', 1, 'tag', 2, _inputs, true, false),
      ),
      _ComposeCall(
        'composeDividend',
        (api) => api.composeDividend(
            _address, 'ASSET', 1, 'XCP', 2, _inputs, true, false),
      ),
      _ComposeCall(
        'composeSweep',
        (api) => api.composeSweep(
            _address, _address, 1, 'memo', 2, _inputs, true, false),
      ),
      _ComposeCall(
        'composeBurn',
        (api) => api.composeBurn(_address, 1, 2, _inputs, true, false),
      ),
    ];

/// Runs [call] against a [V2Api] whose transport is intercepted, and returns
/// the request that would have been sent.
Future<RequestOptions> _capture(
    Future<Object?> Function(V2Api api) call) async {
  RequestOptions? captured;
  final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid/v2'));
  addTearDown(dio.close);
  dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    captured = options;
    handler.reject(DioException(requestOptions: options, error: 'captured'));
  }));
  await expectLater(call(V2Api(dio)), throwsA(isA<DioException>()));
  return captured!;
}

void main() {
  group('compose requests never send the unrecognized `unconfirmed` key', () {
    for (final allowed in [false, true]) {
      for (final compose in _composeCalls(allowed)) {
        test('${compose.name} (allowUnconfirmedInputs=$allowed)', () async {
          final request = await _capture(compose.call);

          expect(request.path, contains('/compose/'));
          expect(request.queryParameters.containsKey('unconfirmed'), isFalse,
              reason: 'the Counterparty compose API rejects `unconfirmed`');
          expect(
            request.queryParameters['allow_unconfirmed_inputs'],
            compose.allowsUnconfirmed,
          );
        });
      }
    }
  });

  test('issuance forwards its parameters under their documented keys',
      () async {
    final request = await _capture((api) => api.composeIssuanceVerbose(
        _address,
        'ASSET',
        1,
        null,
        null,
        null,
        null,
        null,
        true,
        2,
        _inputs,
        true,
        false));

    expect(request.queryParameters, {
      'asset': 'ASSET',
      'quantity': 1,
      'allow_unconfirmed_inputs': true,
      'sat_per_vbyte': 2,
      'inputs_set': _inputs,
      'exclude_utxos_with_balances': true,
      'disable_utxo_locks': false,
    });
  });

  test('dispenser maps validate and disable_utxo_locks to their own slots',
      () async {
    final request = await _capture((api) => api.composeDispenserVerbose(
        _address,
        'ASSET',
        1,
        2,
        3,
        0,
        null,
        null,
        true,
        null,
        2,
        _inputs,
        true,
        false,
        true));

    expect(request.queryParameters['allow_unconfirmed_inputs'], true);
    expect(request.queryParameters['validate'], false);
    expect(request.queryParameters['disable_utxo_locks'], true);
  });
}
