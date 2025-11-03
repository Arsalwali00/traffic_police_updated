import 'package:flutter/material.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'package:GBPayUsers/features/home/presenter/VoucherPresenter.dart';
import 'package:GBPayUsers/features/home/model/voucher_model.dart';
import 'package:GBPayUsers/core/local_storage.dart';

class GeneratedVouchersScreen extends StatefulWidget {
  const GeneratedVouchersScreen({super.key});

  @override
  _GeneratedVouchersScreenState createState() => _GeneratedVouchersScreenState();
}

class _GeneratedVouchersScreenState extends State<GeneratedVouchersScreen> {
  bool _isLoading = true;
  bool _isDeleting = false;
  List<VoucherData> _vouchers = [];
  String? _errorMessage;
  final VoucherPresenter _voucherPresenter = VoucherPresenter();

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<VoucherData>? vouchers = await _voucherPresenter.getGeneratedVouchers();
      if (vouchers != null) {
        setState(() {
          _vouchers = vouchers;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load vouchers. Please check your login status.";
        });
        if (await LocalStorage.getToken() == null) {
          _navigateToLogin();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching vouchers: $e";
      });
      print("Error fetching vouchers: $e");
      if (e.toString().contains("401")) {
        _navigateToLogin();
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToLogin() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.login,
          (route) => false,
    );
  }

  Future<Map<String, dynamic>?> _showConfirmationDialog(String citizenName, String psid) async {
    TextEditingController remarkController = TextEditingController();
    String? remarkError;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Delete Request',
                style: TextStyle(color: Colors.black),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Are you sure you want to generate a delete request for:',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Name: $citizenName',
                      style: const TextStyle(color: Colors.black),
                    ),
                    Text(
                      'PSID: $psid',
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Remarks:*',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextField(
                      controller: remarkController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(),
                        hintText: 'Enter your remarks here (required)',
                        hintStyle: const TextStyle(color: Colors.black54),
                        errorText: remarkError,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      style: const TextStyle(color: Colors.black),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                ),
                _isDeleting
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                )
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (remarkController.text.trim().isEmpty) {
                      setState(() {
                        remarkError = 'Remarks are required';
                      });
                      return;
                    }
                    Navigator.of(context).pop({
                      'confirmed': true,
                      'remarks': remarkController.text.trim(),
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _showFinalConfirmationDialog(String citizenName, String psid) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Confirmation',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete the voucher for $citizenName (PSID: $psid)?',
            style: const TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Confirm Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteVoucher(String psid, String remarks) async {
    try {
      setState(() => _isDeleting = true);
      bool success = await _voucherPresenter.deleteVoucher(
        psid: psid,
        remarks: remarks,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voucher deletion requested successfully'),
          ),
        );
        await _fetchVouchers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to request voucher deletion'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete voucher: $e')),
      );
    } finally {
      setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF379E4B)),
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchVouchers,
              child: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF379E4B),
              ),
            ),
          ],
        ),
      )
          : _vouchers.isEmpty
          ? const Center(
        child: Text(
          'No vouchers found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchVouchers,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _vouchers.length,
          itemBuilder: (context, index) {
            return _buildVoucherCard(_vouchers[index]);
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF379E4B)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Generated Vouchers",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildVoucherCard(VoucherData voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                voucher.citizenName ?? 'Unnamed Voucher',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                voucher.psid,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: ${voucher.dateTime}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Amount: Rs. ${voucher.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await _showConfirmationDialog(
                voucher.citizenName ?? 'Unnamed Voucher',
                voucher.psid,
              );
              if (result != null && result['confirmed'] == true) {
                final finalConfirmation = await _showFinalConfirmationDialog(
                  voucher.citizenName ?? 'Unnamed Voucher',
                  voucher.psid,
                );
                if (finalConfirmation == true) {
                  await _deleteVoucher(voucher.psid, result['remarks']);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Delete Request',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}