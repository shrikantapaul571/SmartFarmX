import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> notifications = [
      "New farm data available",
      "Sensor update successful",
      "Reminder: Check water levels",
    ]; // Replace with live Firebase data later if needed

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications_active),
            title: Text(notifications[index]),
          );
        },
      ),
    );
  }
}
