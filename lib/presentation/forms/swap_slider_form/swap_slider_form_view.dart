import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class SwapSliderForm extends StatefulWidget {
  const SwapSliderForm({
    super.key,
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

    const cardHeight = 366.0;

    return const Column(
      children: [
        SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: HorizonCard(
            padding: EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Line 1"),
                  SizedBox(height: 12),
                  Text("Line 2"),
                  SizedBox(height: 12),
                  Text("Line 3"),
                  SizedBox(height: 12),
                  Text("More content..."),
                  SizedBox(height: 400), // simulate long content
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text("button"),
      ],
    );
  }
}
