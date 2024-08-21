# horizon

A bip39 wallet for XCP and bitcoin. Supports importing from Freewallet and Counterwallet.

## Prerequisites

- Flutter SDK https://docs.flutter.dev/get-started/install
- Dart SDK https://dart.dev/get-dart
- Chrome or Chromium browser

## Getting Started

To run locally on the web:

1. Install dependencies:
   `flutter pub get`

2. Add a .env file to the root of the application which includes:

```
TEST=false
```

to run in testnet mode, set TEST=true

3. Much of the web app relies on code generation. To generate the necessary code, run:
   `flutter pub run build_runner build`

4. Run the app

   - To run the application as a web app

   ```
   flutter run -d Chrome --dart-define=NETWORK=<mainnet|testnet>
   ```

   - Run in regtest

   More details instructions [here](./regtest.md)


   ```
   flutter run -d Chrome --dart-define=REG_TEST_PK=<PK>  \
                         --dart-define=REG_TEST_PASSWORD=<PW> \
                         --dart-define=NETWORK=regtest
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

### notes

- esplora api only returns 50 txs in mempool with no addresses





| Network | Method | Format | Path | Address Type |
|---------|--------|--------|------|--------------|
| mainnet | onboarding_create | horizon | m/84'/0'/0'/0/0 | bech32 |
| testnet | onboarding_create | horizon | m/84'/1'/0'/0/0 | bech32 |
| mainnet | onboarding_import | horizon | m/84'/0'/0'/0/0 | bech32 |
| testnet | onboarding_import | horizon | m/84'/1'/0'/0/0 | bech32 |
| mainnet | onboarding_import | freewallet | m/32/0/0'/0/0-9 | bech32 |
| mainnet | onboarding_import | freewallet | m/32/0/0'/0/0-9 | legacy |
| testnet | onboarding_import | freewallet | m/32/1/0'/0/0-9 | bech32 |
| testnet | onboarding_import | freewallet | m/32/1/0'/0/0-9 | legacy |
| mainnet | onboarding_import | counterwallet | m/0'/0/0'/0/0 | legacy |
| testnet | onboarding_import | counterwallet | m/0'/1/0'/0/0 | legacy |







