import 'package:flutter/material.dart';
import 'package:GBPayUsers/features/home/model/voucher_model.dart';
import 'package:GBPayUsers/features/bills/view/bill_detail.dart';

class VoucherList extends StatelessWidget {
  final List<VoucherData> vouchers;
  final String? dateRangeText; // Optional parameter for dynamic date range

  const VoucherList({super.key, required this.vouchers, this.dateRangeText});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Explicit white background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateRangeText ?? "Recently Generated Vouchers", // Use dateRangeText if provided, else default
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12), // Space between header and list
          ListView.builder(
            shrinkWrap: true, // Sizes to content
            physics: const NeverScrollableScrollPhysics(), // No internal scrolling
            itemCount: vouchers.length, // Show all vouchers
            itemBuilder: (context, index) {
              return _buildVoucherBox(context, vouchers[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherBox(BuildContext context, VoucherData voucher) {
    final bool isPaid = voucher.isPaid == true || voucher.isPaid == 1;
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
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Name", voucher.citizenName),
            const SizedBox(height: 8),
            _buildDetailRow("Bill Date", formattedMonthYear),
            const SizedBox(height: 8),
            _buildDetailRow("Payable Amount", " ${voucher.amount.toStringAsFixed(2)}"),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Status: $statusText",
                style: TextStyle(
                  color: isPaid ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}