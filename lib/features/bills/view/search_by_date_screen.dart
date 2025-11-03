import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/features/home/presenter/VoucherPresenter.dart';
import 'package:GBPayUsers/features/home/model/voucher_model.dart';
import 'package:GBPayUsers/features/bills/view/voucher_list.dart';

class SearchByDateScreen extends StatefulWidget {
  const SearchByDateScreen({super.key});

  @override
  _SearchByDateScreenState createState() => _SearchByDateScreenState();
}

class _SearchByDateScreenState extends State<SearchByDateScreen> {
  DateTime? _dateFrom;
  late DateTime _dateTo;
  bool _isLoading = false;
  List<VoucherData>? _vouchers;
  String? _dateRangeText;
  final VoucherPresenter _voucherPresenter = VoucherPresenter();
  Color _dynamicColor = const Color(0xFF379E4B); // Default color

  @override
  void initState() {
    super.initState();
    _dateTo = DateTime.now();
    _fetchDynamicColor();
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
            _dynamicColor = const Color(0xFF379E4B); // Fallback to default
          }
        });
      }
    } catch (e) {
      print("Error fetching user data for color: $e");
      if (mounted) {
        setState(() {
          _dynamicColor = const Color(0xFF379E4B); // Fallback to default
        });
      }
    }
  }

  Future<void> _selectDateFrom() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? _dateTo,
      firstDate: DateTime(2000),
      lastDate: _dateTo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: _dynamicColor,
              headerForegroundColor: Colors.white,
              dayStyle: const TextStyle(color: Colors.black),
              rangeSelectionBackgroundColor: _dynamicColor.withOpacity(0.3),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _dynamicColor;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.withOpacity(0.5);
                }
                return Colors.black.withOpacity(0.7);
              }),
            ),
            colorScheme: ColorScheme.light(
              primary: _dynamicColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _dynamicColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _dateFrom) {
      setState(() {
        _dateFrom = pickedDate;
      });
    }
  }

  Future<void> _selectDateTo() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTo,
      firstDate: _dateFrom ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: _dynamicColor,
              headerForegroundColor: Colors.white,
              dayStyle: const TextStyle(color: Colors.black),
              rangeSelectionBackgroundColor: _dynamicColor.withOpacity(0.3),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _dynamicColor;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                if (states.contains(WidgetState.disabled)) {
                  return Colors.grey.withOpacity(0.5);
                }
                return Colors.black.withOpacity(0.7);
              }),
            ),
            colorScheme: ColorScheme.light(
              primary: _dynamicColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _dynamicColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _dateTo) {
      setState(() {
        _dateTo = pickedDate;
        if (_dateFrom != null && _dateFrom!.isAfter(_dateTo)) {
          _dateFrom = null;
        }
      });
    }
  }

  Future<void> _searchByDateRange() async {
    if (_dateFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select "Date From".'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _vouchers = null;
    });

    String dateFromStr = "${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}";
    String dateToStr = "${_dateTo.year}-${_dateTo.month.toString().padLeft(2, '0')}-${_dateTo.day.toString().padLeft(2, '0')}";

    List<VoucherData>? vouchers = await _voucherPresenter.getVouchersByDateRange(
      dateFrom: dateFromStr,
      dateTo: dateToStr,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _vouchers = vouchers;
      String displayDateFrom = "${_dateFrom!.day.toString().padLeft(2, '0')}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.year}";
      String displayDateTo = "${_dateTo.day.toString().padLeft(2, '0')}-${_dateTo.month.toString().padLeft(2, '0')}-${_dateTo.year}";
      _dateRangeText = "Date: $displayDateFrom - $displayDateTo";
    });

    if (vouchers == null || vouchers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No vouchers found for this date range.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Search by Date",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Date From",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDateFrom,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: _dynamicColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateFrom == null
                            ? "Pick a start date"
                            : "${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}",
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      Icon(Icons.calendar_today, color: _dynamicColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Date To",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectDateTo,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: _dynamicColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_dateTo.day}/${_dateTo.month}/${_dateTo.year}",
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      Icon(Icons.calendar_today, color: _dynamicColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _searchByDateRange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dynamicColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_vouchers != null && _vouchers!.isNotEmpty)
                VoucherList(
                  vouchers: _vouchers!,
                  dateRangeText: _dateRangeText,
                )
              else if (_vouchers != null && _vouchers!.isEmpty)
                const Center(child: Text("No vouchers found."))
            ],
          ),
        ),
      ),
    );
  }
}