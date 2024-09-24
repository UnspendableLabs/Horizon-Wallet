sealed class FeeOption {
  String get label;

  @override
  String toString() => switch (this) {
        Fast() => 'Fast()',
        Medium() => 'Medium()',
        Slow() => 'Slow()',
        Custom(fee: var fee) => 'Custom(fee: $fee)',
      };

  String toInputValue() => switch (this) {
        Fast() => 'fast',
        Medium() => 'medium',
        Slow() => 'slow',
        Custom() => 'custom',
      };

  static FeeOption fromString(String value, {int? customFee}) =>
      switch (value) {
        'fast' => Fast(),
        'medium' => Medium(),
        'slow' => Slow(),
        'custom' => Custom(customFee ?? 0),
        _ => Medium(),
      };
}

class Fast extends FeeOption {
  @override
  String get label => 'Fast';
}

class Medium extends FeeOption {
  @override
  String get label => 'Medium';
}

class Slow extends FeeOption {
  @override
  String get label => 'Slow';
}

class Custom extends FeeOption {
  final int fee;
  Custom(this.fee);

  @override
  String get label => 'Custom';
}
