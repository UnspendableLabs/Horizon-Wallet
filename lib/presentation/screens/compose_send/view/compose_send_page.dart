import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import "package:horizon/api/v2_api.dart" as v2_api;

class ComposeSendPage extends StatelessWidget {
  final String initialAddress;

  ComposeSendPage({Key? key, required this.initialAddress}) : super(key: key);

  Future<List<String>> _fetchAssets() async {
    final dio = Dio();
    final client = v2_api.V2Api(dio);

    final xcpBalances = await client.getBalancesByAddress(initialAddress, true);
    final assets = xcpBalances.result!.map((e) => e.asset).toList();
    return assets;
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController destinationAddressController = TextEditingController();
    TextEditingController quantityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Compose Send'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('From Address: $initialAddress'),
              TextFormField(
                controller: destinationAddressController,
                decoration: InputDecoration(labelText: 'Destination Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a destination address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  return null;
                },
              ),
              FutureBuilder<List<String>>(
                future: _fetchAssets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return DropdownButtonFormField<String>(
                      hint: Text('Select Asset'),
                      onChanged: (String? newValue) {},
                      items: snapshot.data!.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Please select an asset' : null,
                    );
                  }
                },
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle form submission
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
