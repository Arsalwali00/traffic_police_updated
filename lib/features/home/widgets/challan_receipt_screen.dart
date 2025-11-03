import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:GBPayUsers/features/home/model/challan_receipt_model.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/config/api.dart';
import 'package:http/http.dart' as http;


class ChallanReceiptScreen extends StatefulWidget {
  final ChallanReceiptModel receipt;

  const ChallanReceiptScreen({super.key, required this.receipt});

  @override
  _ChallanReceiptScreenState createState() => _ChallanReceiptScreenState();
}

class _ChallanReceiptScreenState extends State<ChallanReceiptScreen> {
  bool _isLoading = false;

  Future<pw.Document> _generateReceiptPdf() async {
    final pdf = pw.Document();

    String department = 'Department';
    String district = 'N/A';
    String userName = 'N/A';
    pw.MemoryImage? logoImage;
    try {
      Map<String, dynamic>? userData = await LocalStorage.getUser();
      if (userData != null) {
        department = userData['department'] ?? 'Department';
        district = userData['district'] ?? 'N/A';
        userName = userData['name'] ?? 'N/A';
        if (userData['department_logo'] != null) {
          String logoUrl = userData['department_logo'];
          if (!logoUrl.startsWith('http')) {
            logoUrl = "${ApiConfig.assetBaseUrl}/$logoUrl";
          }
          final response = await http.get(Uri.parse(logoUrl));
          if (response.statusCode == 200) {
            logoImage = pw.MemoryImage(response.bodyBytes);
          } else {
            print('Error fetching department logo: HTTP ${response.statusCode}');
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat(48 * PdfPageFormat.mm, 100 * PdfPageFormat.mm),
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  logoImage != null
                      ? pw.Image(logoImage, width: 40, height: 40)
                      : pw.Text(
                    department,
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          department,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          district != 'N/A' ? 'District $district' : 'N/A',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 7,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              _buildPdfDetailRow('PSID', widget.receipt.psid,
                  fontSize: 8, isBold: true),
              pw.SizedBox(height: 8),
              _buildPdfDetailRow('Head of Account', widget.receipt.headOfAccount,
                  fontSize: 8, valueIsBold: true),
              _buildPdfDetailRow('Name', _capitalizeWords(widget.receipt.consumerDetails),
                  fontSize: 8),
              _buildPdfDetailRow('Date', widget.receipt.dateTime,
                  fontSize: 8),
              _buildPdfDetailRow(
                  'Description',
                  widget.receipt.description.isNotEmpty
                      ? widget.receipt.description
                      : 'No Description Available',
                  fontSize: 8,
                  valueIsBold: true),
              if (widget.receipt.vehicleNumber != null &&
                  widget.receipt.vehicleNumber!.isNotEmpty)
                _buildPdfDetailRow('Vehicle Number', widget.receipt.vehicleNumber!,
                    fontSize: 8),
              _buildPdfDetailRow('Total Amount',
                  'PKR ${widget.receipt.amount.toStringAsFixed(2)}',
                  fontSize: 8, isBold: true),
              _buildPdfDetailRow('Amount in Words', widget.receipt.amountInWords,
                  fontSize: 8, valueIsBold: true),
              pw.SizedBox(height: 4),
              pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: widget.receipt.psid.isNotEmpty ? widget.receipt.psid : 'N/A',
                width: double.infinity,
                height: 30,
                drawText: false,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Field Officer: $userName',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 6,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Pay using PSID via 1-Bill in digital banking, ATM, or bank counter.',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 6,
                  fontStyle: pw.FontStyle.italic,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf;
  }

  Future<void> _shareReceipt() async {
    setState(() => _isLoading = true);
    try {
      final pdf = await _generateReceiptPdf();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/challan_receipt_${widget.receipt.psid}.pdf');
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Challan Receipt - PSID: ${widget.receipt.psid}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share receipt: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printReceipt() async {
    setState(() => _isLoading = true);
    try {
      final pdf = await _generateReceiptPdf();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print receipt: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReceiptAsPdf() async {
    setState(() => _isLoading = true);
    try {
      final pdf = await _generateReceiptPdf();
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/challan_receipt_${widget.receipt.psid}.pdf');
      await file.writeAsBytes(await pdf.save());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  pw.Widget _buildPdfDetailRow(String label, String value,
      {bool isBold = false, double fontSize = 14, bool valueIsBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      // Modified condition to exclude "Vehicle Number" from Column layout
      child: label == "Head of Account" ||
          label == "Description" ||
          label == "Amount in Words"
          ? pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value.isNotEmpty ? value : 'N/A',
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: valueIsBold
                  ? pw.FontWeight.bold
                  : (isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
        ],
      )
          : pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value.isNotEmpty ? value : 'N/A',
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: valueIsBold
                  ? pw.FontWeight.bold
                  : (isBold ? pw.FontWeight.bold : pw.FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.receipt.psid.isEmpty) {
      return Scaffold(
        body: const Center(child: Text('Invalid receipt: PSID is missing')),
      );
    }

    final fontSize = MediaQuery.of(context).size.width * 0.035;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<Map<String, dynamic>?>(
                        future: LocalStorage.getUser(),
                        builder: (context, snapshot) {
                          String department = 'Department';
                          ImageProvider? departmentLogo;
                          if (snapshot.hasData &&
                              snapshot.data != null &&
                              snapshot.data!['department_logo'] != null) {
                            String logoUrl = snapshot.data!['department_logo'];
                            if (!logoUrl.startsWith('http')) {
                              logoUrl = "${ApiConfig.assetBaseUrl}/$logoUrl";
                            }
                            departmentLogo = NetworkImage(logoUrl);
                            department = snapshot.data!['department'] ?? 'Department';
                          }
                          return CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade300,
                            child: ClipOval(
                              child: departmentLogo != null
                                  ? Image(
                                image: departmentLogo,
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                      department,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                              )
                                  : Text(
                                department,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: LocalStorage.getUser(),
                        builder: (context, snapshot) {
                          String department = 'Department';
                          String district = 'N/A';
                          if (snapshot.hasData && snapshot.data != null) {
                            department = snapshot.data!['department'] ?? 'Department';
                            district = snapshot.data!['district'] ?? 'N/A';
                          }
                          return Expanded(
                            child: Column(
                              children: [
                                Text(
                                  department,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  district != 'N/A' ? 'District $district' : 'N/A',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _buildDetailRow("PSID", widget.receipt.psid, isBold: true, fontSize: fontSize),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow("Head of Account", widget.receipt.headOfAccount,
                          valueIsBold: true, fontSize: fontSize),
                      _buildDetailRow("Name",
                          _capitalizeWords(widget.receipt.consumerDetails),
                          fontSize: fontSize),
                      _buildDetailRow("Date", widget.receipt.dateTime,
                          fontSize: fontSize),
                      _buildDetailRow(
                          "Description",
                          widget.receipt.description.isNotEmpty
                              ? widget.receipt.description
                              : 'No Description Available',
                          valueIsBold: true,
                          fontSize: fontSize),
                      if (widget.receipt.vehicleNumber != null &&
                          widget.receipt.vehicleNumber!.isNotEmpty)
                        _buildDetailRow("Vehicle Number", widget.receipt.vehicleNumber!,
                            fontSize: fontSize),
                      const SizedBox(height: 8),
                      _buildDetailRow("Total Amount",
                          "PKR ${widget.receipt.amount.toStringAsFixed(2)}",
                          isBold: true, fontSize: fontSize),
                      _buildDetailRow("Amount in Words", widget.receipt.amountInWords,
                          valueIsBold: true, fontSize: fontSize),
                      const SizedBox(height: 8),
                      BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: widget.receipt.psid.isNotEmpty ? widget.receipt.psid : 'N/A',
                        width: double.infinity,
                        height: 60,
                        color: Colors.black,
                        backgroundColor: Colors.white,
                        drawText: false,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: LocalStorage.getUser(),
                        builder: (context, snapshot) {
                          String userName = 'N/A';
                          if (snapshot.hasData && snapshot.data != null) {
                            userName = snapshot.data!['name'] ?? 'N/A';
                          }
                          return Text(
                            'Field Officer: $userName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pay this bill using the PSID via the 1 Bill option in your digital banking app, at an ATM, or over the counter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize * 0.8,
                          color: Colors.black,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildIconButton(Icons.share, "Share", _shareReceipt, sizeMultiplier: 1.2),
                          _buildIconButton(Icons.print, "Print", _printReceipt, sizeMultiplier: 3.0),
                          _buildIconButton(
                              Icons.picture_as_pdf, "Save as PDF", _saveReceiptAsPdf, sizeMultiplier: 1.2),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  String _capitalizeWords(String input) {
    return input
        .split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? color, bool valueIsBold = false, required double fontSize}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      // Modified condition to exclude "Vehicle Number" from Column layout
      child: label == "Head of Account" ||
          label == "Description" ||
          label == "Amount in Words"
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: valueIsBold
                  ? FontWeight.bold
                  : (isBold ? FontWeight.bold : FontWeight.normal),
              color: color ?? Colors.black,
            ),
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: valueIsBold
                    ? FontWeight.bold
                    : (isBold ? FontWeight.bold : FontWeight.normal),
                color: color ?? Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String text, VoidCallback onPressed, {double sizeMultiplier = 1.0}) {
    return GestureDetector(
      onTap: _isLoading ? null : onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20 * sizeMultiplier,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10 * sizeMultiplier,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}