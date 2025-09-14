import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';

// Top-level function for booking appointments
Future<void> _bookAppointment(BuildContext context, Doctor doctor, Patient patient, Hospital hospital) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF199A8E),
            onPrimary: Colors.white,
            onSurface: Color(0xFF0D1F48),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF199A8E),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate == null) return;

  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF199A8E),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF199A8E),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedTime == null) return;

  final DateTime finalDateTime = DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime.hour,
    pickedTime.minute,
  );

  final newAppointment = Appointment(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    patientId: patient.id,
    hospitalId: hospital.id,
    doctorId: doctor.id,
    doctorName: doctor.name,
    specialty: doctor.specialist,
    dateTime: finalDateTime,
  );

  await UserDataService().bookAppointment(newAppointment);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Appointment booked successfully!'),
        backgroundColor: const Color(0xFF199A8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context)..pop()..pop();
  }
}

class DoctorListPage extends StatelessWidget {
  final Hospital hospital;
  final Patient patient;
  const DoctorListPage({super.key, required this.hospital, required this.patient});

  @override
  Widget build(BuildContext context) {
    final doctors = UserDataService().getDoctorsForHospital(hospital.id);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      appBar: AppBar(
        title: Text(
          'Doctors at ${hospital.name}',
          style: const TextStyle(
            color: Color(0xFF0D1F48),
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D1F48)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE5E5E5)],
            stops: [0.1, 0.9],
          ),
        ),
        child: doctors.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No doctors available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6E7191),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No doctors have registered for this hospital yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFA0A5BA),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Doctor avatar
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF199A8E).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: const Color(0xFF199A8E).withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0D1F48),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialist,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF199A8E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.medical_services,
                                      size: 14,
                                      color: Color(0xFFA0A5BA),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      hospital.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFFA0A5BA),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _bookAppointment(context, doctor, patient, hospital),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF199A8E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Book Appointment',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}