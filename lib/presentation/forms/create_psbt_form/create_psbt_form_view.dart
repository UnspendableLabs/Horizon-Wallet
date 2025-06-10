import 'package:flutter/material.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/common/expiry_selector.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/sats_to_usd_display.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/extensions.dart';
import './bloc/create_psbt_form_bloc.dart';

// just putting this here for now

class CreatePsbtFormActions {
  final Function(String value) onBtcValueChanged;
  final Function(DateTime? date) onExpiryDateSelected;
  final VoidCallback onSubmitClicked;
  final VoidCallback onCloseSignPsbtModalClicked;
  final Function(String signedPsbtHex) onSignatureCompleted;

  const CreatePsbtFormActions(
      {required this.onBtcValueChanged,
      required this.onSubmitClicked,
      required this.onCloseSignPsbtModalClicked,
      required this.onSignatureCompleted,
      required this.onExpiryDateSelected});
}

class CreatePsbtFormProvider extends StatelessWidget {
  final AddressV2 address;
  final String utxoID;

  final Widget Function(
      CreatePsbtFormActions actions, CreatePsbtFormModel state) child;

  const CreatePsbtFormProvider({
    super.key,
    required this.utxoID,
    required this.address,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return BlocProvider(
        create: (context) => CreatePsbtFormBloc(
              address: address,
              httpConfig: session.httpConfig,
              utxoID: utxoID,
            ),
        child: BlocBuilder<CreatePsbtFormBloc, CreatePsbtFormModel>(
            builder: (context, state) => child(
                CreatePsbtFormActions(onBtcValueChanged: (value) {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(BtcPriceInputChanged(value: value));
                }, onExpiryDateSelected: (date) {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(ExpiryDateSelected(date: date));
                }, onSubmitClicked: () {
                  context.read<CreatePsbtFormBloc>().add(SubmitClicked());
                }, onSignatureCompleted: (String signedPsbtHex) {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(SignatureCompleted(signedPsbtHex: signedPsbtHex));
                }, onCloseSignPsbtModalClicked: () {
                  context
                      .read<CreatePsbtFormBloc>()
                      .add(const CloseSignPsbtModalClicked());
                }),
                state)));
  }
}

class CreatePsbtSuccess {
  final String signedPsbtHex;
  final BigInt btcQuantity;

  const CreatePsbtSuccess({
    required this.signedPsbtHex,
    required this.btcQuantity,
  });
}

class CreatePsbtSuccessHandler extends StatelessWidget {
  final Function(CreatePsbtSuccess createPsbtSuccess) onSuccess;

  const CreatePsbtSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(context) {
    return BlocListener<CreatePsbtFormBloc, CreatePsbtFormModel>(
        listener: (context, state) {
          if (state.submissionStatus.isSuccess) {
            print("success callback ${state.btcPriceInput.value}");
            print("success callback dec ${state.btcPriceInput.asDecimal}");
            print("success callback bi ${state.btcPriceInput.asSats}");

            onSuccess(CreatePsbtSuccess(
                signedPsbtHex: state.signedPsbt!,
                btcQuantity: state.btcPriceInput.asSats
                    .getOrThrow() // will never be called if this is undefiend

                ));
          }
        },
        child: const SizedBox.shrink());
  }
}

class CreatePsbtSignHandler extends StatelessWidget {
  final Function(String signedPsbtHex) onSuccess;
  final VoidCallback onClose;
  final String address;

  const CreatePsbtSignHandler(
      {super.key,
      required this.onSuccess,
      required this.onClose,
      required this.address});

