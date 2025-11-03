import 'package:flutter/material.dart';
import 'package:GBPayUsers/core/local_storage.dart';
import 'package:GBPayUsers/config/routes.dart';
import 'package:GBPayUsers/features/security/view/security_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _darkMode = await LocalStorage.getBool("dark_mode") ?? false;
    _notificationsEnabled = await LocalStorage.getBool("notifications") ?? true;
    setState(() {});
  }

  Future<void> _updateSetting(String key, bool value) async {
    await LocalStorage.setBool(key, value);
    setState(() {});
  }

  void _logout() async {
    await LocalStorage.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          /// 🔹 **Profile Settings**
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile Settings"),
            subtitle: const Text("Update your name, email, and password"),
            onTap: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
          const Divider(),

          /// 🔹 **Security Settings**
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Security Settings"),
            subtitle: const Text("Manage PIN, fingerprint, and passwords"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  SecurityScreen()),
              );
            },
          ),
          const Divider(),

          /// 🔹 **Notifications Toggle**
          SwitchListTile(
            title: const Text("Enable Notifications"),
            subtitle: const Text("Receive updates and special offers"),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              _updateSetting("notifications", value);
              setState(() => _notificationsEnabled = value);
            },
            secondary: const Icon(Icons.notifications_active),
          ),
          const Divider(),

          /// 🔹 **Dark Mode Toggle**
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Reduce eye strain at night"),
            value: _darkMode,
            onChanged: (bool value) {
              _updateSetting("dark_mode", value);
              setState(() => _darkMode = value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const Divider(),

          /// 🔹 **Language Selection**
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Change Language"),
            subtitle: const Text("Select your preferred language"),
            onTap: () {
              // Implement Language Selection Logic
            },
          ),
          const Divider(),

          /// 🔹 **Logout**
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
