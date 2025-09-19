import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/address_info.dart';
import 'package:horizon/domain/entities/account_v2.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/account_configuration.dart';
import 'package:get_it/get_it.dart';
import 'package:fpdart/fpdart.dart' hide State;
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

class AccountAddressesTile extends StatefulWidget {
  final String addressPath; // e.g. m/84'/0'/0'/0/12
  final String? p2pkhAddress;
  final String? p2wpkhAddress;
  final WalletConfig walletConfig;
  final VoidCallback? onTap;
  final Widget? leading;
  final void Function(String action)? onMenuAction;
  final BitcoinRepository? bitcoinRepository;
  final bool isCurrent;

  const AccountAddressesTile({
    super.key,
    required this.addressPath,
    required this.walletConfig,
    this.p2pkhAddress,
    this.p2wpkhAddress,
    this.onTap,
    this.leading,
    this.onMenuAction,
    this.bitcoinRepository,
    this.isCurrent = false,
  });

  @override
  State<AccountAddressesTile> createState() => _AccountAddressesTileState();
}

class _AccountAddressesTileState extends State<AccountAddressesTile>
    with AutomaticKeepAliveClientMixin {
  late final BitcoinRepository _bitcoinRepository =
      widget.bitcoinRepository ?? GetIt.I<BitcoinRepository>();

  // Cache the task so it isn't recreated on every build:
  late final TaskEither<String, List<AddressInfo>> _addressInfoTask;

  double get _height {
    final kinds = widget.walletConfig.supportedKinds.length;
    return kinds == 2 ? 126 : 104;
  }

  @override
  void initState() {
    super.initState();

    // Build once:
    final addresses = [widget.p2pkhAddress, widget.p2wpkhAddress]
        .whereType<String>()
        .toList();

    // If there’s nothing to fetch, keep a completed task:
    _addressInfoTask = addresses.isEmpty
        ? TaskEither.right(<AddressInfo>[])
        : _bitcoinRepository.getAddressInfoMultiT(
            httpConfig: context
                .read<SessionStateCubit>()
                .state
                .successOrThrow()
                .httpConfig,
            addresses: addresses,
            onError: (e) => "failed to fetch BTC balance",
          );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final text = theme.textTheme;

    final rows = <Widget>[
      _InfoRow(
        label: 'Path',
        value: widget.addressPath,
        valueStyle:
            const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      ),
      if (widget.walletConfig.supportedKinds.contains(AddressV2Type.p2pkh))
        _InfoRow(
          label: 'P2PKH',
          value: widget.p2pkhAddress ?? "",
          monospace: true,
          ellipsizeMiddle: true,
          copyable: false,
        ),
      if (widget.walletConfig.supportedKinds.contains(AddressV2Type.p2wpkh))
        _InfoRow(
          label: 'P2WPKH',
          value: widget.p2wpkhAddress ?? "",
          monospace: true,
          ellipsizeMiddle: true,
          copyable: false,
        ),
    ];

    return SizedBox(
      height: _height,
      child: RepaintBoundary(
        child: HoverTile(
          selected: widget.isCurrent,
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 12),
                    ],
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
                    // Uses cached task; will NOT recreate on rebuilds:
                    RemoteDataTaskEitherBuilder(
                      task: _addressInfoTask,
                      builder: (context, state, refresh) {
                        return state.fold3(
                          onNone: () => const SizedBox.shrink(),
                          onFailure: (_) => const SizedBox.shrink(),
                          onReplete: (list) {
                            final total = list.fold<int>(0, (sum, info) {
                              final funded = info.chainStats.fundedTxoSum;
                              final spent = info.chainStats.spentTxoSum;
                              return sum + (funded - spent);
                            });
                            return SatsToUsdDisplay(
                              key: ValueKey(
                                  "sats_display_${widget.addressPath}"),
                              sats: BigInt.from(total),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                if (widget.isCurrent)
                  Positioned(
                    top: 4,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Current',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Keep items alive when scrolled off-screen so they don’t refetch:
  @override
  bool get wantKeepAlive => true;
}

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
        hoverColor: cs.primary.withOpacity(0.06),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: child,
      ),
    );
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
    // Only one watch here:
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final currentAddrs =
        session.addressIndexSet.list.map((a) => a.address).toSet();

    return ListView.builder(
      itemCount: 1000,
      addAutomaticKeepAlives: true, // works with the mixin in item
      addRepaintBoundaries: true,
      // If all rows have same height, set itemExtent. If not, consider prototypeItem:
      prototypeItem: AccountAddressesTile(
        addressPath:
            "${session.walletConfig.basePath.get(session.walletConfig.network)}${account.index}'/0/0",
        walletConfig: session.walletConfig,
        isCurrent: false,
      ),
      itemBuilder: (context, index) {
        final addressPath =
            "${session.walletConfig.basePath.get(session.walletConfig.network)}${account.index}'/0/$index";

        // Don’t fetch here—only ask for the derived addresses
        return RemoteDataTaskEitherBuilder(
          key: Key("address_tile_$addressPath"),
          task: _addressV2Repository.getByAccountAtIndexT(
            index: Bip32AddressIndex(index),
            account: account,
            onError: (e, __) => e.toString(),
          ),
          builder: (context, state, refresh) {
            return state.fold3(
              onNone: () => AccountAddressesTile(
                addressPath: addressPath,
                walletConfig: session.walletConfig,
                isCurrent: false,
              ),
              onFailure: (error) => AccountAddressesTile(
                addressPath: addressPath,
                walletConfig: session.walletConfig,
                // Show something benign; don’t block the list
                p2wpkhAddress: null,
                isCurrent: false,
              ),
              onReplete: (set) {
                final p2pkh = set.getByType(AddressV2Type.p2pkh)?.address;
                final p2wpkh = set.getByType(AddressV2Type.p2wpkh)?.address;
                final isCurrent = [p2pkh, p2wpkh]
                    .whereType<String>()
                    .any(currentAddrs.contains);

                Future<void> onTap() async {
                  final task = TaskEither<Never, void>.Do(($) async {
                    await $(_accountConfigurationsRepository.createOrUpdateT(
                      config: AccountConfiguration(
                        walletUUID: session.walletConfig.uuid,
                        accountIndex: account.index,
                        addressIndex: index,
                      ),
                      onError: (_, __) => throw ("invariant"),
                    ));
                  });
                  await task.run();
                  context.read<SessionStateCubit>().refresh();
                  context.go("/accounts");
                }

                return AccountAddressesTile(
                  onTap: onTap,
                  p2pkhAddress: p2pkh,
                  p2wpkhAddress: p2wpkh,
                  addressPath: addressPath,
                  walletConfig: session.walletConfig,
                  isCurrent: isCurrent, // ← passed down
                );
              },
            );
          },
        );
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
