import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/http_config.dart';

import "./bloc/swap_slider_form_bloc.dart";

class SwapSliderFormActions {}

class SwapSliderFormProvider extends StatelessWidget {
  final String assetName;
  final HttpConfig httpConfig;
  final Widget Function(
    SwapSliderFormActions actions,
    SwapSliderFormModel state,
  ) child;
  const SwapSliderFormProvider({
    super.key,
    required this.child,
    required this.assetName,
    required this.httpConfig,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapSliderFormBloc(
        assetName: assetName,
        httpConfig: httpConfig,
      ),
      child: BlocBuilder<SwapSliderFormBloc, SwapSliderFormModel>(
          builder: (context, state) {
        return child(SwapSliderFormActions(), state);
      }),
    );
  }
}

class SwapSliderForm extends StatefulWidget {
  final SwapSliderFormActions actions;
  final SwapSliderFormModel state;

  const SwapSliderForm({
    super.key,
    required this.actions,
    required this.state,
  });

  @override
  State<SwapSliderForm> createState() => _SwapSliderFormState();
}

class _SwapSliderFormState extends State<SwapSliderForm> {
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final theme = Theme.of(context);
    final appIcons = AppIcons();

    final cardHeight = 366.0;

    return Column(
      children: [
        Text("state: ${widget.state.atomicSwaps}"),
        SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: HorizonCard(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Line 1"),
                  SizedBox(height: 12),
                  Text("Line 2"),
                  SizedBox(height: 12),
                  Text("Line 3"),
                  SizedBox(height: 12),
                  Text("Moreasdf content..."),
                  SizedBox(height: 400), // simulate long content
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text("button"),
      ],
    );
  }
}
