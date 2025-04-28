import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:horizon/domain/entities/compose_response.dart';

import "./bloc/sign_bloc.dart";

class SignProvider<TComposeResponse extends ComposeResponse>
    extends StatelessWidget {
  final String name;
  final Widget child;
  final TComposeResponse composeResponse;
  final String Function(TComposeResponse) getSource;
  const SignProvider({
    required this.name,
    required this.getSource,
    required this.child,
    required this.composeResponse,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignBloc<TComposeResponse>>(
      create: (context) => SignBloc<TComposeResponse>(
        name: name,
        composeResponse: composeResponse,
        getSource: getSource,
      ),
      child: child,
    );
  }
}
