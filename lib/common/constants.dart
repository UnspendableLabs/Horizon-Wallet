// ignore_for_file: constant_identifier_names

enum RecoveryWalletEnum { counterwallet, freewallet, uniparty }

enum WalletTypeEnum { bip44, bip32 }

enum NetworkEnum { mainnet, testnet }

enum AssetEnum { BTC, XCP }

const String STORED_WALLET_DATA_KEY = 'stored_wallet_data';

const String MAINNET_WALLET_NODES_KEY = 'mainnet_wallet_nodes_key';
const String ACTIVE_MAINNET_WALLET_KEY = 'active_mainnet_wallet_key';

const String ACTIVE_TESTNET_WALLET_KEY = 'active_testnet_wallet_key';
const String TESTNET_WALLET_NODES_KEY = 'testnet_wallet_nodes_key';
