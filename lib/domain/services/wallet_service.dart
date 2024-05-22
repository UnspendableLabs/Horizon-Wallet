
import 'package:uniparty/domain/entities/wallet.dart';

// TODO: define mnemonic type
abstract class WalletService {
  Future<Wallet> deriveRoot(String mnemonic);
  Future<Wallet> deriveRootFreewallet(String mnemonic);
}
