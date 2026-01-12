const String kHorizonMarketReferralParam = "ref";
const String kHorizonMarketReferralValueWallet = "HorizonWallet";

bool _isHttpOrHttps(Uri uri) => uri.scheme == "http" || uri.scheme == "https";

Uri withWalletReferral(Uri uri) {
  if (!_isHttpOrHttps(uri)) return uri;

  if (uri.queryParameters.containsKey(kHorizonMarketReferralParam)) {
    return uri;
  }

  final updatedParams = <String, String>{
    ...uri.queryParameters,
    kHorizonMarketReferralParam: kHorizonMarketReferralValueWallet,
  };

  return uri.replace(queryParameters: updatedParams);
}
