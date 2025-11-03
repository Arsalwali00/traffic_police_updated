import 'package:flutter/material.dart';

class ProfileAchievements extends StatelessWidget {
  const ProfileAchievements({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🏅 Achievements",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _buildAchievement("Elite Sniper", "100 Headshots", Icons.emoji_events),
          _buildAchievement("Survivor", "Played 500 Matches", Icons.shield),
          _buildAchievement("Top 1%", "Reached Top 100 in Rankings", Icons.star),
        ],
      ),
    );
  }

  /// 🏅 **Achievement Builder**
  Widget _buildAchievement(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber.shade700, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
      ),
    );
  }
}
