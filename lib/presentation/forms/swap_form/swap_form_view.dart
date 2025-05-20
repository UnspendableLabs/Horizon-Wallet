import "./bloc/loader/loader_bloc.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import "package:horizon/presentation/forms/base/base_form_state.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

class SwapFormLoaderProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AddressV2> addresses;
  final Widget Function(BaseFormState<SwapFormLoaderData>) child;

  const SwapFormLoaderProvider({
    super.key,
    required this.httpConfig,
    required this.addresses,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapFormLoaderBloc(
        loader: SwapFormLoader(),
      )..load(SwapFormLoaderArgs(
          httpConfig: httpConfig,
          addresses: addresses,
        )),
      child: Builder(builder: (context) {
        return BlocBuilder<SwapFormLoaderBloc,
            BaseFormState<SwapFormLoaderData>>(builder: (context, state) {
          return child(state);
        });
      }),
    );
  }
}

class SwapFormView extends StatelessWidget {
  const SwapFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return SwapFormLoaderProvider(
        addresses: session.addresses,
        httpConfig: session.httpConfig,
        child: (state) => switch (state) { _ => Text(state.toString()) });
  }
}
