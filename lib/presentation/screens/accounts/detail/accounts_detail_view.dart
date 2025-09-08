import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/account_configuration.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/address_v2_repository.dart';
import 'package:horizon/domain/repositories/account_v2_repository.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/repositories/account_configurations_repository.dart';

class HoverTile extends StatelessWidget {
  final bool selected;
  final VoidCallback? onTap;
  final Widget child;

  const HoverTile({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: selected ? cs.primary.withOpacity(0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // full-row hover highlight (no splash/highlight flashes)
        hoverColor: cs.primary.withOpacity(0.06),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: child,
      ),
    );
  }
}

class AccountAddressesTile extends StatelessWidget {
  final BitcoinRepository _bitcoinRepository;

  final String addressPath; // e.g. m/84'/0'/0'/0/12
  // final BigInt totalSats;            // total value across all addresses
  final String? p2pkhAddress; // null if not present
  final String? p2wpkhAddress; // null if not present
  final WalletConfig walletConfig;
  final VoidCallback? onTap;
  final Widget? leading;
  final void Function(String action)? onMenuAction; // 'copy', 'rename', etc.

  AccountAddressesTile({
    super.key,
    required this.addressPath,
    // required this.totalSats,
    required this.walletConfig,
    this.p2pkhAddress,
    this.p2wpkhAddress,
    this.onTap,
    this.leading,
    this.onMenuAction,
    BitcoinRepository? bitcoinRepository,
  }) : _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>();

  double get _height {
    final kinds = walletConfig.supportedKinds.length;
    // Tweak to taste. Gives a comfy height for 1 or 2 address rows.

    return kinds == 2 ? 126 : 104;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    // build rows for present kinds
    final rows = <Widget>[
      _InfoRow(
        label: 'Path',
        value: addressPath,
        valueStyle:
            const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
        // tooltip: addressPath,
      ),
      if (walletConfig.supportedKinds.contains(AddressV2Type.p2pkh))
        _InfoRow(
          label: 'P2PKH',
          value: p2pkhAddress ?? "",
          monospace: true,
          ellipsizeMiddle: true,
          copyable: false,
        ),
      if (walletConfig.supportedKinds.contains(AddressV2Type.p2wpkh))
        _InfoRow(
          label: 'P2WPKH',
          value: p2wpkhAddress ?? "",
          monospace: true,
          ellipsizeMiddle: true,
          copyable: false,
        ),
    ];

    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return SizedBox(
      height: _height,
      child: HoverTile(
        selected: addressPath.endsWith("0"),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              // content
              Expanded(
                child: DefaultTextStyle(
                  style: text.bodyMedium!,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: rows,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // kebab
              RemoteDataTaskEitherBuilder(
                  task: TaskEither<String, List<AddressInfo>>.Do(($) async {
                final addresses =
                    [p2pkhAddress, p2wpkhAddress].nonNulls.toList();

                return await $(_bitcoinRepository.getAddressInfoMultiT(
                    httpConfig: session.httpConfig,
                    addresses: addresses,
                    onError: (
                      e,
                    ) =>
                        "failed to fetch BTC balance"));
              }), builder: (context, state, refresh) {
                return state.fold3(
                    onNone: () => const SizedBox.shrink(),
                    onFailure: (_) => const SizedBox.shrink(),
                    onReplete: (addressInfoList) {
                      final total = addressInfoList.fold(0, (sum, info) {
                        final funded = info.chainStats.fundedTxoSum;
                        final spent = info.chainStats.spentTxoSum;
                        final quantity = funded - spent;
                        return sum + quantity;
                      });

                      return SatsToUsdDisplay(
                        key: ValueKey("sats_display_$addressPath"),
                        sats: BigInt.from(total),
                      );
                    });
              })
            ],
          ),
        ),
      ),
    );
  }

  String _formatSats(BigInt sats) {
    // Simple formatter; replace with your SatsToUsdDisplay if needed.
    return sats.toString();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool monospace;
  final bool copyable;
  final bool ellipsizeMiddle;
  final String? tooltip;

  const _InfoRow(
      {required this.label,
      required this.value,
      this.valueStyle,
      this.monospace = false,
      this.copyable = false,
      this.ellipsizeMiddle = false,
      this.tooltip});

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7),
        );

    Widget valueWidget = _MaybeEllipsizedText(
      value,
      monospace: monospace,
      style: valueStyle,
      ellipsizeMiddle: ellipsizeMiddle,
    );

    if (tooltip != null) {
      valueWidget = Tooltip(message: tooltip!, child: valueWidget);
    }

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: labelStyle),
        ),
        Expanded(child: valueWidget),
        if (copyable)
          IconButton(
            onPressed: () {}, // TODO: implement copy functionality
            tooltip: 'Copy',
            icon: const Icon(Icons.copy, size: 16),
            // onPressed: () => Clipboard.setData(ClipboardData(text: value)),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _MaybeEllipsizedText extends StatelessWidget {
  final String text;
  final bool monospace;
  final bool ellipsizeMiddle;
  final TextStyle? style;

  const _MaybeEllipsizedText(
    this.text, {
    this.monospace = false,
    this.ellipsizeMiddle = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final base = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (style ?? const TextStyle()).copyWith(
        fontFamily: monospace ? 'RobotoMono' : null,
      ),
    );

    if (!ellipsizeMiddle) return base;

    // Middle-ellipsis trick: split and show start…end
    final start = text.length <= 12 ? text : text.substring(0, 8);
    final end = text.length <= 12 ? '' : text.substring(text.length - 8);
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.clip,
      text: TextSpan(
        style: (style ?? DefaultTextStyle.of(context).style).copyWith(
          fontFamily: monospace ? 'RobotoMono' : null,
        ),
        children: [
          TextSpan(text: start),
          const TextSpan(text: '…'),
          TextSpan(text: end),
        ],
      ),
    );
  }
}

