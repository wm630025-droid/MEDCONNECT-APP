import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String url;
  final String? successUrlPattern;
  final VoidCallback? onSuccess;

  const InAppWebViewScreen({
    super.key,
    required this.url,
    this.successUrlPattern,
    this.onSuccess,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  InAppWebViewController? webViewController;
  double _progress = 0;
  bool _canGoBack = false;
  bool _showOrdersButton = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (webViewController != null && await webViewController!.canGoBack()) {
      await webViewController!.goBack();
      return false;
    }
    return true;
  }

 Future<void> _checkForSuccess(InAppWebViewController controller) async {
  try {
    // ✅ اطبع النص الحقيقي للصفحة عشان نشوف إيه المكتوب
    final pageText = await controller.evaluateJavascript(source: '''
      document.body.innerText
    ''');
    print('📄 Full page text: $pageText');

    final result = await controller.evaluateJavascript(source: '''
      (function() {
        var text = document.body.innerText || '';
        if (
          text.includes('Payment Successful!') ||
          text.includes('Payment Success') ||
          text.includes('Successfully Paid') ||
          text.includes('Transaction Successful')
        ) {
          return 'found';
        }
        return 'not_found';
      })()
    ''');

    print('📄 Success check result: $result');

    if (result == 'found') {
      if (mounted) setState(() => _showOrdersButton = true);
    }
  } catch (e) {
    print('❌ JS error: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Payment Gateway'),
          leading: IconButton(
            icon: Icon(_canGoBack ? Icons.arrow_back : Icons.close),
            onPressed: () async {
              if (_canGoBack && webViewController != null) {
                await webViewController!.goBack();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            if (!_showOrdersButton)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => webViewController?.reload(),
              ),
          ],
        ),
        body: Column(
          children: [
            if (_progress < 1.0)
              LinearProgressIndicator(value: _progress),

            // ✅ زرار View Orders بيظهر لما الدفع ينجح
            if (_showOrdersButton)
              Container(
                width: double.infinity,
                color: Colors.green.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // ✅ لو في callback من الصفحة اللي فتحت الـ WebView
                    if (widget.onSuccess != null) {
                      widget.onSuccess!();
                    } else {
                      Navigator.of(context).pop(true); // بيرجع true للصفحة السابقة
                    }
                  },
                  icon: const Icon(Icons.receipt_long, color: Colors.white),
                  label: const Text(
                    'View My Orders',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

           Expanded(
  child: InAppWebView(
    initialUrlRequest: URLRequest(url: WebUri(widget.url)),
    
    // 1️⃣ هنا غير الـ initialOptions
    initialOptions: InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true, // ✅ أضف ده
      ),
      android: AndroidInAppWebViewOptions(
        supportMultipleWindows: true, // ✅ أضف ده
      ),
    ),

    onWebViewCreated: (controller) {
      webViewController = controller;
    },
    onProgressChanged: (controller, progress) {
      setState(() => _progress = progress / 100);
    },
    onUpdateVisitedHistory: (controller, url, androidIsReload) async {
      final canGoBack = await controller.canGoBack();
      setState(() => _canGoBack = canGoBack);
    },
    onLoadStop: (controller, url) async {
      await _checkForSuccess(controller);
    },

    // 2️⃣ هنا أضف الـ onCreateWindow
    onCreateWindow: (controller, createWindowAction) async {
      final url = createWindowAction.request.url;
      if (url != null) {
        await controller.loadUrl(
          urlRequest: URLRequest(url: url),
        );
      }
      return true;
    },

    shouldOverrideUrlLoading: (controller, navigationAction) async {
      return NavigationActionPolicy.ALLOW;
    },
    onReceivedError: (controller, request, error) {
      print('WebView error: ${error.type} - ${error.description}');
      _showErrorDialog('Failed to load page: ${error.description}');
    },
  ),
),
          ],
        ),
      ),
    );
  }
}