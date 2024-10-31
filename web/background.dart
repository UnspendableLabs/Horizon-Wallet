import 'package:chrome_extension/runtime.dart';
import 'package:chrome_extension/tabs.dart';
import 'package:chrome_extension/windows.dart';

const CONTENT_SCRIPT_PORT = "content-script";

class ListenForPopupCloseArgs {
  /// ID that comes from newly created window
  final int? id;

  /// TabID from requesting tab, to which request should be returned
  final int? tabId;
  final dynamic response;
  ListenForPopupCloseArgs({this.id, this.tabId, required this.response});
}

void listenForPopupClose(ListenForPopupCloseArgs args) {
  chrome.windows.onRemoved.listen((int winId) {
    if (winId != args.id || args.tabId == null) return;
    chrome.tabs.sendMessage(args.tabId!, args.response, null);
  });
}

class PopupOptions {
  String? url;
  String? title;
  bool? skipPopupFallback;

  PopupOptions({this.url, this.title, this.skipPopupFallback});
}

Future<Window?> popup(PopupOptions options) async {
  final Window currentWindow = await chrome.windows.getCurrent(null);

  const int popupWidth = 400;
  const int popupHeight = 600;

  final int dualScreenLeft = currentWindow.left ?? 0;
  final int dualScreenTop = currentWindow.top ?? 0;

  final int width = currentWindow.width ?? 0;
  final int height = currentWindow.height ?? 0;

  final int left = (width / 2 - popupWidth / 2 + dualScreenLeft).floor();
  final int top = (height / 2 - popupHeight / 2 + dualScreenTop).floor();

  return await chrome.windows.create(CreateData(
    url: options.url,
    width: popupWidth,
    height: popupHeight,
    top: top,
    left: left,
    focused: true,
    type: CreateType.popup,
  ));
}

int? getTabIdFromPort(Port port) {
  return port.sender?.tab?.id;
}

/// Function to get the origin from the port
String? getOriginFromPort(Port port) {
  return port.sender?.origin ?? port.sender?.url;
}

Future<void> rpcGetAddresses(String requestId, Port port) async {
  String? origin = getOriginFromPort(port);
  int? tabId = getTabIdFromPort(port);

  Window? window = await popup(
      PopupOptions(url: "/index.html#?action=getAddresses,$tabId,$requestId"));

  listenForPopupClose(ListenForPopupCloseArgs(
      id: window?.id,
      tabId: tabId,
      response: {
        "id": requestId,
        "errror": "User rejected `getAddresses` request"
      }));
}

Future<void> rpcSignPsbt(String requestId, Port port, String psbt) async {
  String? origin = getOriginFromPort(port);
  int? tabId = getTabIdFromPort(port);

  Window? window = await popup(PopupOptions(
      url: "/index.html#?action=signPsbt,$tabId,$requestId,$psbt"));

  listenForPopupClose(ListenForPopupCloseArgs(
      id: window?.id,
      tabId: tabId,
      response: {
        "id": requestId,
        "errror": "User rejected `signPsbt` request"
      }));
}

Future<void> rpcMessageHandler(Map<dynamic, dynamic> message, Port port) async {
  String method = message["method"];

  int? tabId = getTabIdFromPort(port);
  //
  if (tabId == null) {
    return;
  }

  switch (method) {
    case "getAddresses":
      await rpcGetAddresses(message["id"], port);
    case "signPsbt":
      await rpcSignPsbt(message["id"], port, message["params"]["hex"]);
    default:
      print('Unknown method: ${message['method']}');
  }
}

void main() async {
  await for (Port port in chrome.runtime.onConnect) {
    if (port.name != CONTENT_SCRIPT_PORT) continue;

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
