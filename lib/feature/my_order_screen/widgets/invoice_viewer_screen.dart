import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

class InvoiceViewerScreen extends StatefulWidget {
  final String invoiceUrl;
  final String invoiceNumber;

  const InvoiceViewerScreen({
    super.key,
    required this.invoiceUrl,
    required this.invoiceNumber,
  });

  @override
  State<InvoiceViewerScreen> createState() => _InvoiceViewerScreenState();
}

class _InvoiceViewerScreenState extends State<InvoiceViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (kDebugMode) {
              print('WebView error: ${error.description}');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.invoiceUrl));
  }

  Future<void> _shareInvoice() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Download the file to temporary directory
      final response = await http.get(Uri.parse(widget.invoiceUrl));

      if (response.statusCode == 200) {
        // Use temporary directory (no permissions needed)
        final directory = await getTemporaryDirectory();
        final fileName = '${widget.invoiceNumber}.html';
        final filePath = '${directory.path}/$fileName';

        // Write the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Share the file using system share sheet
        final result = await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Invoice ${widget.invoiceNumber}',
          subject: widget.invoiceNumber,
        );

        if (mounted) {
          if (result.status == ShareResultStatus.success) {
            MySnackBar.showSnackBar(context, 'Invoice shared successfully');
          }
        }
      } else {
        if (mounted) {
          MySnackBar.showSnackBar(
            context,
            'Failed to load invoice: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        MySnackBar.showSnackBar(context, 'Error sharing invoice: $e');
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.invoiceNumber,
        showBack: true,
        titleAlignment: BarTitleAlignment.center,
        actions: [
          IconButton(
            icon: _isDownloading
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AllColors.olivegreenColor,
                      ),
                    ),
                  )
                : Icon(Icons.share, color: AllColors.olivegreenColor),
            onPressed: _isDownloading ? null : _shareInvoice,
            tooltip: 'Share Invoice',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AllColors.olivegreenColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
