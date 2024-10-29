import 'package:chrome_extension/runtime.dart';
import 'package:chrome_extension/tabs.dart';
import 'dart:js_interop';
import 'dart:convert';
import 'package:js/js_util.dart' as js_util;

const CONTENT_SCRIPT_PORT = "content-script";

int? getTabIdFromPort(Port port) {
  return port.sender?.tab?.id;
}

void rpcMessageHandler(Map<dynamic, dynamic> message, Port port) {

  String method = message["method"];

  int? tabId = getTabIdFromPort(port);
  //
  if (tabId == null) {
    return;
  }

  switch (method) {
    case "getAddresses":
      chrome.tabs.sendMessage(
          tabId,
          {
            'addresses': [
              {'address': '0xdeadbeef', 'type': 'p2wpkh'}
            ],
            'id': message['id'],
          },
          null);

    default:
      print('Unknown method: ${message['method']}');
  }
}

void main() async {
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

      rpcMessageHandler(event.message as Map<dynamic, dynamic>, event.port);
    }
  }
}
