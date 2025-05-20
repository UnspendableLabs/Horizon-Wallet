import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/asset_balance_list_item.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class TokenSelectionForm extends StatefulWidget {
  const TokenSelectionForm({super.key});

  @override
  State<TokenSelectionForm> createState() => _TokenSelectionFormState();
}

class _TokenSelectionFormState extends State<TokenSelectionForm> {
  MultiAddressBalance? _fromToken;
  MultiAddressBalance? _toToken;
  final List<MultiAddressBalance> fakeTokens = [
    MultiAddressBalance(
        asset: 'XCP',
        assetLongname: '',
        totalNormalized: '10.0',
        total: 1000000000,
        entries: [
          MultiAddressBalanceEntry(
              address: 'fake_address_1',
              quantityNormalized: '10.0',
              quantity: 1000000000)
        ],
        assetInfo: const AssetInfo(
          assetLongname: '',
          description: '',
          divisible: true,
          locked: false,
        )),
    MultiAddressBalance(
        asset: 'PEPEFAIR',
        assetLongname: '',
        totalNormalized: '50.0',
        total: 5000000000,
        entries: [],
        assetInfo: const AssetInfo(
          assetLongname: '',
          description:
              'https://jlbmoope6h7l77q57j6ij7az35ekslty4lzhqyxdv425pqqffira.arweave.net/SsLHOeTx_r_-Hfp8hPwZ30ipLnji8nhi468118IFKiI/PEPEF.json',
          divisible: true,
          locked: false,
        )),
    MultiAddressBalance(
        asset: 'A5882299801343205953',
        assetLongname: '',
        totalNormalized: '111.0',
        total: 111,
        entries: [],
        assetInfo: const AssetInfo(
          assetLongname: '',
          description:
              'ipfs:bafkreiguw7dnweya2bpzk4e7373445vs32uh2ngupkfeikicgqs7jie33q',
          divisible: false,
          locked: false,
        )),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            "Swap",
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    HorizonRedesignDropdown<MultiAddressBalance>(
                        itemPadding: const EdgeInsets.all(12),
                        items: fakeTokens
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: AssetBalanceListItem(balance: e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value == _toToken) return;
                            _fromToken = value;
                          });
                        },
                        selectedValue: _fromToken,
                        selectedItemBuilder: (MultiAddressBalance item) =>
                            AssetBalanceListItem(balance: item),
                        hintText: "Select Token"),
                    commonHeightSizedBox,
                    HorizonRedesignDropdown<MultiAddressBalance>(
                        itemPadding: const EdgeInsets.all(12),
                        items: fakeTokens
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: AssetBalanceListItem(balance: e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value == _fromToken) return;
                            _toToken = value;
                          });
                        },
                        selectedValue: _toToken,
                        selectedItemBuilder: (MultiAddressBalance item) =>
                            AssetBalanceListItem(balance: item),
                        hintText: "Select Token")
                  ],
                ),
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Material(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          hoverColor: transparentPurple8,
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              if (_fromToken == null || _toToken == null) {
                                return;
                              }
                              final temp = _fromToken;
                              _fromToken = _toToken;
                              _toToken = temp;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: transparentWhite8, width: 1),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: AppIcons.arrowDownIcon(
                                context: context, width: 24, height: 24),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          HorizonButton(
              onPressed: () {},
              child: TextButtonContent(value: "Create Listing"),
              variant: ButtonVariant.green)
        ],
      ),
    );
  }
}
