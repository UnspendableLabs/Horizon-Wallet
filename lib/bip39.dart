@JS("bip39")
library;

import 'dart:js_interop';

@JS()
external JSUint8Array mnemonicToSeedSync(JSString mnemonic, JSString? password);

@JS()
external JSPromise<JSUint8Array> mnemonicToSeed(
    JSString mnemonic, JSString? password);

@JS()
external JSString mnemonicToEntropy(
    JSString mnemonic, JSArray<JSString>? wordlist);

@JS()
external JSString entropyToMnemonic(
    JSUint8Array entropy, JSArray<JSString>? wordlist);

@JS()
external JSString generateMnemonic(
    JSNumber? strength, JSFunction? rng, JSArray<JSString>? wordlist);


