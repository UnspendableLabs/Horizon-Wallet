# horizon

A wallet for XCP and bitcoin. Supports loading seed phrases from Freewallet and Counterwallet.

## Prerequisites

- Flutter SDK https://docs.flutter.dev/get-started/install
- Dart SDK https://dart.dev/get-dart
- Chrome or Chromium browser

## Releasing fixes to extension users

A merged PR or a successful Vercel deployment does **not** publish a Chrome
extension update. Track review, build, store submission and published version
separately in the release PR.

Before publishing:

1. Choose the reviewed commit and record its SHA. Keep `pubspec.yaml` and
   `web/manifest.json` release versions aligned and newer than the store version.
2. Run tests and build from a clean checkout with the agreed Flutter SDK and
   locked dependencies. Do not silently ship dependency changes from a local
   SDK workaround.
3. Use `dart run tool/build_extension.dart` for the Chromium release build.
   Explicitly set the intended production Sentry configuration and provide
   source-map upload credentials securely. Verify the upload actually succeeded:
   the build script can otherwise skip it with a warning. Never put credentials
   in the release notes or artifact.
4. Load the exact `build/web` artifact in a clean browser profile with a test
   wallet. Exercise import, account switching, balances and connection to Market.
   Check error reporting against the matching release. Do not use customer keys.
5. Verify source maps are absent from the distributed artifact. Record the
   artifact checksum; the authorized publisher submits that same artifact.
6. After store approval, install/update from the store and verify its displayed
   version and critical flows. Record the published version and time. Compare
   Sentry events by release; errors from an older installed version are not proof
   that the new release regressed.

Do not mark a user-facing extension fix deployed until step 6 is verified.

## Getting Started

To run locally on the web:

1. Install dependencies:
   `flutter pub get`

2. Much of the web app relies on code generation. To generate the necessary code, run:
   `flutter pub run build_runner build`

3. Run the app

   - To run the application as a web app

   ```
   flutter run -d Chrome --dart-define=HORIZON_NETWORK=<mainnet|testnet>
   ```

   - Run in regtest

   More details instructions [here](./regtest.md)

   ```
   flutter run -d Chrome --dart-define=REG_TEST_PK=<PK>  \
                         --dart-define=REG_TEST_PASSWORD=<PW> \
                         --dart-define=HORIZON_NETWORK=regtest
   ```

   - To run the application as a chrome extension:
     a. build the application
     `flutter build web --web-renderer html --csp`

     b. open your Chrome browser and navigate to chrome://extensions

     c. enable Developer mode on the top right corner of the extensions page

     d. click the "Load unpacked" button

     e. Select the `<flutter_project_dir>/build/web` folder.

   - To use a Chrome substitute (such as Chromium), export the following from your shell env:
     `export CHROME_EXECUTABLE=$(which chromium)`

### gen drift schema

❯ dart run drift_dev schema dump lib/data/sources/local/db.dart drift_schemas/

### derive migration step fn

❯ dart run drift_dev schema steps drift_schemas/ lib/data/sources/local/schema_versions.dart

### gen migration tests

❯ dart run drift_dev schema generate drift_schemas/ test/drift_migrations

### notes

- esplora api only returns 50 txs in mempool with no addresses

### derivation paths

| Network          | Method            | Format        | Path                                   | Address Type         |
| ---------------- | ----------------- | ------------- | -------------------------------------- | -------------------- |
| mainnet          | onboarding_create | horizon       | m/84'/0'/0'/0/0                        | 1 bech32             |
| testnet          | onboarding_create | horizon       | m/84'/1'/0'/0/0                        | 1 bech32             |
| mainnet          | onboarding_import | horizon       | m/84'/0'/0'/0/0                        | 1 bech32             |
| testnet          | onboarding_import | horizon       | m/84'/1'/0'/0/0                        | 1 bech32             |
| mainnet, testnet | onboarding_import | freewallet    | m/0'/0/0-9                             | 10 bech32, 10 legacy |
| mainnet, testnet | onboarding_import | counterwallet | m/0'/0/0                               | 1 legacy             |
| mainnet          | add_account       | horizon       | m/84'/0'/1'/0/0 ( max_account_idx + 1) | 1 bech32             |
| testnet          | add_account       | horizon       | m/84'/1'/1'/0/0 ( max_account_idx + 1) | 1 bech32             |
| mainnet, testnet | add_account       | freewallet    | m/1'/0/0-9 ( max_segment_0 + 1)        | 10 bech32, 10 legacy |
| mainnet, testnet | add_account       | counterwallet | m/1'/0/0 ( max_segment_0 + 1)          | 1 legacy             |

#### sources

- https://github.com/CounterpartyXCP/counterwallet/blob/1de386782818aeecd7c23a3d2132746a2f56e4fc/src/js/util.bitcore.js#L17

### unit tests

- run with `flutter test` or `flutter test test/target_file.dart`

#### integration_test

1. set up your env

https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser

2. run tests ( defaults to mainnet )

```
# Mainnet
flutter drive   --driver=test_driver/integration_test.dart   --target=integration_test/app_test.dart   -d chrome

# Testnet
flutter drive   --driver=test_driver/integration_test.dart   --target=integration_test/app_test.dart   -d chrome --dart-define=HORIZON_NETWORK=testnet

```
