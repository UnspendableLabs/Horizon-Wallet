import 'package:flutter/widgets.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/transactions/input_loading_scaffold.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class TokenNameField extends StatelessWidget {
  final MultiAddressBalance? balance;

  const TokenNameField({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    if (balance == null) {
      return const InputLoadingScaffold();
    }

    final tokenName = displayAssetName(balance!.asset, balance!.assetLongname);

    return HorizonTextField(
        label: 'Token',
        controller: TextEditingController(text: tokenName),
        enabled: false);
  }
}
