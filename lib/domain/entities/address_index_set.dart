import "./address_v2.dart";
import 'package:collection/collection.dart';

// this models all of the addresses rendered
// at a given index ( e.g. p2wphk, p2pkh, etc. )

class AddressIndexSet {
  final Map<AddressV2Type, AddressV2> _map;

  AddressIndexSet(this._map);

  List<AddressV2> get list {
    return _map.values.toList()
      ..sort((a, b) => priority(a.type).compareTo(priority(b.type)));
  }

  static int priority(AddressV2Type type) {
    return switch (type) {
      AddressV2Type.p2wpkh => 0,
      AddressV2Type.p2pkh => 1,
    };
  }

  AddressV2? getByAddress(String address) {
    return _map.values.firstWhereOrNull((a) => a.address == address);
  }

  AddressV2? getByType(AddressV2Type type) {
    return _map[type];
  }
}

sealed class AddressIndexSetViewModel {}

class AddressIndexSetSingle implements AddressIndexSetViewModel {
  final AddressV2 address;

  AddressIndexSetSingle(this.address);
}

class AddressIndexSetMultiple implements AddressIndexSetViewModel {
  final List<AddressV2> addresses;

  AddressIndexSetMultiple(this.addresses);
}

extension AddressIndexSetExtension on AddressIndexSet {
  AddressIndexSetViewModel toViewModel() {
    if (_map.length == 1) {
      return AddressIndexSetSingle(_map.values.first);
    } else {
      return AddressIndexSetMultiple(list);
    }
  }
}
