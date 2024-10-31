// import 'dart:js_interop';
// import 'dart:html';
//
// @JS()
// external dynamic get chrome;
//
// const String CONTENT_SCRIPT_PORT = "content-script";
//
// @JS()
// external int? getTabIdFromPort(JSObject port);
//
// int? getTabIdFromPortInterop(JSObject port) {
//   final sender = getProperty(port, "sender") as JSObject?;
//   final tab = sender?['tab'] as JSObject?;
//   return tab?['id'] as int?;
// }
//
// void rpcMessageHandler(JsObject message, JsObject port) {
//   final id = getTabIdFromPortInterop(port);
//
//   switch j(message['method'] as String?) {
//     case "ping":
//       chrome['tabs'].callMethod('sendMessage', [
//         getTabIdFromPortInterop(port),
//         JsObject.jsify({'msg': 'pong', 'id': message['id']}),
//       ]);
//       break;
//     case "getAddresses":
//       chrome['tabs'].callMethod('sendMessage', [
//         getTabIdFromPortInterop(port),
//         JsObject.jsify({
//           'addresses': [
//             {'address': '0xdeadbeef', 'type': 'p2wpkh'}
//           ],
//           'id': message['id']
//         }),
//       ]);
//       break;
//     default:
//       print("unknown method ${message['method']}");
//   }
// }
//
// void main() {
//   final runtime = chrome['runtime'];
//
//   runtime.callMethod('onConnect').callMethod('addListener', [
//     allowInterop((JSObject port) {
//       if (port['name'] != CONTENT_SCRIPT_PORT) return;
//
//       port.callMethod('onMessage').callMethod('addListener', [
//         allowInterop((JsObject message, JsObject port) {
//           print("message received in background script at port: $port, $message");
//
//           final sender = port['sender'] as JsObject?;
//           final originUrl = sender?['origin'] ?? sender?['url'];
//
//           if (originUrl == null) {
//             print("message reached background script without a valid origin");
//             return;
//           }
//
//           rpcMessageHandler(message, port);
//         })
//       ]);
//     })
//   ]);
// }
//
