import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

import 'package:flutter_form_builder/flutter_form_builder.dart';

class IssuanceDialog extends StatefulWidget {
  final Asset asset;
  final String actionType;
  const IssuanceDialog(
      {super.key, required this.actionType, required this.asset});
  @override
  _IssuanceDialogState createState() =>
      _IssuanceDialogState(actionType: actionType);
}

class _IssuanceDialogState extends State<IssuanceDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 0;
  late int _totalSteps;
  late String title;

  final String actionType;
  _IssuanceDialogState({required this.actionType}) {
    _totalSteps = _getStepCount(actionType);
  }

  int _getStepCount(String actionType) {
    switch (actionType) {
      case 'reset':
      case 'lockDescription':
      case 'lockQuantity':
        return 2;
      case 'changeDescription':
      case 'issueMore':
      case 'issueSubasset':
        return 3;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    // // Handle the selected action
    switch (actionType) {
      case 'reset':
        title = 'Reset Asset';
        break;
      // case 'lockDescription':
      //   title = 'Lock Description';
      //   break;
      // case 'lockQuantity':
      //   title = 'Lock Quantity';
      // break;
      case 'changeDescription':
        title = 'Change Description';
        break;
      case 'issueMore':
        title = 'Issue More';
        break;
      case 'issueSubasset':
        title = 'Issue Subasset';
        break;
    }

    return HorizonUI.HorizonDialog(
      title: title,
      body: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.7, // Adjust as needed
        ),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Add this line
            children: [
              Flexible(
                // Change Expanded to Flexible
                child: SingleChildScrollView(
                  // Add this
                  child: _buildCurrentStepContent(),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
      includeBackButton: false,
      includeCloseButton: true,
      onBackButtonPressed: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1ContentForAction(actionType, title, widget.asset);
      case 1:
        return _buildStep2Content();
      case 2:
        return _buildStep3Content();
      default:
        return Container();
    }
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        const HorizonUI.HorizonDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HorizonUI.HorizonCancelButton(
              onPressed: _currentStep > 0
                  ? () => setState(() => _currentStep--)
                  : () => Navigator.of(context).pop(),
              buttonText: _currentStep == 0 ? 'CANCEL' : 'BACK',
            ),
            HorizonUI.HorizonContinueButton(
              onPressed: _currentStep < _totalSteps - 1
                  ? () => setState(() => _currentStep++)
                  : () {
                      // Handle form submission here
                      print('Form submitted');
                      Navigator.of(context).pop();
                    },
              buttonText:
                  _currentStep == _totalSteps - 1 ? 'SUBMIT' : 'CONTINUE',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2Content() {
    return FormBuilderDropdown(
      name: 'step2_dropdown',
      decoration: const InputDecoration(labelText: 'Step 2 Dropdown'),
      items: ['Option 1', 'Option 2', 'Option 3']
          .map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
    );
  }

  Widget _buildStep3Content() {
    return FormBuilderCheckbox(
      name: 'step3_checkbox',
      title: const Text('Step 3 Checkbox'),
    );
  }

  Widget _buildStep1ContentForAction(
      String actionType, String title, Asset asset) {
    switch (actionType) {
      case 'reset':
        // case 'lockDescription':
        // case 'lockQuantity':
        return Column(
          children: [
            const SelectableText('Please confirm the following action:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: mainTextWhite)),
            const SizedBox(height: 12),
            SelectableText('$title will be performed on ${asset.asset}',
                style: const TextStyle(fontSize: 16, color: mainTextWhite)),
          ],
        );
      case 'changeDescription':
        print(
            'asset.description: ${asset.description != '' ? asset.description : 'N/A'} ');
        return Column(
          children: [
            SelectableText(
                'Please enter the new description for ${asset.asset}:',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: mainTextWhite)),
            const SizedBox(height: 12),
            HorizonUI.HorizonTextFormField(
              controller: TextEditingController(),
              label: 'Previous Description',
              initialValue: asset.description != '' ? asset.description : 'N/A',
              enabled: false,
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'new_description',
              decoration: const InputDecoration(labelText: 'New Description'),
            ),
          ],
        );
      case 'issueMore':
        return Column(
          children: [
            Text('Please enter the quantity to issue for ${asset.asset}:'),
            FormBuilderTextField(
              name: 'quantity_to_issue',
              decoration: const InputDecoration(labelText: 'Quantity to Issue'),
            ),
          ],
        );
      // case 'issueSubasset':
      //   return Column(
      //     children: [
      //       Text('Please enter the quantity to issue for ${asset.asset}:'),
      //       FormBuilderTextField(
      //         name: 'quantity_to_issue',
      //         decoration: InputDecoration(labelText: 'Quantity to Issue'),
      //       ),
      //     ],
      //   );
      default:
        return Container();
    }
  }
}
