@JS("bip39")
library;

import 'dart:js_interop';

@JS()
external JSUint8Array mnemonicToSeedSync(String mnemonic,
    [String? password]);

@JS()
external JSPromise<JSUint8Array> mnemonicToSeed(String mnemonic,
    [String? password]);

@JS()
external String mnemonicToEntropy(
    String mnemonic, [ JSArray<JSString>? wordlist ]);

@JS()
external String entropyToMnemonic(
    JSUint8Array entropy, JSArray<JSString>? wordlist);

@JS()
external String generateMnemonic(
    [int? strength, JSFunction? rng, JSArray<JSString>? wordlist]);


@JS()
external bool validateMnemonic(
    String mnemonic, [ JSArray<JSString>? wordlist ]);