class Bip32AccountDetailView extends StatelessWidget {
  final Bip32 account;
  final AddressV2Repository _addressV2Repository;

  final WalletConfigRepository _walletConfigRepository;
  final AccountConfigurationsRepository _accountConfigurationsRepository;

  Bip32AccountDetailView({
    required this.account,
    AddressV2Repository? addressV2Repository,
    WalletConfigRepository? walletConfigRepository,
    AccountConfigurationsRepository? accountConfigurationsRepository,
    super.key,
  })  : _walletConfigRepository =
            walletConfigRepository ?? GetIt.I<WalletConfigRepository>(),
        _addressV2Repository =
            addressV2Repository ?? GetIt.I<AddressV2Repository>(),
        _accountConfigurationsRepository = accountConfigurationsRepository ??
            GetIt.I<AccountConfigurationsRepository>();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return ListView.builder(
      // TODO: should we enforce item count?
      // itemCount: 100,

      itemBuilder: (context, index) {
        final item = account;

        final addressPath =
            "${session.walletConfig.basePath.get(session.walletConfig.network)}${account.index}'/0/$index";

        print("adderss path in view $addressPath");
        return RemoteDataTaskEitherBuilder(
            task: _addressV2Repository.getByAccountAtIndexT(
                index: Bip32AddressIndex(index),
                account: item,
                onError: (e, __) => e.toString()),
            builder: (context, state, refresh) {
              return state.fold3(
                  onNone: () => AccountAddressesTile(
                      // key: ValueKey("none:$addressPath"),
                      //            p2pkhAddress:  maybeAddresses
                      // ?.firstWhereOrNull(
                      //  (address) => address.type == AddressV2Type.p2pkh)
                      // ?.address,
                      //            p2wpkhAddress:  maybeAddresses
                      // ?.firstWhereOrNull(
                      //  (address) => address.type == AddressV2Type.p2wpkh)
                      // ?.address,
                      addressPath: addressPath,
                      walletConfig: session.walletConfig),
                  // should never hit failure case
                  onFailure: (error) => AccountAddressesTile(
                      // key: ValueKey("failure:$addressPath"),
                      p2wpkhAddress: error.toString(),
                      addressPath: addressPath,
                      walletConfig: session.walletConfig),
                  onReplete: (addressIndexSet) {
                    final p2pkh =
                        addressIndexSet.getByType(AddressV2Type.p2pkh);

                    final p2wpkh =
                        addressIndexSet.getByType(AddressV2Type.p2wpkh);

                    onSuccess() {
                      context.read<SessionStateCubit>().refresh();

                      context.go("/accounts");
                    }

                    return AccountAddressesTile(
                        // key: ValueKey("replete:$addressPath"),
                        onTap: () async {
                          final task = TaskEither<Never, void>.Do(($) async {
                            await $(_accountConfigurationsRepository
                                .createOrUpdateT(
                                    config: AccountConfiguration(
                                        walletUUID: session.walletConfig.uuid,
                                        accountIndex: account.index,
                                        addressIndex: index),
                                    onError: (_, __) => throw ("invariant")));
                          });

                          await task.run();

                          onSuccess();
                        },
                        p2pkhAddress: p2pkh?.address,
                        p2wpkhAddress: p2wpkh?.address,
                        addressPath: addressPath,
                        walletConfig: session.walletConfig);
                  });
            });
      },
    );
  }
}

class ImportedWIFAccountDetailView extends StatelessWidget {
  final ImportedWIF account;

  const ImportedWIFAccountDetailView({required this.account, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Text(account.toString())],
    );
  }
}

class AccountDetailView extends StatelessWidget {
  final AccountV2 account;

  final BitcoinRepository _bitcoinRepository;

  final AddressV2Repository _addressV2Repository;
  final AccountV2Repository _accountV2Repository;

  AccountDetailView(
      {required this.account,
      BitcoinRepository? bitcoinRepository,
      AddressV2Repository? addressV2Repository,
      AccountV2Repository? accountV2Repository,
      super.key})
      : _addressV2Repository =
            addressV2Repository ?? GetIt.I<AddressV2Repository>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _accountV2Repository =
            accountV2Repository ?? GetIt.I<AccountV2Repository>();

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    final account = this.account;

    return switch (account) {
      ImportedWIF() => ImportedWIFAccountDetailView(account: account),
      Bip32() => Bip32AccountDetailView(account: account),
    };
  }
}
