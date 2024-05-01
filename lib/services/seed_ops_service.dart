import 'package:get_it/get_it.dart';
import 'package:uniparty/bitcoin_wallet_utils/bip39.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_seed/legacy_mnemonic.dart';
import 'package:uniparty/bitcoin_wallet_utils/legacy_seed/legacy_mnemonic_word_list.dart';
import 'package:uniparty/common/constants.dart';

const invalidLengthError = 'seed phrase contains the wrong number of letters';
const invalidWordsError = 'some words are not in the word list';
const invalidNullPhrase = 'seed phrase may not be null';

class SeedOpsService {
  String? validateMnemonic(String? mnemonic, RecoveryWalletEnum recoveryWallet) {
    if (mnemonic == null) {
      throw ArgumentError(invalidNullPhrase);
    }
    try {
      switch (recoveryWallet) {
        case RecoveryWalletEnum.uniparty:
        case RecoveryWalletEnum.freewallet:
          /*
        bip39 mnemonicToEntropy will throw if
        1. a word is xnot in the word list
        2. there is a wrong number of words
        3. entropy is invalid
        3. the checksum fails
      */
          GetIt.I.get<Bip39Service>().mnemonicToEntropy(mnemonic);
          break;
        case RecoveryWalletEnum.counterwallet:
          if (mnemonic.split(" ").length != 12) {
            throw ArgumentError(invalidLengthError);
          }
          for (var word in mnemonic.split(" ")) {
            if (!legacyMnemonicWords.contains(word)) {
              throw ArgumentError(invalidWordsError);
            }
          }
          break;
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

  WalletTypeEnum getWalletType(RecoveryWalletEnum recoveryWallet) {
    switch (recoveryWallet) {
      case RecoveryWalletEnum.uniparty:
        return WalletTypeEnum.bip44;
      case RecoveryWalletEnum.freewallet:
      case RecoveryWalletEnum.counterwallet:
        return WalletTypeEnum.bip32;
      default:
        throw UnsupportedError('wallet $recoveryWallet not supported');
    }
  }

  Future<String> getSeedHex(String mnemonic, RecoveryWalletEnum recoveryWallet) async {
    // await Future.delayed(const Duration(milliseconds: 5)); // simulate async
    var bip39 = GetIt.I.get<Bip39Service>();
    switch (recoveryWallet) {
      case RecoveryWalletEnum.uniparty:
        return bip39.mnemonicToSeedHex(mnemonic);
      case RecoveryWalletEnum.freewallet:
        return bip39.mnemonicToEntropy(mnemonic);
      case RecoveryWalletEnum.counterwallet:
        return LegacyMnemonic().mnemonicToSeed(mnemonic);
      default:
        throw UnsupportedError('wallet $recoveryWallet not supported');
    }
  }
}
