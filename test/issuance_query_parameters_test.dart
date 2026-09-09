import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';

void main() {
  for (final verbose in [false, true]) {
    for (final allowed in [false, true]) {
      test('issuance verbose=$verbose allows unconfirmed inputs=$allowed',
          () async {
        RequestOptions? captured;
        final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid/v2'));
        dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
          captured = options;
          handler
              .reject(DioException(requestOptions: options, error: 'captured'));
        }));
        final api = V2Api(dio);
        final call = verbose
            ? api.composeIssuanceVerbose(
                'address', 'ASSET', 1, null, null, null, null, null, allowed)
            : api.composeIssuance(
                'address', 'ASSET', 1, null, null, null, null, null, allowed);
        await expectLater(call, throwsA(isA<DioException>()));
        expect(captured!.queryParameters['allow_unconfirmed_inputs'], allowed);
        expect(captured!.queryParameters.containsKey('unconfirmed'), isFalse);
        expect(captured!.queryParameters['asset'], 'ASSET');
        dio.close();
      });
    }
  }
}
