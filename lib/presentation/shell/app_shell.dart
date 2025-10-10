import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/extension_rpc.dart';
import 'package:horizon/domain/entities/psbt_type.dart';
import 'package:horizon/domain/repositories/action_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/version_cubit.dart';

class SignPsbtModal extends StatelessWidget {
  final int tabId;
  final String requestId;
  final String unsignedPsbt;
  final TransactionService transactionService;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final BitcoindService bitcoindService;
  final BalanceRepository balanceRepository;
  final RPCSignPsbtSuccessCallback onSuccess;
  final Map<String, List<int>> signInputs;
  final List<int>? sighashTypes;
  final BitcoinRepository bitcoinRepository;

  const SignPsbtModal(
      {super.key,
      required this.unsignedPsbt,
      required this.transactionService,
      required this.encryptionService,
      required this.addressService,
      required this.bitcoindService,
      required this.balanceRepository,
      required this.tabId,
      required this.requestId,
      required this.onSuccess,
      required this.signInputs,
      required this.sighashTypes,
      required this.bitcoinRepository});

  @override
  Widget build(BuildContext context) {
    final session = context.select<SessionStateCubit, SessionStateSuccess>(
      (cubit) => cubit.state.successOrThrow(),
    );
    return BlocProvider(
      create: (_) => SignPsbtBloc(
        addresses: session.addressIndexSet.list,
        psbtType: OpaquePsbt(),
        httpConfig: session.httpConfig,
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
        signInputs: signInputs,
        sighashTypes: sighashTypes,
        unsignedPsbt: unsignedPsbt,
        transactionService: transactionService,
        bitcoindService: bitcoindService,
        encryptionService: encryptionService,
        addressService: addressService,
      ),
      child: SignPsbtForm(
        psbtType: OpaquePsbt(),
        key: Key(unsignedPsbt),
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        onSuccess: (signedPsbtHex) {
          onSuccess(RPCSignPsbtSuccessCallbackArgs(
              tabId: tabId, requestId: requestId, signedPsbt: signedPsbtHex));
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final ActionRepository actionRepository;
  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.actionRepository,
  });

  // Method to navigate to tabs from outside

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  final ActionRepository actionRepository = GetIt.instance<ActionRepository>();

  @override
  void initState() {
    super.initState();

    // final action = widget.actionRepository.peek();
    // action.fold(noop, (action) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _getHandler(action)();
    //   });
    // });
  }

  @override
  void didUpdateWidget(AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).dialogTheme.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width > 500 ? 500 : double.infinity,
          ),
          child: VersionWarningSnackbar(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class VersionWarningSnackbar extends StatefulWidget {
  final Widget child;

  const VersionWarningSnackbar({required this.child, super.key});

  @override
  VersionWarningState createState() => VersionWarningState();
}

class VersionWarningState extends State<VersionWarningSnackbar> {
  bool _hasShownSnackbar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final versionInfo = context
        .read<VersionCubit>()
        .state; // we should only ever get to this page if session is success

    if (!_hasShownSnackbar && versionInfo.warning != null) {
      switch (versionInfo.warning!) {
        case NewVersionAvailable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
        case VersionServiceUnreachable():
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                'Version service unreachable.  Horizon Wallet may be out of date. Your version is ${versionInfo.current} ',
              )),
            );
            _hasShownSnackbar = true;
          });
          break;
      }
    }

    if (!_hasShownSnackbar && versionInfo.current < versionInfo.latest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'There is a new version of Horizon Wallet: ${versionInfo.latest}.  Your version is ${versionInfo.current} ',
          )),
        );
        _hasShownSnackbar = true;
      });
    }
  }

  @override
  Widget build(context) => widget.child;
}
