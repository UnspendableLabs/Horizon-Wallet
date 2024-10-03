import 'package:collection/collection.dart';
import 'package:horizon/common/constants.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_state.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_event.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/compose_send/view/asset_dropdown.dart';

class ComposeDispenserPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeDispenserPageWrapper({
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeDispenserBloc(
          bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          addressRepository: GetIt.I.get<AddressRepository>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          utxoRepository: GetIt.I.get<UtxoRepository>(),
          accountRepository: GetIt.I.get<AccountRepository>(),
          walletRepository: GetIt.I.get<WalletRepository>(),
          encryptionService: GetIt.I.get<EncryptionService>(),
          addressService: GetIt.I.get<AddressService>(),
          transactionService: GetIt.I.get<TransactionService>(),
          bitcoindService: GetIt.I.get<BitcoindService>(),
          transactionRepository: GetIt.I.get<TransactionRepository>(),
          transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
        )..add(FetchFormData(currentAddress: state.currentAddress)),
        child: ComposeDispenserPage(
          address: state.currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDispenserPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;

  const ComposeDispenserPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeDispenserPageState createState() => ComposeDispenserPageState();
}

class ComposeDispenserPageState extends State<ComposeDispenserPage> {
  TextEditingController giveQuantityController = TextEditingController();
  TextEditingController escrowQuantityController = TextEditingController();
  TextEditingController mainchainrateController = TextEditingController();
  TextEditingController openAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();

  String? asset;
  Balance? balance_;

  final balanceRepository = GetIt.I.get<BalanceRepository>();

  @override
  void initState() {
    super.initState();
    openAddressController.text = widget.address.address;
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<ComposeDispenserBloc, ComposeDispenserState>(
      address: widget.address,
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<ComposeDispenserBloc>().add(ChangeFeeOption(value: fee)),
      buildInitialFormFields: (state, loading, formKey) =>
          _buildInitialFormFields(state, loading, formKey),
      onInitialCancel: () => _handleInitialCancel(),
      onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
      buildConfirmationFormFields: (composeTransaction, formKey) =>
          _buildConfirmationDetails(composeTransaction),
      onConfirmationBack: () => _onConfirmationBack(),
      onConfirmationContinue: (composeTransaction, fee, formKey) {
        _onConfirmationContinue(composeTransaction, fee, formKey);
      },
      onFinalizeSubmit: (password, formKey) {
        _onFinalizeSubmit(password, formKey);
      },
      onFinalizeCancel: () => _onFinalizeCancel(),
    );
  }

  void _handleInitialCancel() {
    context
        .read<ComposeDispenserBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      int giveQuantity = int.parse(giveQuantityController.text);
      int escrowQuantity = int.parse(escrowQuantityController.text);
      int mainchainrate = int.parse(mainchainrateController.text);

      if (asset == null) throw Exception("Please select an asset");

      context.read<ComposeDispenserBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address.address,
            params: ComposeDispenserEventParams(
              asset: asset!,
              giveQuantity: giveQuantity,
              escrowQuantity: escrowQuantity,
              mainchainrate: mainchainrate,
              status: 0, // TODO: get rid of this
            ),
          ));
    }
  }

  Widget _buildAssetInput(ComposeDispenserState state, bool loading) {
    return state.balancesState.maybeWhen(
        orElse: () => const AssetDropdownLoading(),
        success: (balances) {
          if (balances.isEmpty) {
            return const HorizonUI.HorizonTextFormField(
              enabled: false,
              label: "No assets",
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (asset == null) {
              setState(() {
                asset = balances[0].asset;
              });
            }
          });

          return SizedBox(
            height: 48,
            child: AssetDropdown(
              loading: loading,
              asset: asset,
              controller: assetController,
              balances: balances,
              onSelected: (String? value) {
                Balance? balance =
                    _getBalanceForSelectedAsset(balances, value!);

                if (balance == null)
                  throw Exception("No balance found for selected asset");

                setState(() {
                  asset = value;
                  balance_ = balance;
                  giveQuantityController.text = '';
                });

                context
                    .read<ComposeDispenserBloc>()
                    .add(ChangeAsset(asset: value, balance: balance));
              },
            ),
          );
        });
  }

  Widget _buildGiveQuantityInput(ComposeDispenserState state,
      void Function() handleInitialSubmit, bool loading) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildGiveQuantityInputField(
          state,
          null,
          // handleInitialSubmit,
          loading);
    }, success: (balances) {
      if (balances.isEmpty) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      Balance? balance = balance_ ??
          _getBalanceForSelectedAsset(balances, asset ?? balances[0].asset);

      if (balance == null) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      return _buildGiveQuantityInputField(
          state,
          balance,
          // handleInitialSubmit,
          loading);
    });
  }

  Widget _buildGiveQuantityInputField(
      ComposeDispenserState state,
      Balance? balance,
      /* void Function() handleInitialSubmit, */ bool loading) {
    return Stack(
      children: [
        HorizonUI.HorizonTextFormField(
          controller: giveQuantityController,
          enabled: !loading,
          onChanged: (value) {
            context
                .read<ComposeDispenserBloc>()
                .add(ChangeGiveQuantity(value: value));
          },
          label: 'Quantity',
          inputFormatters: [
            balance?.assetInfo.divisible == true
                ? DecimalTextInputFormatter(decimalRange: 8)
                : FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a quantity';
            }
            Decimal input = Decimal.parse(value);
            Decimal max = Decimal.parse(balance?.quantityNormalized ?? '0');
            if (input > max) {
              return "give quantity exceeds available balance";
            }
            setState(() {
              balance_ = balance;
            });
            return null;
          },
          // onFieldSubmitted: (value) {
          //   handleInitialSubmit();
          // },
        ),
        state.balancesState.maybeWhen(orElse: () {
          return const SizedBox.shrink();
        }, success: (_) {
          return asset != null
              ? Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2.0),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildEscrowQuantityInput(ComposeDispenserState state, bool loading) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildEscrowQuantityInputField(state, null, loading);
    }, success: (balances) {
      if (balances.isEmpty) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      Balance? balance = balance_ ??
          _getBalanceForSelectedAsset(balances, asset ?? balances[0].asset);

      if (balance == null) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      return _buildEscrowQuantityInputField(state, balance, loading);
    });
  }

  Widget _buildEscrowQuantityInputField(
      ComposeDispenserState state, Balance? balance, bool loading) {
    return HorizonUI.HorizonTextFormField(
      controller: escrowQuantityController,
      enabled: !loading,
      onChanged: (value) {
        context
            .read<ComposeDispenserBloc>()
            .add(ChangeEscrowQuantity(value: value));
      },
      label: 'Escrow Quantity',
      inputFormatters: [
        balance?.assetInfo.divisible == true
            ? DecimalTextInputFormatter(decimalRange: 8)
            : FilteringTextInputFormatter.digitsOnly,
      ],
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: false),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an escrow quantity';
        }
        Decimal escrowQuantity = Decimal.parse(value);
        Decimal max = Decimal.parse(balance?.quantityNormalized ?? '0');
        if (escrowQuantity > max) {
          return "escrow quantity exceeds available balance";
        }

        Decimal? giveQuantity = giveQuantityController.text.isNotEmpty
            ? Decimal.parse(giveQuantityController.text)
            : null;
        // Check if the escrow quantity is greater than or equal to the give quantity

        if (giveQuantity != null && escrowQuantity < giveQuantity) {
          return 'Escrow quantity must be greater than or equal to give quantity';
        }

        setState(() {
          balance_ = balance;
        });
        return null;
      },
    );
  }

  List<Widget> _buildInitialFormFields(
      ComposeDispenserState state, bool loading, GlobalKey<FormState> formKey) {
    return [
      HorizonUI.HorizonTextFormField(
        enabled: false,
        controller: openAddressController,
        label: "Open Address",
      ),
      const SizedBox(height: 16.0),
      _buildAssetInput(state, loading),
      const SizedBox(height: 16.0),
      _buildGiveQuantityInput(state, () {
        _handleInitialSubmit(formKey);
      }, loading),
      const SizedBox(height: 16.0),
      _buildEscrowQuantityInput(state, loading),
      const SizedBox(height: 16.0),
      _buildPricePerUnitInput(loading),
    ];
  }

  Widget _buildPricePerUnitInput(bool loading) {
    return HorizonUI.HorizonTextFormField(
      controller: mainchainrateController,
      label: 'Price Per Unit (satoshis)',
      enabled: !loading,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Only allow integers
      ],
      keyboardType: const TextInputType.numberWithOptions(
          decimal: false, signed: false), // No decimal allowed
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a mainchain rate';
        }
        return null;
      },
    );
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeDispenserVerbose).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Give Quantity",
        controller: TextEditingController(text: params.giveQuantity.toString()),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Escrow Quantity",
        controller:
            TextEditingController(text: params.escrowQuantity.toString()),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Mainchain Rate",
        controller:
            TextEditingController(text: params.mainchainrate.toString()),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeDispenserBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDispenserBloc>().add(
            FinalizeTransactionEvent<ComposeDispenserVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDispenserBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeDispenserBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}

class AssetDropdownLoading extends StatelessWidget {
  const AssetDropdownLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      DropdownMenu(
        expandedInsets: const EdgeInsets.all(0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        initialSelection: "",
        // enabled: false,
        label: const Text('Asset'),
        dropdownMenuEntries:
            [const DropdownMenuEntry<String>(value: "", label: "")].toList(),
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 8.0),
          ),
        ),
      ),
      const Positioned(
        left: 12,
        top: 0,
        bottom: 0,
        child: Center(
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ]);
  }
}

_getBalanceForSelectedAsset(List<Balance> balances, String asset) {
  if (balances.isEmpty) {
    return null;
  }

  return balances.firstWhereOrNull((balance) => balance.asset == asset) ??
      balances[0];
}
