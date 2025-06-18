import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/presentation/common/asset_balance_list_item.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/send/bloc/token_selector_form_bloc.dart';
import 'package:horizon/presentation/screens/send/loader/loader_bloc.dart';

class SendFormLoader extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AddressV2> addresses;
  final Widget Function(RemoteData<SendFormLoaderData>) child;
  const SendFormLoader(
      {super.key,
      required this.httpConfig,
      required this.addresses,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendFormLoaderBloc(loader: SendFormLoaderFn())
        ..load(
            SendFormLoaderArgs(httpConfig: httpConfig, addresses: addresses)),
      child: Builder(builder: (context) {
        return BlocBuilder<SendFormLoaderBloc, RemoteData<SendFormLoaderData>>(
            builder: (context, state) {
          return child(state);
        });
      }),
    );
  }
}

class TokenSelectorFormActions {
  final Function(TokenSelectorOption value) onTokenSelected;
  final VoidCallback onSubmitClicked;

  const TokenSelectorFormActions(
      {required this.onTokenSelected, required this.onSubmitClicked});
}

class TokenSelectorFormSuccessHandler extends StatelessWidget {
  final Function(TokenSelectorOption value) onTokenSelected;
  const TokenSelectorFormSuccessHandler({super.key, required this.onTokenSelected});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TokenSelectorFormBloc, TokenSelectorFormModel>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          onTokenSelected(state.tokenSelectorInput.value!);
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

class TokenSelectorFormProvider extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final Widget Function(
      TokenSelectorFormActions actions, TokenSelectorFormModel state) child;
  const TokenSelectorFormProvider(
      {required this.child, required this.balances, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return TokenSelectorFormBloc(
          initialBalances: balances,
        );
      },
      child: BlocBuilder<TokenSelectorFormBloc, TokenSelectorFormModel>(
          builder: (context, state) {
        return child(
            TokenSelectorFormActions(onTokenSelected: (value) {
              context.read<TokenSelectorFormBloc>().add(TokenSelected(value));
            }, onSubmitClicked: () {
              context.read<TokenSelectorFormBloc>().add(SubmitClicked());
            }),
            state);
      }),
    );
  }
}

class SendFormTokenSelector extends StatefulWidget {
  final TokenSelectorFormActions actions;
  final TokenSelectorFormModel state;
  const SendFormTokenSelector(
      {super.key,
      required this.actions,
      required this.state});

  @override
  State<SendFormTokenSelector> createState() => _SendFormTokenSelectorState();
}

class _SendFormTokenSelectorState extends State<SendFormTokenSelector> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          children: [
            HorizonRedesignDropdown<TokenSelectorOption>(
                itemPadding: const EdgeInsets.all(12),
                items: widget.state.balances
                    .map((item) => DropdownMenuItem(
                          value: item,
                          child: AssetBalanceListItemWithOptionalBalance(
                              asset: item.name,
                              description: item.description,
                              balance: item.balance),
                        ))
                    .toList(),
                onChanged: (value) {
                  widget.actions.onTokenSelected(value!);
                },
                selectedValue: widget.state.tokenSelectorInput.value,
                selectedItemBuilder: (TokenSelectorOption item) =>
                    AssetBalanceListItemWithOptionalBalance(
                        asset: item.name,
                        description: item.description,
                        balance: item.balance),
                hintText: "Select Token"),
            const SizedBox(height: 24),
            HorizonButton(
              variant: ButtonVariant.green,
              disabled: !widget.state.tokenSelectorInput.isValid ||
                  widget.state.submissionStatus.isInProgress,
              onPressed: () {
                widget.actions.onSubmitClicked();
              },
              child: TextButtonContent(value: "Continue"),
            )
          ],
        ),
      );
  }
}
