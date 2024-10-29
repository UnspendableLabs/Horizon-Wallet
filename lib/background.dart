
import 'package:chrome_extension/runtime.dart';
import 'package:chrome_extension/tabs.dart';
import 'dart:js_interop';
import 'dart:convert';
import 'package:js/js_util.dart' as js_util;

import "package:horizon/data/sources/local/dao/addresses_dao.dart";
import "package:horizon/data/sources/local/db.dart" as local;
import "package:horizon/data/sources/repositories/address_repository_impl.dart";
import "package:horizon/domain/repositories/address_repository.dart";
import 'package:horizon/data/sources/local/db_manager.dart';
import "package:horizon/domain/entities/address.dart";

const CONTENT_SCRIPT_PORT = "content-script";

int? getTabIdFromPort(Port port) {
  return port.sender?.tab?.id;
}


void rpcMessageHandler(AddressRepository addressRepository, Map<dynamic, dynamic> message, Port port) async {
  String method = message["method"];

  int? tabId = getTabIdFromPort(port);
  //
  if (tabId == null) {
    return;
  }

  switch (method) {


    case "getAddresses":

      List<Address> addresses = await  addressRepository.getAll();
        
        
      chrome.tabs.sendMessage(
          tabId,
          {
            'addresses': [
              {'address': addresses[0].address, 'type': 'p2wpkh'}
            ],
            'id': message['id'],
          },
          null);

    default:
      print('Unknown method: ${message['method']}');
  }
}

void init(AddressRepository addressRepository) async {
  await for (Port port in chrome.runtime.onConnect) {
    print("aaa");
    print(port.name);
    if (port.name != CONTENT_SCRIPT_PORT) continue;

    print("bbb");

    await for (var event in port.onMessage) {
      print(
          'Background script received message from content script: ${event.message}');

      String? originUrl = port.sender?.origin ?? port.sender?.url;

      if (originUrl == null) {
        print("no origin");
        continue;
      }

      rpcMessageHandler(addressRepository, event.message as Map<dynamic, dynamic>, event.port);
    }
  }
}
