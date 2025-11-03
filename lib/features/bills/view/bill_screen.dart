import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/home/model/voucher_model.dart';
import 'package:GBPayUsers/features/home/presenter/VoucherPresenter.dart';
import 'package:GBPayUsers/features/bills/view/bill_detail.dart';
import 'package:GBPayUsers/features/bills/view/search_by_date_screen.dart';
import 'package:GBPayUsers/features/bills/view/voucher_list.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final TextEditingController _voucherController = TextEditingController();
  List<VoucherData>? _voucherData;
  List<VoucherData>? _generatedVouchers;
  bool _isLoading = false;
  String _errorMessage = "";
  final VoucherPresenter _voucherPresenter = VoucherPresenter();
  Color _dynamicColor = const Color(0xFF379E4B);

  @override
  void initState() {
    super.initState();
    _fetchDynamicColor();
    _fetchGeneratedVouchers();
  }

  Future<void> _fetchDynamicColor() async {
    try {
      Map<String, dynamic>? userData = await LocalStorage.getUser();
      if (userData != null && mounted) {
        setState(() {
          try {
            if (userData['color'] != null) {
              String colorString = userData['color'].toString();
              if (colorString.startsWith('0x')) {
                colorString = colorString.replaceFirst('0x', '');
              }
              _dynamicColor = Color(int.parse(colorString, radix: 16) | 0xFF000000);
            }
          } catch (e) {
            print("Error parsing color: $e");
            _dynamicColor = const Color(0xFF379E4B);
          }
        });
      }
    } catch (e) {
      print("Error fetching user data for color: $e");
      if (mounted) {
        setState(() {
          _dynamicColor = const Color(0xFF379E4B);
        });
      }
    }
  }

  Future<void> _fetchVoucher() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    String voucherNumber = _voucherController.text.trim();

    if (voucherNumber.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Please enter a voucher number.";
      });
      return;
    }

    try {
      VoucherResponse? response = await _voucherPresenter.getVoucher(voucherNumber);

      if (!mounted) return;
      if (response != null && response.status && response.data != null && response.data!.isNotEmpty) {
        setState(() {
          _voucherData = response.data;
          _isLoading = false;
          debugPrint('Vouchers fetched: ${_voucherData?.length}');
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "No vouchers found.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching vouchers: $e";
      });
    }
  }

  Future<void> _fetchGeneratedVouchers() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = "";
      _voucherData = null;
      _generatedVouchers = null;
      _voucherController.clear();
    });

    try {
      List<VoucherData>? vouchers = await _voucherPresenter.getGeneratedVouchers();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _generatedVouchers = vouchers;
        if (vouchers != null && vouchers.isNotEmpty) {
          debugPrint('Generated vouchers fetched: ${vouchers.length}');
        } else {
          _errorMessage = "No generated vouchers found.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Error fetching generated vouchers: $e";
      });
    }
  }

  void _navigateToSearchByDate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchByDateScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchGeneratedVouchers,
        color: _dynamicColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: _dynamicColor))
                    : _errorMessage.isNotEmpty
                    ? Text(_errorMessage, style: const TextStyle(color: Colors.red))
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_voucherData != null && _voucherData!.isNotEmpty)
                      VoucherList(
                        vouchers: _voucherData!,
                        dateRangeText: "Vouchers Found",
                      ),
                    if (_generatedVouchers != null && _generatedVouchers!.isNotEmpty)
                      VoucherList(
                        vouchers: _generatedVouchers!,
                        dateRangeText: "Recently Generated Vouchers",
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Bills",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Search Voucher",
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _voucherController,
                style: const TextStyle(color: Colors.black, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "PSID,Vehicle Number , Name ,CNIC",
                  hintStyle: const TextStyle(color: Colors.black38),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: _buildBorder(_dynamicColor),
                  enabledBorder: _buildBorder(_dynamicColor),
                  focusedBorder: _buildBorder(_dynamicColor, width: 2.0),
                  suffixIcon: _buildSearchButton(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _dynamicColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: _navigateToSearchByDate,
              ),
            ),
          ],
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _dynamicColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            final input = _voucherController.text.trim();
            if (input.isEmpty) {
              setState(() {
                _errorMessage = 'Please enter a voucher number.';
              });
              return;
            }
            _fetchVoucher();
          },
        ),
      ),
    );
  }

  Widget _buildVoucherDetails(VoucherData voucher) {
    final bool isPaid = voucher.isPaid == true || voucher.isPaid == 1;
    final Color? cardColor = isPaid ? Colors.green[700] : Colors.red[700];
    final String statusText = isPaid ? "Paid" : "Unpaid";
    String formattedMonthYear = "${voucher.billMonth} ${voucher.billYear}";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BillDetailScreen(voucher: voucher),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(30.0),
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 1.0),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -30,
              left: -30,
              child: Image.asset(
                'assets/images/card/rectangle_809.png',
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: -40,
              right: -50,
              child: Image.asset(
                'assets/images/card/ellipse_117.png',
                width: 150,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Name", voucher.citizenName),
                const SizedBox(height: 10),
                _buildDetailRow("Bill Date", formattedMonthYear),
                const SizedBox(height: 10),
                _buildDetailRow("Payable Amount", "${voucher.amount.toStringAsFixed(2)}"),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Status: $statusText",
                    style: TextStyle(
                      color: isPaid ? Colors.greenAccent : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }
}