import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// WebViewEnvironment? webViewEnvironment;

class InAppBrowserController extends ChromeSafariBrowser {
  BuildContext? context;
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad(didLoadSuccessfully) {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

class InAppBrowserView extends StatefulWidget {
  const InAppBrowserView({super.key});

  @override
  State<InAppBrowserView> createState() => _InAppBrowserViewState();
}

class _InAppBrowserViewState extends State<InAppBrowserView> {
  final browserController = InAppBrowserController();

  @override
  void initState() {
    // browserController.addMenuItem(ChromeSafariBrowserMenuItem(
    //     id: 1,
    //     label: 'Custom item menu 1',
    //     onClick: (url, title) {
    //       print('Custom item menu 1 clicked!');
    //     }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
          onPressed: () async {
            await browserController.open(
                url: WebUri("https://horizon.market"),
                settings: ChromeSafariBrowserSettings(
                    shareState: CustomTabsShareState.SHARE_STATE_OFF,
                    barCollapsingEnabled: true));
          },
          child: const Text("Open Chrome Safari Browser")),
    );
  }

  @override
  void dispose() {
    browserController.context = null;
    super.dispose();
  }
}

class EmbeddedBrowserView extends StatefulWidget {
  final String url;

  const EmbeddedBrowserView({super.key, required this.url});

  @override
  State<EmbeddedBrowserView> createState() => _EmbeddedBrowserViewState();
}

class _EmbeddedBrowserViewState extends State<EmbeddedBrowserView> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          print("Started loading: $url");
          controller.addJavaScriptHandler(
            handlerName: 'walletBridge',
            callback: (args) async {
              final Map<String, dynamic> message = args[0];
              final method = message['method'];
              final id = message['id'];

              print('📩 Flutter received method: $method');

              if (method == 'getAddresses') {
                final addresses = await _showGetAddressesDialog(context);
                print("\n\n\naddresses: $addresses \n\n");

                if (addresses != null) {
                  print("about tocall _postMessage");
                  print({
                    'jsonrpc': '2.0',
                    'id': id,
                    'addresses': addresses,
                  });

                  await _postMessage({
                    'jsonrpc': '2.0',
                    'id': id,
                    'addresses': addresses,
                  });
                } else {
                  await _postMessage({
                    'jsonrpc': '2.0',
                    'id': id,
                    'error': {
                      'code': 4001,
                      'message': 'User rejected request',
                    },
                  });
                }
              } else {
                // Unknown method
                await _postMessage({
                  'jsonrpc': '2.0',
                  'id': id,
                  'error': {
                    'code': -32601,
                    'message': 'Method not found',
                  },
                });
              }

              return null; // real response goes through postMessage
            },
          );
        },
        onLoadStop: (controller, url) async {
          await controller.evaluateJavascript(
              source: _injectHorizonProviderScript());
          print('✅ Injected HorizonWalletProvider into page');
        },
      ),
    );
  }

  Future<void> _postMessage(Map<String, dynamic> message) async {
    print("\n\n\nymessage in postMessage $message\n\n");

    final jsonString = jsonEncode(message);
    print("\n\nder json $jsonString\n\n\n\n");
    await webViewController?.evaluateJavascript(source: '''
      window.postMessage($jsonString, window.location.origin);
    ''');
  }

  // Simple confirm dialog for "getAddresses"
  Future<List<Map<String, String>>?> _showGetAddressesDialog(
      BuildContext context) async {
    return await showDialog<List<Map<String, String>>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Approve Address Request?'),
          content:
              const Text('Allow the DApp to access your Bitcoin addresses?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null); // User rejected
              },
              child:
                  const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop([
                    {
                      "type": "p2wpkh",
                      "address": "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2"
                    }
                  ]); // Example addresses
                },
                child: const Text('Approve',
                    style: TextStyle(color: Colors.white))),
          ],
        );
      },
    );
  }

  String _injectHorizonProviderScript() {
    return """
      function registerProvider() {
        if (!window.btc_providers) window.btc_providers = [];

        window.btc_providers.push({
          id: "HorizonWalletProvider",
          name: "Horizon Wallet",
          icon: "data:image/svg+xml;base64,...", // <-- you can paste your SVG base64 here
          methods: ["getAddresses", "signPsbt", "signMessage"]
        });
      }

      registerProvider();

      const provider = {
        request: (method, params) => {
          const id = crypto.randomUUID();
          const rpcRequest = {
            jsonrpc: "2.0",
            id,
            method,
            params,
          };
          document.dispatchEvent(new CustomEvent("horizon-provider-request", { detail: rpcRequest }));
          return new Promise((resolve, reject) => {
            function handleMessage(event) {
              console.log({ event })

              console.log("event.data", event.data)
              console.log("event.data.id", event.data.id)
              console.log("event.data.addresses", event.data.addresses)
              console.log("event.data.addresses[0].address", event.data.addresses[0].address)
              const response = event.data;
              console.log("response.id", response.id, id)
              console.log(JSON.stringify(response))
              if (response.id !== id) return;
              window.removeEventListener("message", handleMessage);
              if ("error" in response) reject(response);

              else resolve({ result: response });
            }
            window.addEventListener("message", handleMessage);
          });
        }
      };

      try {
        Object.defineProperty(window, "HorizonWalletProvider", {
          get: () => provider,
          set: () => {},
        });
      } catch (e) {
        console.warn("Unable to set HorizonWalletProvider on window", e);
      }

      // Listen for horizon-provider-request events and forward them to Flutter
      document.addEventListener("horizon-provider-request", (event) => {
        window.flutter_inappwebview.callHandler('walletBridge', event.detail);
      });

      window.dispatchEvent(new Event('horizon#initialized'));
    """;
  }
}
