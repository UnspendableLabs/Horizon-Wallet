class Balance {
  final String address;
  final String asset;
  final int quantity;

  const Balance({
    required this.address,
    required this.asset,
    required this.quantity,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'address': String address,
        'asset': String asset,
        'quanity': int quantity,
      } =>
        Balance(
          address: address,
          asset: asset,
          quantity: quantity,
        ),
      _ => throw const FormatException('Failed to load balance object.'),
    };
  }
}
