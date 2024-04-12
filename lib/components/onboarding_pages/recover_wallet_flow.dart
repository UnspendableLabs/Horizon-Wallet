import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uniparty/app_router.dart';
import 'package:uniparty/bloc/data_bloc.dart';
import 'package:uniparty/bloc/data_events.dart';
import 'package:uniparty/components/common/back_button.dart';
import 'package:uniparty/models/constants.dart';
import 'package:uniparty/models/wallet_retrieve_info.dart';
import 'package:uniparty/utils/seed_phrase_validation.dart';
import 'package:uniparty/wallet_recovery/get_seed_and_wallet_type.dart';

class WalletTypeEvent {
  final String walletType;
  WalletTypeEvent({required this.walletType});
}

class WalletTypeState {
  final String walletType;
  WalletTypeState({required this.walletType});
}

class WalletTypeBloc extends Bloc<WalletTypeEvent, WalletTypeState> {
  WalletTypeBloc() : super(WalletTypeState(walletType: COUNTERWALLET)) {
    on<WalletTypeEvent>((event, emit) {
      emit(WalletTypeState(walletType: event.walletType));
    });
  }
}

class RecoverWalletFlow extends StatefulWidget {
  const RecoverWalletFlow({super.key});

  @override
  State<RecoverWalletFlow> createState() => _RecoverWalletFlowState();
}

const List<String> list = <String>[COUNTERWALLET, FREEWALLET, UNIPARTY];

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
    return BlocProvider<WalletTypeBloc>(
        create: (BuildContext context) => WalletTypeBloc(),
        child: BlocListener<WalletTypeBloc, WalletTypeState>(
            listenWhen: (previous, current) => previous.walletType != current.walletType,
            listener: (context, state) {
              BlocProvider.of<WalletTypeBloc>(context).add(WalletTypeEvent(walletType: state.walletType));
            },
            child: ElevatedButton(
              onPressed: () {
                showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => MultiBlocProvider(
                          providers: [
                            BlocProvider<WalletTypeBloc>(
                              create: (BuildContext context) => WalletTypeBloc(),
                            ),
                            BlocProvider<DataBloc>(
                              create: (BuildContext context) => DataBloc(),
                            ),
                          ],
                          child: BlocBuilder<WalletTypeBloc, WalletTypeState>(builder: (context, state) {
                            return Dialog(
                                shape: _getShape(),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      const CommonBackButton(),
                                      TextFormField(
                                        controller: _textFieldController,
                                        decoration: const InputDecoration(hintText: "input seed phrase"),
                                        validator: (value) {
                                          return validateSeedPhrase(value, state.walletType);
                                        },
                                      ),
                                      FilledButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!.validate()) {
                                              WalletRetrieveInfo walletInfo =
                                                  getSeedHexAndWalletType(_textFieldController.text, state.walletType);

                                              BlocProvider.of<DataBloc>(context).add(WriteDataEvent(data: walletInfo));
                                              // await Future.delayed(const Duration(milliseconds: 500));

                                              Navigator.pushNamed(
                                                // ignore: use_build_context_synchronously
                                                context,
                                                AppRouter.walletPage,
                                                arguments: walletInfo,
                                              );
                                            }
                                          },
                                          child: const Text('Recover wallet')),
                                      DropdownButton<String>(
                                        value: state.walletType,
                                        icon: const Icon(Icons.arrow_downward),
                                        elevation: 16,
                                        style: const TextStyle(color: Color.fromRGBO(159, 194, 244, 1.0)),
                                        underline: Container(
                                          height: 2,
                                          color: const Color.fromRGBO(159, 194, 244, 1.0),
                                        ),
                                        onChanged: (String? value) {
                                          // This is called when the user selects an item.
                                          BlocProvider.of<WalletTypeBloc>(context).add(WalletTypeEvent(walletType: value!));
                                        },
                                        items: list.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
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

  ShapeBorder _getShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: const BorderSide(
        color: Color.fromRGBO(159, 194, 244, 1.0),
      ),
    );
  }
}
