import 'package:flutter/material.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final List<String> availableSensors = [
    'Temperature',
    'Humidity',
    'LDR',
    'Moisture',
    'pH',
    'PIR',
  ];

  List<String> selectedSensors = [];

  void _goToEditSensors() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(
        context,
        '/edit-sensors',
        arguments: {
          'name': _nameController.text.trim(),
          'location': _locationController.text.trim(),
          'sensors': selectedSensors,
        },
      );
    }
  }

  Widget _buildSensorChip(String sensor) {
    final isSelected = selectedSensors.contains(sensor);
    return FilterChip(
      label: Text(sensor),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            selectedSensors.add(sensor);
          } else {
            selectedSensors.remove(sensor);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFE7),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Add Farm"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Enter Farm Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Farm Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter farm name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Select Sensors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Wrap(
                spacing: 8,
                children: availableSensors.map(_buildSensorChip).toList(),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _goToEditSensors,
                icon: const Icon(Icons.navigate_next),
                label: const Text("Next"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
