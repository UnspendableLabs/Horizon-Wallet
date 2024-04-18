import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/bloc/stored_wallet_data_bloc.dart';
import 'package:uniparty/bloc/wallet_recovery_bloc.dart';
import 'package:uniparty/common/constants.dart';
import 'package:uniparty/models/create_wallet_payload.dart';
import 'package:uniparty/services/seed_ops_service.dart';
import 'package:uniparty/widgets/common/back_button.dart';
import 'package:uniparty/widgets/common/common_dialog_shape.dart';

class RecoverWalletFlow extends StatefulWidget {
  const RecoverWalletFlow({super.key});

  @override
  State<RecoverWalletFlow> createState() => _RecoverWalletFlowState();
}

const List<RecoveryWalletEnum> list = <RecoveryWalletEnum>[
  RecoveryWalletEnum.counterwallet,
  RecoveryWalletEnum.freewallet,
  RecoveryWalletEnum.uniparty
];

class _RecoverWalletFlowState extends State<RecoverWalletFlow> {
  final _textFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WalletRecoveryBloc>(
        create: (BuildContext context) => WalletRecoveryBloc(),
        child: BlocListener<WalletRecoveryBloc, WalletRecoveryState>(
            listenWhen: (previous, current) => previous.recoveryWallet != current.recoveryWallet,
            listener: (context, state) {
              BlocProvider.of<WalletRecoveryBloc>(context).add(WalletRecoveryEvent(recoveryWallet: state.recoveryWallet));
            },
            child: ElevatedButton(
              onPressed: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => MultiBlocProvider(
                          providers: [
                            BlocProvider<WalletRecoveryBloc>(
                              create: (BuildContext context) => WalletRecoveryBloc(),
                            ),
                            BlocProvider<StoredWalletDataBloc>(
                              create: (BuildContext context) => StoredWalletDataBloc(),
                            ),
                          ],
                          child: BlocBuilder<WalletRecoveryBloc, WalletRecoveryState>(builder: (context, state) {
                            return Dialog(
                                shape: getDialogShape(),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      const CommonBackButton(),
                                      TextFormField(
                                        controller: _textFieldController,
                                        decoration: const InputDecoration(hintText: "input seed phrase"),
                                        validator: (value) {
                                          return GetIt.I.get<SeedOpsService>().validateMnemonic(value, state.recoveryWallet);
                                        },
                                      ),
                                      FilledButton(
                                          onPressed: () {
                                            if (_formKey.currentState!.validate()) {
                                              Navigator.pushNamed(
                                                context,
                                                AppRouter.walletPage,
                                                arguments: CreateWalletPayload(
                                                    mnemonic: _textFieldController.text,
                                                    recoveryWallet: state.recoveryWallet),
                                              );
                                            }
                                          },
                                          child: const Text('Recover wallet')),
                                      DropdownButton<RecoveryWalletEnum>(
                                        value: state.recoveryWallet,
                                        icon: const Icon(Icons.arrow_downward),
                                        elevation: 16,
                                        style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
                                        underline: Container(
                                          height: 2,
                                          color: const Color.fromRGBO(159, 194, 244, 1.0),
                                        ),
                                        onChanged: (RecoveryWalletEnum? value) {
                                          // This is called when the user selects an item.
                                          BlocProvider.of<WalletRecoveryBloc>(context)
                                              .add(WalletRecoveryEvent(recoveryWallet: value!));
                                        },
                                        items: list.map<DropdownMenuItem<RecoveryWalletEnum>>((RecoveryWalletEnum value) {
                                          return DropdownMenuItem<RecoveryWalletEnum>(
                                            value: value,
                                            child: Text(value.name),
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                ));
                          }),
                        ));
              },
              style: _buttonStyle(),
              child: const Text('Recover Wallet'),
            )));
  }

  ButtonStyle _buttonStyle() {
    return ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size?>(const Size(150.0, 50.0)),
        textStyle: MaterialStateProperty.all<TextStyle?>(const TextStyle(fontSize: 15)));
  }
}
