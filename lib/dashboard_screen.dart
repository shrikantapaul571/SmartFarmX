import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true, // ✅ Center the title
        title: const Text("Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.person), // ✅ Profile on the left
          tooltip: 'Profile',
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
            ), // ✅ Notifications on the right
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),

      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef.child('users/${user!.uid}/farms').onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                "👋 Welcome to SmartFarmX!\nPlease add your farm for monitoring.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final data = snapshot.data!.snapshot.value as Map;
          final farms = data.entries.map<Map<String, dynamic>>((e) {
            final farm = Map<String, dynamic>.from(e.value);
            farm['id'] = e.key; // add ID for navigation
            return farm;
          }).toList();

          return ListView.builder(
            itemCount: farms.length,
            itemBuilder: (context, index) {
              return buildFarmCard(farms[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/add-farm');
        },
      ),
    );
  }

  Widget buildFarmCard(Map<String, dynamic> farm) {
    final sensors = Map<String, dynamic>.from(farm['sensors'] ?? {});
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/farm-details',
          arguments: {'userId': user!.uid, 'farmId': farm['id']},
        );
      },
      child: Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                farm['name'] ?? 'Unnamed Farm',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("📍 ${farm['location'] ?? 'No Location'}"),
              const SizedBox(height: 8),
              ...sensors.entries.map((entry) {
                final sensorName = entry.value['name'] ?? entry.key;
                final value = entry.value['value'];
                return Text("🔹 $sensorName: $value");
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
