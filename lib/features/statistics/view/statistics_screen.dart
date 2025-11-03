// statistics_screen.dart
import 'package:flutter/material.dart';
import 'package:GBPayUsers/features/statistics/model/statistics_model.dart';
import 'package:GBPayUsers/features/statistics/presenter/statistics_presenter.dart';

class StatisticsScreen extends StatefulWidget {
  final Color dynamicColor; // Add dynamicColor for consistency with HomeScreen
  const StatisticsScreen({super.key, required this.dynamicColor});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsPresenter _presenter = StatisticsPresenter();
  StatisticsModel? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatistics();
  }

  Future<void> _fetchStatistics() async {
    setState(() => _isLoading = true);
    final stats = await _presenter.getStatistics();
    setState(() {
      _statistics = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(''), // Empty title as per previous request
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.dynamicColor),
        ),
      )
          : _statistics == null
          ? Center(child: Text("Failed to load statistics. Please try again."))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Yearly Collection",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              key: ValueKey(_statistics), // Force rebuild on data change
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDashboardCard(
                  title: "Total Vouchers",
                  value: _statistics?.totalVouchers.toStringAsFixed(0) ?? '0', // Remove PKR. prefix
                  icon: Icons.receipt_long,
                  color: widget.dynamicColor,
                ),
                _buildDashboardCard(
                  title: "Paid Amount",
                  value: "PKR. ${_statistics?.paidAmount.toStringAsFixed(0) ?? '0'}",
                  icon: Icons.check_circle_outline,
                  color: widget.dynamicColor,
                ),
                _buildDashboardCard(
                  title: "Unpaid Amount",
                  value: "PKR. ${_statistics?.unpaidAmount.toStringAsFixed(0) ?? '0'}",
                  icon: Icons.cancel_outlined,
                  color: widget.dynamicColor,
                ),
                _buildDashboardCard(
                  title: "Today Collection",
                  value: "PKR. ${_statistics?.todaysCollection.toStringAsFixed(0) ?? '0'}",
                  icon: Icons.account_balance_wallet_outlined,
                  color: widget.dynamicColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Icon(
                icon,
                color: color.withOpacity(0.2),
                size: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}