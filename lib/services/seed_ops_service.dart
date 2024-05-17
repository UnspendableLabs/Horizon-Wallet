import 'package:get_it/get_it.dart';
import 'package:uniparty/services/bip39.dart' as bip39;
import 'package:uniparty/bitcoin_wallet_utils/legacy_seed/legacy_mnemonic_word_list.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/seed.dart';

const invalidLengthError = 'seed phrase contains the wrong number of letters';
const invalidWordsError = 'some words are not in the word list';
const invalidNullPhrase = 'seed phrase may not be null';

class SeedOpsService {
  String? validateMnemonic(
      String? mnemonic, WalletType recoveryWallet) {
    if (mnemonic == null) {
      throw ArgumentError(invalidNullPhrase);
    }
    try {
      switch (recoveryWallet) {
        case WalletType.uniparty:
        case WalletType.freewallet:
          /*
        bip39 mnemonicToEntropy will throw if
        1. a word is xnot in the word list
        2. there is a wrong number of words
        3. entropy is invalid
        3. the checksum fails
      */
          GetIt.I.get<bip39.Bip39Service>().mnemonicToEntropy(mnemonic);
          break;
        case WalletType.counterwallet:
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

  // WalletTypeEnum getWalletType(WalletType recoveryWallet) {
  //   switch (recoveryWallet) {
  //     case WalletType.uniparty:
  //       return WalletTypeEnum.bip44;
  //     case WalletType.freewallet:
  //     case WalletType.counterwallet:
  //       return WalletTypeEnum.bip32;
  //     default:
  //       throw UnsupportedError('wallet $recoveryWallet not supported');
  //   }
  // }

  Future<Seed> getSeed(
      String mnemonic, WalletType recoveryWallet) async {
    // await Future.delayed(const Duration(milliseconds: 5)); // simulate async

    var bip39Service = GetIt.I.get<bip39.Bip39Service>();
    switch (recoveryWallet) {
      case WalletType.uniparty:
        return bip39Service.mnemonicToSeed(mnemonic);
      case WalletType.freewallet:
        return Seed.fromHex(bip39Service.mnemonicToEntropy(mnemonic));
      case WalletType.counterwallet:
        throw UnsupportedError('Not Implemented');
      default:
        throw UnsupportedError('wallet $recoveryWallet not supported');
    }
  }
}
