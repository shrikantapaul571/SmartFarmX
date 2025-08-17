import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class FarmDetailsScreen extends StatelessWidget {
  const FarmDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> farm = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final user = FirebaseAuth.instance.currentUser;
    final dbRef = FirebaseDatabase.instance.ref();

    return Scaffold(
      appBar: AppBar(
        title: Text(farm['name'] ?? 'Farm Details'),
        backgroundColor: Colors.green,
      ),
      body: user == null
          ? const Center(child: Text("Not logged in"))
          : StreamBuilder(
              stream: dbRef.child('users/${user.uid}/farms/${farm['id']}/sensors').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.exists) {
                  final sensorData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: sensorData.entries.map((entry) {
                      final sensorName = entry.value['name'] ?? entry.key;
                      final value = entry.value['value'];
                      final history = (entry.value['history'] ?? []) as List<dynamic>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📊 $sensorName", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                titlesData: FlTitlesData(show: false),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: history.asMap().entries.map((e) {
                                      final y = (e.value as num?)?.toDouble() ?? 0;
                                      return FlSpot(e.key.toDouble(), y);
                                    }).toList(),
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 2,
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  );
                } else {
                  return const Center(child: Text("No sensor data found."));
                }
              },
            ),
    );
  }
}
