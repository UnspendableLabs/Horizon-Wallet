abstract class ECPairService<T, N> {
  T fromWIF(String wif, N network);
  N get testnet;
  N get mainnet;
}
