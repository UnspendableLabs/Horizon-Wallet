class WalletEntity {

  String uuid;
  String name;
  String wif; // TODO: obviously don't store WIF here

  WalletEntity({required this.uuid, required this.name, required this.wif});


}
