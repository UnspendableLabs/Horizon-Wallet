// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';

class ComposeIssuancePage extends StatelessWidget {
  final Address initialAddress;

  const ComposeIssuancePage({super.key, required this.initialAddress});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ComposeIssuanceBloc(),
        child: _ComposeIssuancePage(
          initialAddress: initialAddress,
        ));
  }
}

class _ComposeIssuancePage extends StatefulWidget {
  final Address initialAddress;

  const _ComposeIssuancePage({required this.initialAddress});

  @override
  _ComposeIssuancePageState createState() => _ComposeIssuancePageState();
}

class _ComposeIssuancePageState extends State<_ComposeIssuancePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('Compose Issuance'),
      ),
      body: BlocBuilder<ComposeIssuanceBloc, ComposeIssuanceState>(
        builder: (context, state) {
          if (state is ComposeIssuanceInitial) {
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SelectableText('From Address: ${widget.initialAddress.address}'),
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name for the issuance';
                        }
                        return null;
                      },
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          context.read<ComposeIssuanceBloc>().add(CreateIssuanceEvent(
                              sourceAddress: widget.initialAddress,
                              name: nameController.text,
                              quantity: double.parse(quantityController.text)));
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is ComposeIssuanceLoading) {
            return const CircularProgressIndicator();
          }
          if (state is ComposeIssuanceError) {
            return SelectableText(state.message);
          }
          if (state is ComposeIssuanceSuccess) {
            return Column(
              children: [
                const Text('Issuance Created'),
                SelectableText('Name: ${state.composeIssuance.name}'),
                SelectableText('Raw Transaction: ${state.composeIssuance.rawtransaction}'),
              ],
            );
          }
          return const Text("");
        },
      ),
    );
  }
}
