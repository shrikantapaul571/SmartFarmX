import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditSensorScreen extends StatefulWidget {
  const EditSensorScreen({super.key});

  @override
  State<EditSensorScreen> createState() => _EditSensorScreenState();
}

class _EditSensorScreenState extends State<EditSensorScreen> {
  List<Map<String, String>> sensors = [];
  late String farmName;
  late String farmLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      // Handles list of strings like ['Temperature', 'Humidity']
      sensors = (args['sensors'] as List)
          .map<Map<String, String>>(
            (e) => {'name': e.toString(), 'location': ''},
          )
          .toList();

      farmName = args['name'];
      farmLocation = args['location'];
    }
  }

  void _editSensor(int index) {
    final nameController = TextEditingController(text: sensors[index]['name']);
    final locationController = TextEditingController(text: sensors[index]['location']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Sensor"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Sensor Name"),
            ),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: "Sensor Location"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                sensors[index]['name'] = nameController.text.trim();
                sensors[index]['location'] = locationController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndGoToDashboard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref().child('users/${user.uid}/farms');

    final Map<String, dynamic> sensorData = {};
    final random = Random();

    for (var sensor in sensors) {
      final name = sensor['name']!;
      final location = sensor['location'] ?? '';
      final key = name.toLowerCase().replaceAll(' ', '_');

      String value;
      switch (key) {
        case 'temperature':
          value = "${(20 + random.nextInt(10) + random.nextDouble()).toStringAsFixed(1)}°C";
          break;
        case 'humidity':
          value = "${(50 + random.nextInt(30))}%";
          break;
        case 'ldr':
          value = "${(300 + random.nextInt(300))} lux";
          break;
        case 'moisture':
        case 'soil_moisture':
          value = "${(300 + random.nextInt(150))}";
          break;
        case 'pir':
          value = random.nextBool() ? "Detected" : "Not Detected";
          break;
        case 'ph':
          value = (5.5 + random.nextDouble() * 2).toStringAsFixed(1);
          break;
        default:
          value = "N/A";
      }

      sensorData[key] = {
        'name': name,
        'location': location,
        'value': value,
      };
    }

    final Map<String, dynamic> farmData = {
      'name': farmName,
      'location': farmLocation,
      'sensors': sensorData,
    };

    await dbRef.push().set(farmData);

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFE7),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(farmName.toUpperCase()),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Farm has been successfully created!",
              style: TextStyle(color: Colors.green.shade700),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: "Welcome to ",
                children: [
                  TextSpan(
                    text: farmName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ",\nlocated at "),
                  TextSpan(
                    text: farmLocation,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        ".\n\nNow, edit your sensor details and connect them to start monitoring your farm.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sensors.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(sensors[index]['name'] ?? ''),
                      subtitle: Text(
                        sensors[index]['location']?.isEmpty == true
                            ? "No location set"
                            : "Location: ${sensors[index]['location']}",
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _editSensor(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                sensors.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _saveAndGoToDashboard,
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green.shade200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Icon(Icons.home),
            Icon(Icons.add),
          ],
        ),
      ),
    );
  }
}
