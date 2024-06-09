here’s an extra step

so first: run
flutter pub get

then run:

flutter pub run build_runner build

then do:

flutter run -d Chrome



# horizon

A bip39 wallet for XCP and bitcoin. Compatible with Freewallet and Counterwallet.

## Getting Started

To run locally:

1. Install dependencies:
`flutter pub get`

2. Add a .env file to the root of the application which includes:
```
TESTNET_URL=https://api.counterparty.io:14000
MAINNET_URL=https://api.counterparty.io:4000
```

3. Run the application

    - To run the application as a web app:
    `flutter build web --web-renderer html --csp`

    - To run the application as a chrome extension:
        a. build the application
        `flutter run -d Chrome`

        b. open your Chrome browser and navigate to chrome://extensions

        c. enable Developer mode on the top right corner of the extensions page

        d. click the "Load unpacked" button

        e.  Select the `<flutter_project_dir>/build/web` folder.

    - To use a Chrome substitute (such as Chromium), export the following from your shell env:
    `export CHROME_EXECUTABLE=$(which chromium)`