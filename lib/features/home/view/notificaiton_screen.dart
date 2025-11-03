import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItemModel> notifications = [
    NotificationItemModel(image: "assets/images/users/user1.png", name: "Jane Cooper", message: "Just added a room.", time: "2m", isUnread: true),
    NotificationItemModel(image: "assets/images/users/user2.jpg", name: "David", message: "Commented on your review.", time: "5m", isUnread: true),
    NotificationItemModel(image: "assets/images/users/user3.png", name: "Theresa", message: "Asking for a review.", time: "8m", isUnread: true),
    NotificationItemModel(image: "assets/images/users/user4.png", name: "Marvin", message: "Commented on your review.", time: "30m", isUnread: true),
    NotificationItemModel(image: "assets/images/users/user5.png", name: "Devon Lane", message: "Commented on your review.", time: "44m"),
    NotificationItemModel(image: "assets/images/users/user6.png", name: "Eleanor Pena", message: "Asking for a review.", time: "1h"),
    NotificationItemModel(image: "assets/images/users/user7.png", name: "Kathryn", message: "Replied to your review.", time: "2h"),
    NotificationItemModel(image: "assets/images/users/user8.png", name: "Ronald", message: "Asking for a review.", time: "3h"),
    NotificationItemModel(image: "assets/images/users/user9.png", name: "Samantha", message: "Started following you.", time: "5h"),
    NotificationItemModel(image: "assets/images/users/user10.png", name: "Jake", message: "Liked your post.", time: "7h"),
    NotificationItemModel(image: "assets/images/users/user11.png", name: "Chris Evans", message: "Sent you a message.", time: "9h", isUnread: true),
    NotificationItemModel(image: "assets/images/users/user12.png", name: "Emma Watson", message: "Tagged you in a comment.", time: "11h"),
    NotificationItemModel(image: "assets/images/users/user13.png", name: "Robert Downey", message: "Invited you to an event.", time: "12h"),
    NotificationItemModel(image: "assets/images/users/user14.png", name: "Selena Gomez", message: "Shared a post with you.", time: "15h"),
    NotificationItemModel(image: "assets/images/users/user15.png", name: "Tom Holland", message: "Reacted to your story.", time: "18h", isUnread: true),
  ];

  /// 🔄 Mark All as Read
  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isUnread = false;
      }
    });
  }

  /// ✅ Mark a Single Notification as Read
  void _markAsRead(int index) {
    setState(() {
      notifications[index].isUnread = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // ✅ Dark theme applied
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber), // ✅ Amber back button
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black, // ✅ Dark background applied
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 Header: "All" & "Mark all as read"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "All",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: const Text("Mark all as read", style: TextStyle(color: Colors.amber)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// 🔔 Notifications List (Card Style)
              Column(
                children: List.generate(
                  notifications.length,
                      (index) => GestureDetector(
                    onTap: () => _markAsRead(index),
                    child: NotificationCard(notification: notifications[index]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Model for Notifications
class NotificationItemModel {
  final String image;
  final String name;
  final String message;
  final String time;
  bool isUnread;

  NotificationItemModel({
    required this.image,
    required this.name,
    required this.message,
    required this.time,
    this.isUnread = false,
  });
}

/// 📌 Card-Style Notification UI
class NotificationCard extends StatelessWidget {
  final NotificationItemModel notification;

  const NotificationCard({required this.notification, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // ✅ Adds shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      color: notification.isUnread ? Colors.amber.shade700.withOpacity(0.2) : Colors.black, // ✅ Highlight unread messages
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// 🖼 User Avatar
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(notification.image),
            ),
            const SizedBox(width: 12),

            /// 📄 Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    notification.message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            /// ⏳ Time + Unread Indicator
            Column(
              children: [
                Text(notification.time, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                if (notification.isUnread)
                  const Icon(Icons.circle, color: Colors.amber, size: 10), // ✅ Amber dot for unread messages
              ],
            ),
          ],
        ),
      ),
    );
  }
}
