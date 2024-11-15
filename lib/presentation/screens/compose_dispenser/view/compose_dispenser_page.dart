import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_state.dart';
import 'package:horizon/presentation/screens/compose_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/view/compose_dispenser_on_new_address_page.dart';
import 'package:horizon/presentation/screens/compose_send/view/asset_dropdown.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class ComposeDispenserPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const ComposeDispenserPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeDispenserBloc(
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          fetchDispenserFormDataUseCase:
              GetIt.I.get<FetchDispenserFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
        )..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeDispenserPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDispenserPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

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
  bool _submitted = false;
  bool hideSubmitButtons = false;
  bool isCreateNewAddressFlow = false;

  @override
  void initState() {
    super.initState();
    openAddressController.text = widget.address;
  }

  @override
  void dispose() {
    giveQuantityController.dispose();
    escrowQuantityController.dispose();
    mainchainrateController.dispose();
    assetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComposeDispenserBloc, ComposeDispenserState>(
      listener: (context, state) {
        setState(() {
          hideSubmitButtons = _shouldHideSubmitButtons(state.dialogState);
        });

        state.dialogState.maybeWhen(
          // if the current address has open dispensers and the user chooses to open on a new address, proceed to the new address flow
          closeDialogAndOpenNewAddress: (originalAddress, divisible, asset,
              giveQuantity, escrowQuantity, mainchainrate, feeRate) {
            // Close current dialog
            Navigator.of(context).pop();

            // Show new dialog
            HorizonUI.HorizonDialog.show(
              context: context,
              body: HorizonUI.HorizonDialog(
                title: 'Create Dispenser on New Address',
                includeBackButton: false,
                includeCloseButton: true,
                onBackButtonPressed: () {
                  Navigator.of(context).pop();
                },
                body: ComposeDispenserOnNewAddressPageWrapper(
                  originalAddress: originalAddress,
                  divisible: divisible,
                  asset: asset,
                  giveQuantity: giveQuantity,
                  escrowQuantity: escrowQuantity,
                  mainchainrate: mainchainrate,
                  dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
                  feeRate: feeRate,
                ),
              ),
            );
          },
          orElse: () {},
        );
      },
      child: ComposeBasePage<ComposeDispenserBloc, ComposeDispenserState>(
        hideSubmitButtons: hideSubmitButtons,
        dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
        onFeeChange: (fee) => context
            .read<ComposeDispenserBloc>()
            .add(ChangeFeeOption(value: fee)),
        buildInitialFormFields: (state, loading, formKey) =>
            _buildInitialFormFields(state, loading, formKey),
        onInitialCancel: () => _handleInitialCancel(),
        onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
        buildConfirmationFormFields: (state, composeTransaction, formKey) =>
            _buildConfirmationDetails(composeTransaction),
        onConfirmationBack: () => _onConfirmationBack(),
        onConfirmationContinue: (composeTransaction, fee, formKey) {
          _onConfirmationContinue(composeTransaction, fee, formKey);
        },
        onFinalizeSubmit: (password, formKey) {
          _onFinalizeSubmit(password, formKey);
        },
        onFinalizeCancel: () => _onFinalizeCancel(),
      ),
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      Balance? balance = balance_;

      if (asset == null) {
        throw Exception("Please select an asset");
      }

      if (balance == null) {
        throw Exception("No balance found for selected asset");
      }

      Decimal giveInput = Decimal.parse(giveQuantityController.text);
      Decimal escrowInput = Decimal.parse(escrowQuantityController.text);
      Decimal mainchainrateBtc =
          Decimal.parse(mainchainrateController.text); // Price in BTC

      int giveQuantity;
      int escrowQuantity;

      // Handle divisibility for the give quantity
      if (balance.assetInfo.divisible) {
        giveQuantity =
            (giveInput * Decimal.fromInt(100000000)).toBigInt().toInt();
        escrowQuantity =
            (escrowInput * Decimal.fromInt(100000000)).toBigInt().toInt();
      } else {
        giveQuantity = giveInput.toBigInt().toInt();
        escrowQuantity = escrowInput.toBigInt().toInt();
      }

      int mainchainrate =
          (mainchainrateBtc * Decimal.fromInt(100000000)).toBigInt().toInt();

      if (isCreateNewAddressFlow) {
        context.read<ComposeDispenserBloc>().add(ConfirmTransactionOnNewAddress(
              originalAddress: widget.address,
              divisible: balance.assetInfo.divisible,
              asset: asset!,
              giveQuantity: giveQuantity,
              escrowQuantity: escrowQuantity,
              mainchainrate: mainchainrate,
            ));
        return;
      }

      // Dispatch the event with the calculated values

      context.read<ComposeDispenserBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address,
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

  Widget _buildAssetInput(ComposeDispenserState state, bool loading,
      [String? label]) {
    return state.balancesState.maybeWhen(
        orElse: () => const AssetDropdownLoading(),
        success: (balances) {
          // the problem is here, somehow balances is being reset
          // to a single balance...

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
              key: const Key('asset_dropdown'),
              loading: loading,
              label: label,
              asset: asset ?? balances[0].asset,
              controller: assetController,
              balances: balances,
              onSelected: (String? value) {
                _onAssetChanged(value, balances);
              },
            ),
          );
        });
  }

  void _onAssetChanged(String? value, List<Balance> balances) {
    Balance? balance = _getBalanceForSelectedAsset(balances, value!);

    if (balance == null) throw Exception("No balance found for selected asset");

    setState(() {
      asset = value;
      balance_ = balance;

      // Reset the input fields
      giveQuantityController.clear();
      escrowQuantityController.clear();
      mainchainrateController.clear();
    });

    context
        .read<ComposeDispenserBloc>()
        .add(ChangeAsset(asset: value, balance: balance));
  }

  Widget _buildGiveQuantityInput(
      ComposeDispenserState state,
      void Function() handleInitialSubmit,
      bool loading,
      GlobalKey<FormState> formKey) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildGiveQuantityInputField(state, null, loading, formKey);
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

      return _buildGiveQuantityInputField(state, balance, loading, formKey);
    });
  }

  Widget _buildGiveQuantityInputField(ComposeDispenserState state,
      Balance? balance, bool loading, GlobalKey<FormState> formKey) {
    return Stack(
      children: [
        HorizonUI.HorizonTextFormField(
          key: Key('give_quantity_input_${balance?.asset}'),
          controller: giveQuantityController,
          enabled: !loading,
          onChanged: (value) {
            setState(() {
              balance_ = balance;
            });
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
            return null;
          },
          onFieldSubmitted: (value) {
            _handleInitialSubmit(formKey);
          },
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
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

  Widget _buildEscrowQuantityInput(
      ComposeDispenserState state, bool loading, GlobalKey<FormState> formKey) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildEscrowQuantityInputField(state, null, loading, formKey);
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

      return _buildEscrowQuantityInputField(state, balance, loading, formKey);
    });
  }

  Widget _buildEscrowQuantityInputField(ComposeDispenserState state,
      Balance? balance, bool loading, GlobalKey<FormState> formKey) {
    return HorizonUI.HorizonTextFormField(
      key: Key('escrow_quantity_input_${balance?.asset}'),
      controller: escrowQuantityController,
      enabled: !loading,
      onChanged: (value) {
        setState(() {
          balance_ = balance;
        });
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
          return 'escrow quantity must be greater than or equal to give quantity';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        _handleInitialSubmit(formKey);
      },
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
    );
  }

  Widget _displayDispensersWarning(ComposeDispenserState state, bool loading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: Colors.orange),
              const SizedBox(width: 8.0),
              Expanded(
                child: SelectableText(
                  'Address currently has open dispensers. Creating multiple dispensers on the same address will result in a multidispense.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Text(
            'How would you like to proceed?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8.0),
          LayoutBuilder(
            builder: (context, constraints) {
              // Stack buttons vertically if width is less than 400px
              if (constraints.maxWidth < 400) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (addressIsSegwit(widget.address))
                      _buildWarningButton(
                        'Create Dispenser on a new address',
                        true,
                      ),
                    const SizedBox(height: 8.0),
                    _buildWarningButton(
                      'Continue with existing address',
                      false,
                    ),
                  ],
                );
              }
              // Otherwise, show buttons side by side
              return Row(
                children: [
                  Expanded(
                    child: _buildWarningButton(
                      'Create Dispenser on a new address',
                      true,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildWarningButton(
                      'Continue with existing address',
                      false,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWarningButton(String label, bool isCreateNewAddress) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isCreateNewAddressFlow = isCreateNewAddress;
          hideSubmitButtons = false;
        });
        context.read<ComposeDispenserBloc>().add(
              ChooseWorkFlow(
                isCreateNewAddress: isCreateNewAddress,
              ),
            );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
      ),
      child: Text(label),
    );
  }

  List<Widget> _buildInitialFormFields(
      ComposeDispenserState state, bool loading, GlobalKey<FormState> formKey) {
    return [
      state.dialogState.maybeWhen(orElse: () {
        return const SizedBox.shrink();
      }, successNormalFlow: () {
        return Column(
          children: [
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
            }, loading, formKey),
            const SizedBox(height: 16.0),
            _buildEscrowQuantityInput(state, loading, formKey),
            const SizedBox(height: 16.0),
            _buildPricePerUnitInput(loading, formKey),
          ],
        );
      }, successCreateNewAddressFlow: () {
        return Column(
          children: [
            HorizonUI.HorizonTextFormField(
              enabled: false,
              label: "Open Address",
              controller: TextEditingController(text: 'To be created'),
            ),
            const SizedBox(height: 16.0),
            _buildAssetInput(state, loading, 'Asset to transfer'),
            const SizedBox(height: 16.0),
            _buildGiveQuantityInput(state, () {
              _handleInitialSubmit(formKey);
            }, loading, formKey),
            const SizedBox(height: 16.0),
            _buildEscrowQuantityInput(state, loading, formKey),
            const SizedBox(height: 16.0),
            _buildPricePerUnitInput(loading, formKey),
          ],
        );
      }, warning: () {
        return Column(
          children: [
            HorizonUI.HorizonTextFormField(
              enabled: false,
              controller: openAddressController,
              label: "Open Address",
            ),
            _displayDispensersWarning(state, loading),
          ],
        );
      }),
    ];
  }

  Widget _buildPricePerUnitInput(bool loading, GlobalKey<FormState> formKey) {
    return HorizonUI.HorizonTextFormField(
      key: const Key('price_per_unit_input'),
      controller: mainchainrateController,
      label: 'Price Per Unit (BTC)',
      enabled: !loading,
      inputFormatters: [
        DecimalTextInputFormatter(
            decimalRange: 8), // Allow up to 8 decimal places for BTC
      ],
      keyboardType: const TextInputType.numberWithOptions(
          decimal: false, signed: false), // No decimal allowed
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Per Unit Price is required';
        }
        if (double.parse(value) < 0.000006) {
          return 'Price must exceed dust limit of 600 satoshis';
        }
        return null;
      },
      onFieldSubmitted: (value) {
        _handleInitialSubmit(formKey);
      },
      autovalidateMode: _submitted
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
    );
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params =
        (composeTransaction as ComposeDispenserResponseVerbose).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Asset",
        controller: TextEditingController(text: params.asset),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Give Quantity",
        controller: TextEditingController(text: params.giveQuantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Escrow Quantity",
        controller:
            TextEditingController(text: params.escrowQuantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: 'Price Per Unit (BTC)',
        controller: TextEditingController(
            text: satoshisToBtc(params.mainchainrate).toStringAsFixed(8)),
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
            FinalizeTransactionEvent<ComposeDispenserResponseVerbose>(
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

  bool _shouldHideSubmitButtons(DialogState dialogState) {
    return dialogState.maybeWhen(
      loading: () => true,
      warning: () => true,
      orElse: () => false,
    );
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
