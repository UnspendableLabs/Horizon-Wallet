import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_mnemonic_word_list.dart';
import 'package:uniparty/models/wallet_types.dart';

const invalidLengthError = 'seed phrase contains the wrong number of letters';
const invalidWordsError = 'some words are not in the word list';
const invalidNullPhrase = 'seed phrase may not be null';

String? validateSeedPhrase(String? seedValue, String recoveryWallet) {
  if (seedValue == null) {
    throw ArgumentError(invalidNullPhrase);
  }
  try {
    if (recoveryWallet == FREEWALLET || recoveryWallet == UNIPARTY) {
      /*
        bip39 mnemonicToEntropy will throw if
        1. a word is xnot in the word list
        2. there is a wrong number of words
        3. entropy is invalid
        3. the checksum fails
      */
      Bip39().mnemonicToEntropy(seedValue);
    } else if (recoveryWallet == COUNTERWALLET) {
      if (seedValue.split(" ").length != 12) {
        throw ArgumentError(invalidLengthError);
      }
      for (var word in seedValue.split(" ")) {
        if (!legacyMnemonicWords.contains(word)) {
          throw ArgumentError(invalidWordsError);
        }
      }
    }
    return null;
  } catch (error) {
    if (error is ArgumentError) {
      // argument error is thrown by bip39 for invaled phrases
      return error.message;
    }
    if (error is StateError) {
      // state error is thrown by bip39 for invalid entropy or checksum fails
      return error.message;
    }
    rethrow;
  }
}