  @override
  Widget build(context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();

    return BlocListener<CreatePsbtFormBloc, CreatePsbtFormModel>(
        listener: (context, state) async {
          final settings = GetIt.I<SettingsRepository>();

          if (state.showSignPsbtModal) {
            final result = await WoltModalSheet.show(
                context: context,
                modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
                pageListBuilder: (bottomSheetContext) => [
                      WoltModalSheetPage(
                          trailingNavBarWidget: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel",
                                style: Theme.of(context).textTheme.labelLarge),
                          ),
                          hasTopBarLayer: false,
                          // pageTitle: Text("Sign PSBT",
                          //     style: Theme.of(context).textTheme.headlineSmall),
                          child: state.unsignedPsbtHex.fold(
                            () => SizedBox.shrink(),
                            (unsignedPsbtHex) => BlocProvider(
                                create: (context) => SignPsbtBloc(
                                      httpConfig: session.httpConfig,
                                      addresses: session.addresses,
                                      passwordRequired: settings
                                          .requirePasswordForCryptoOperations,
                                      unsignedPsbt: unsignedPsbtHex,
                                      signInputs: {
                                        address: [0]
                                      },
                                      sighashTypes: [
                                        0x03 | 0x80, // single | anyone_can_pay
                                      ],
                                    ),
                                child: SignPsbtForm(
                                  key: Key(unsignedPsbtHex),
                                  passwordRequired: settings
                                      .requirePasswordForCryptoOperations,
                                  onSuccess: (signedPsbtHex) {
                                    onSuccess(signedPsbtHex);

                                    Navigator.of(context).pop();
                                  },
                                )),
                          ))
                    ]);

            onClose();

            // show wolt modal but only if it's not already displayed
          }
        },
        child: const SizedBox.shrink());
  }
}

class CreatePsbtForm extends StatefulWidget {
  final CreatePsbtFormModel state;
  final CreatePsbtFormActions actions;

  final String asset;
  final String quantityNormalized;
  final int quantity;
  final String utxo;
  final String utxoAddress;

  const CreatePsbtForm(
      {required this.state,
      required this.actions,
      required this.asset,
      required this.quantityNormalized,
      required this.quantity,
      required this.utxo,
      required this.utxoAddress,
      super.key});

  @override
  State<CreatePsbtForm> createState() => _CreatePsbtFormState();
}

class _CreatePsbtFormState extends State<CreatePsbtForm> {
  late final TextEditingController _btcController;

  final appIcons = AppIcons();

  @override
  void initState() {
    super.initState();
    // Seed it with whatever value the bloc already holds (or '' if none).
    _btcController =
        TextEditingController(text: widget.state.btcPriceInput.value);
  }

  @override
  void dispose() {
    _btcController.dispose(); // ALWAYS dispose controllers
    super.dispose();
  }

  _buildFromCard(BuildContext context, HttpConfig httpConfig) {
    final theme = Theme.of(context);
    return HorizonCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: QuantityText(
                quantity: widget.quantityNormalized,
                style: TextStyle(fontSize: 35),
              )),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  appIcons.assetIcon(
                      httpConfig: httpConfig,
                      assetName: widget.asset,
                      context: context,
                      width: 24,
                      height: 24),
                  const SizedBox(width: 8),
                  Text(widget.asset,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontSize: 12,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildToCard(BuildContext context, HttpConfig httpConfig) {
    final theme = Theme.of(context);
    return HorizonCard(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: QuantityInputV2(
                      style: const TextStyle(fontSize: 35),
                      divisible: true,
                      controller:
                          _btcController, // chat helpo me with a stateful controller hre,
                      onChanged: (value) {
                        widget.actions.onBtcValueChanged(value);
                      })),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  appIcons.assetIcon(
                      httpConfig: httpConfig,
                      assetName: "BTC",
                      context: context,
                      width: 24,
                      height: 24),
                  const SizedBox(width: 8),
                  Text("BTC",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontSize: 12,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (widget.state.btcPriceInput.isValid)
            SatsToUsdDisplay(
                sats: widget.state.btcPriceInput.asSats
                    .getOrElse(() => BigInt.zero),
                child: (usdValue) => Text(
                      '${usdValue.toStringAsFixed(2)} USD',
                      style: theme.textTheme.labelSmall?.copyWith(height: 1.2),
                    )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            commonHeightSizedBox,
            Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                        height: 132,
                        child: _buildFromCard(context, session.httpConfig)),
                    commonHeightSizedBox,
                    SizedBox(
                        height: 132,
                        child: _buildToCard(context, session.httpConfig)),
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
            commonHeightSizedBox,
            ExpirySelector(onChange: (date) {
              widget.actions.onExpiryDateSelected(date);
            }),
            commonHeightSizedBox,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: HorizonButton(
                  disabled: widget.state.submitDisabled,
                  isLoading: widget.state.submissionStatus.isInProgress,
                  onPressed: () {
                    if (!widget.state.submitDisabled) {
                      widget.actions.onSubmitClicked();
                    }
                  },
                  child: TextButtonContent(value: "Create listing")),
            )
          ],
        ),
      ),
    );
  }
}
