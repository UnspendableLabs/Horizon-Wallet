import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

class AddressDropdown extends StatefulWidget {
  final bool isDarkTheme;
  final List<Address> addresses;
  final Function(Address) onChange;

  const AddressDropdown(
      {super.key,
      required this.isDarkTheme,
      required this.addresses,
      required this.onChange});

  @override
  AddressDropdownState createState() => AddressDropdownState();
}

class AddressDropdownState extends State<AddressDropdown> {
  late Address _selectedAddress;

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.addresses.first;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
            decoration: BoxDecoration(
              color:
                  widget.isDarkTheme ? lightNavyDarkTheme : noBackgroundColor,
              borderRadius: BorderRadius.circular(20.0),
              border: widget.isDarkTheme
                  ? Border.all(color: noBackgroundColor)
                  : Border.all(color: greyLightThemeUnderlineColor),
            ),
            child: SizedBox(
              width: 400,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Address>(
                    // dropdownColor: widget.isDarkTheme
                    //     ? darkNavyDarkTheme
                    //     : whiteLightTheme,
                    style: TextStyle(
                        color: widget.isDarkTheme
                            ? darkThemeInputLabelColor
                            : lightThemeInputLabelColor),
                    isExpanded: true,
                    value: _selectedAddress,
                    onChanged: (Address? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedAddress = newValue;
                        });
                        widget.onChange(newValue);
                      }
                    },
                    items: widget.addresses
                        .map<DropdownMenuItem<Address>>((Address address) {
                      return DropdownMenuItem<Address>(
                        value: address,
                        child: Text(
                          address.address,
                          style: const TextStyle(
                              overflow: TextOverflow.ellipsis, fontSize: 16.0),
                        ),
                      );
                    }).toList(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ),
            ));
      },
    );
  }
}
