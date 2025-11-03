import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          /// 🔹 **First Row (Level & XP)**
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildStat(Icons.bar_chart, "Level", "42")),
              Expanded(child: _buildStat(Icons.bolt, "XP", "18,950")),
            ],
          ),
          const Divider(color: Colors.white24, thickness: 0.5, height: 20),

          /// 🔹 **Second Row (Rank & Bee Currency)**
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildStat(Icons.emoji_events, "Rank", "Legend")),
              Expanded(child: _buildCustomStat("assets/icons/bee.png", "Bee", "1,250")), // 🐝 **Custom Bee Icon**
            ],
          ),
        ],
      ),
    );
  }

  /// 🔢 **Stat Builder with Built-in Icons**
  Widget _buildStat(IconData icon, String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.amber.shade700, size: 22), // ✅ Adjusted icon size
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.amber), // ✅ Reduced size
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70), // ✅ Slightly smaller
        ),
      ],
    );
  }

  /// 🐝 **Stat Builder with Custom Bee Icon**
  Widget _buildCustomStat(String imagePath, String title, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(imagePath, height: 22, width: 22, color: Colors.amber.shade700), // ✅ Smaller Custom Bee Icon
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.amber), // ✅ Reduced size
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70), // ✅ Adjusted size
        ),
      ],
    );
  }
}
