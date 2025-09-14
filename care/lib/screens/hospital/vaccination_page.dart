// File: lib/screens/hospital/vaccination_page.dart

import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';

class VaccinationPage extends StatelessWidget {
  final Patient patient;
  const VaccinationPage({super.key, required this.patient});

  // --- LOGIC for booking a vaccination slot ---
  Future<void> _bookVaccinationSlot(BuildContext context, Hospital hospital) async {
    // Safety check
    if (hospital.vaccines.isEmpty) return;

    String? selectedVaccine;

    // Handle vaccine selection
    if (hospital.vaccines.length == 1) {
      selectedVaccine = hospital.vaccines.first;
    } else {
      selectedVaccine = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Select Vaccine'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: hospital.vaccines.length,
              itemBuilder: (listCtx, index) {
                return ListTile(
                  title: Text(hospital.vaccines[index]),
                  onTap: () => Navigator.of(ctx).pop(hospital.vaccines[index]),
                );
              },
            ),
          ),
        ),
      );
    }

    if (selectedVaccine == null || !context.mounted) return;

    // Pick Date and Time
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)));
    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) return;

    // Create and save the appointment
    final DateTime finalDateTime = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);

    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patient.id,
      hospitalId: hospital.id,
      doctorName: selectedVaccine,
      specialty: 'Vaccination',
      dateTime: finalDateTime,
      isVaccination: true,
      type: AppointmentType.vaccination,
    );

    await UserDataService().bookAppointment(newAppointment);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vaccination slot booked successfully!'),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get only the hospitals that offer vaccines
    final vaccineHospitals = UserDataService()
        .hospitals
        .where((h) => h.vaccines.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Book a Vaccination'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: vaccineHospitals.isEmpty
          ? const Center(
              child: Text(
                'No hospitals are currently offering vaccines.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: vaccineHospitals.length,
              itemBuilder: (context, index) {
                final hospital = vaccineHospitals[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hospital.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hospital.address,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const Divider(height: 24),
                        const Text(
                          'Available Vaccines:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: hospital.vaccines
                              .map((vaccine) =>
                                  Chip(label: Text(vaccine)))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.event_available_rounded),
                            label: const Text('Book a Slot'),
                            onPressed: () =>
                                _bookVaccinationSlot(context, hospital),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}