import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WebViewPage(),
  ));
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? webViewController;
  bool isLoading = true;
  bool isConnected = true; // Tracks connectivity status
  String initialUrl = 'https://goo.gl/maps/eLH3FaNqZBsf49B66?g_st=abt';

  @override
  void initState() {
    super.initState();
    checkConnectivity();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected = connectivityResult != ConnectivityResult.none;
    });

    if (!isConnected) {
      showConnectivityDialog();
    }
  }

  void showConnectivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Internet Connection"),
        content: const Text(
            "You are not connected to the internet. Please enable internet access and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast ⛈️'),
      ),
      body: isConnected
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isLoading
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            LinearProgressIndicator(),
                            SizedBox(height: 10),
                            Text(
                              "Please wait as the page loads🙏",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(
                        url: WebUri(initialUrl),
                      ),
                      initialSettings: InAppWebViewSettings(),
                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onLoadStop: (controller, url) {
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: const Text(
                "No internet connection. Please check your network settings.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
    );
  }
}
