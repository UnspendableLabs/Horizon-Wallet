class Balance {
  final String address;
  final String asset;
  final int quantity;

  const Balance({
    required this.address,
    required this.asset,
    required this.quantity,
  });

  factory Balance.fromJson(Map<String, dynamic> data) {
    final address = data['address'] as String;
    final asset = data['asset'] as String;
    final quantity = data['quantity'] as int;
    return Balance(address: address, asset: asset, quantity: quantity);
  }
}
