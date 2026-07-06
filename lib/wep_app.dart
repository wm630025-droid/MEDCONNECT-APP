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
  InAppWebViewController? _controller;
  double _progress = 0;
  Uri? _initialUrl;

  @override
  void initState() {
    super.initState();
    _initialUrl = Uri.tryParse(widget.url);
    if (_initialUrl == null || !_initialUrl!.hasScheme) {
      if (widget.url.isNotEmpty) {
        final httpsUrl = Uri.tryParse('https://${widget.url}');
        if (httpsUrl != null && httpsUrl.hasScheme) {
          _initialUrl = httpsUrl;
        }
      }
    }

    if (_initialUrl == null || !_initialUrl!.hasScheme) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showInvalidUrlDialog();
      });
    }
  }

  Future<void> _showInvalidUrlDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invalid URL'),
        content: const Text('The payment link is invalid and cannot be opened.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop(false);
  }

  Future<void> _checkForSuccess() async {
    try {
      final result = await _controller?.evaluateJavascript(source: '''
        (function() {
          var text = document.body.innerText || '';
          if (
            text.includes('Payment Successful!') ||
            text.includes('Payment Success') ||
            text.includes('Successfully Paid') ||
            text.includes('Transaction Successful')
          ) {
            return 'success';
          }
          if (
            text.includes('Payment Failed') ||
            text.includes('Transaction Failed') ||
            text.includes('Payment Unsuccessful')
          ) {
            return 'failed';
          }
          return 'not_found';
        })()
      ''');

      print('📄 Success check result: $result');

      if (result == 'success') {
        if (mounted) Navigator.of(context).pop(true);
      } else if (result == 'failed') {
        if (mounted) Navigator.of(context).pop(false);
      }
    } catch (e) {
      print('❌ JS error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 1.0)
            LinearProgressIndicator(value: _progress),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(
               // url:WebUri.uri(_initialUrl!) ,
               url:_initialUrl,
              ),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                  userAgent: 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
                ),
                android: AndroidInAppWebViewOptions(
                  supportMultipleWindows: true,
                ),
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onProgressChanged: (controller, progress) {
                if (mounted) setState(() => _progress = progress / 100);
              },
              onLoadStop: (controller, url) async {
                print('📄 Page finished: $url');
                await _checkForSuccess();
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url.toString();
                print('🔗 Navigating to: $url');

                if (url.startsWith('myapp://payment-success') ||
                    url.contains('payment-success')) {
                  if (mounted) Navigator.of(context).pop(true);
                  return NavigationActionPolicy.CANCEL;
                }

                if (url.startsWith('myapp://payment-failed') ||
                    url.contains('payment-failed')) {
                  if (mounted) Navigator.of(context).pop(false);
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
             onLoadError: (controller, url, code, message) {
  print('WebView error: $code - $message');
},
            ),
          ),
        ],
      ),
    );
  }
}