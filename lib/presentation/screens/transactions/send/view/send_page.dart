import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/send_form_refactor/send_form_view.dart';
import 'package:horizon/presentation/screens/transactions/send/bloc/send_page_bloc.dart';

class SendPage extends StatefulWidget {
  final String assetName;
  final List<String> addresses;
  const SendPage({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  @override
  Widget build(BuildContext context) {
    return SendFormProvider(
      addresses: widget.addresses,
      assetName: widget.assetName,
    );
  }
}

