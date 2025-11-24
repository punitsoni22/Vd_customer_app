import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vd_customer_app/core/theme/colors.dart';
import 'package:vd_customer_app/core/utils/common_widgets/common_appbar.dart';
import 'package:vd_customer_app/widget/snack_bar.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  File? _localPdfFile;
  PdfController? _pdfController;
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(widget.invoiceUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final fileName = '${widget.invoiceNumber}.pdf';
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        _localPdfFile = file;
        try {
          _pdfController = PdfController(
            document: PdfDocument.openFile(filePath),
          );
        } catch (e) {
          _pdfController = null;
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
      if (mounted)
        MySnackBar.showSnackBar(context, 'Error loading invoice: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareInvoice() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      File? fileToShare = _localPdfFile;
      if (fileToShare == null) {
        final response = await http.get(Uri.parse(widget.invoiceUrl));
        if (response.statusCode == 200) {
          final directory = await getTemporaryDirectory();
          final fileName = '${widget.invoiceNumber}.pdf';
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          fileToShare = file;
        } else {
          if (mounted) {
            MySnackBar.showSnackBar(
              context,
              'Failed to load invoice: ${response.statusCode}',
            );
          }
        }
      }

      if (fileToShare != null) {
        final result = await Share.shareXFiles(
          [XFile(fileToShare.path)],
          text: 'Invoice ${widget.invoiceNumber}',
          subject: widget.invoiceNumber,
        );

        if (mounted) {
          if (result.status == ShareResultStatus.success) {
            MySnackBar.showSnackBar(context, 'Invoice shared successfully');
          }
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
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AllColors.olivegreenColor,
                ),
              ),
            )
          else if (_localPdfFile != null && _pdfController != null)
            PdfView(controller: _pdfController!)
          else if (_localPdfFile != null)
            Center(
              child: Text(
                'Unable to open invoice file',
                style: TextStyle(color: Colors.red.shade700),
              ),
            )
          else
            Center(
              child: Text(
                'Unable to load invoice',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          if (_isDownloading)
            Positioned(
              top: 12,
              right: 12,
              child: SizedBox(
                width: 28.w,
                height: 28.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AllColors.olivegreenColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }
}
