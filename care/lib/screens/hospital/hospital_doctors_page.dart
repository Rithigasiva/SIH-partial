import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';

class HospitalDoctorsPage extends StatefulWidget {
  final Hospital hospital;
  const HospitalDoctorsPage({super.key, required this.hospital});

  @override
  State<HospitalDoctorsPage> createState() => _HospitalDoctorsPageState();
}

class _HospitalDoctorsPageState extends State<HospitalDoctorsPage> {
  final UserDataService _userDataService = UserDataService();

  // Re-usable delete logic
  void _deleteDoctor(Doctor doctor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete Dr. ${doctor.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _userDataService.deleteUser(doctor);
              setState(() {}); // Refresh the list
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch only the doctors for this specific hospital
    final doctorsInHospital = _userDataService.getDoctorsForHospital(widget.hospital.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors at ${widget.hospital.name}'),
      ),
      body: doctorsInHospital.isEmpty
          ? const Center(child: Text('No doctors have been registered for this hospital yet.'))
          : ListView.builder(
              itemCount: doctorsInHospital.length,
              itemBuilder: (context, index) {
                final doctor = doctorsInHospital[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(doctor.name),
                    subtitle: Text(doctor.specialist),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteDoctor(doctor),
                    ),
                  ),
                );
              },
            ),
    );
  }
}