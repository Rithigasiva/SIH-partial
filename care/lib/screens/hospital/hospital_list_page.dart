import 'package:care/models/user_models.dart';
import 'package:care/screens/doctor/doctor_list_page.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';
// Note: Add intl package to your pubspec.yaml if not already present for date formatting.
// import 'package:intl/intl.dart';

class HospitalListPage extends StatelessWidget {
  final Patient patient;
  const HospitalListPage({super.key, required this.patient});

  // --- ACTION HANDLER: Shows a bottom sheet with booking options ---
  void _showBookingOptions(BuildContext context, Hospital hospital) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // Build a list of available actions
        List<Widget> options = [
          ListTile(
            leading: const Icon(Icons.person_search_rounded, color: Color(0xFF199A8E)),
            title: const Text('Consult a Specific Doctor'),
            onTap: () {
              Navigator.pop(ctx); // Close the sheet
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorListPage(
                    hospital: hospital,
                    patient: patient,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups_rounded, color: Color(0xFF199A8E)),
            title: const Text('Request a General Consultation'),
            onTap: () {
              Navigator.pop(ctx); // Close the sheet
              _bookGeneralAppointment(context, hospital);
            },
          ),
        ];

        // Conditionally add the vaccination option
        if (hospital.vaccines.isNotEmpty) {
          options.add(
            ListTile(
              leading: const Icon(Icons.vaccines_rounded, color: Color(0xFF199A8E)),
              title: const Text('Book Vaccination Slot'),
              onTap: () {
                Navigator.pop(ctx); // Close the sheet
                _bookVaccination(context, hospital);
              },
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(children: options),
        );
      },
    );
  }

  // --- LOGIC for booking a general appointment (with mode selection) ---
  Future<void> _bookGeneralAppointment(BuildContext context, Hospital hospital) async {
    // Step 1: Show dialog to choose appointment type (Online/Offline)
    final AppointmentType? selectedType = await showDialog<AppointmentType>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Consultation Mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam_rounded, color: Color(0xFF199A8E)),
              title: const Text('Online'),
              onTap: () => Navigator.of(ctx).pop(AppointmentType.online),
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_rounded, color: Color(0xFF199A8E)),
              title: const Text('Offline'),
              onTap: () => Navigator.of(ctx).pop(AppointmentType.offline),
            ),
          ],
        ),
      ),
    );

    if (selectedType == null || !context.mounted) return;

    // Step 2 & 3: Pick Date and Time
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      // Re-adding the custom theme builder from your original code
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF199A8E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF199A8E),
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

    // Step 4: Create and save the appointment
    final DateTime finalDateTime = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);

    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patient.id,
      dateTime: finalDateTime,
      hospitalId: hospital.id,
      type: selectedType, // Set the chosen mode
      isVaccination: false,
    );

    await UserDataService().bookAppointment(newAppointment);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Request sent to hospital!'),
        backgroundColor: const Color(0xFF199A8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    }
  }

  // --- LOGIC for booking a vaccination slot (Corrected and Robust) ---
  Future<void> _bookVaccination(BuildContext context, Hospital hospital) async {
    // Safety check: Exit if the vaccine list is somehow empty.
    if (hospital.vaccines.isEmpty) return;

    String? selectedVaccine;

    // Step 1: Handle vaccine selection
    if (hospital.vaccines.length == 1) {
      // If there's only one vaccine, select it automatically.
      selectedVaccine = hospital.vaccines.first;
    } else {
      // If there are multiple vaccines, prompt the user to choose.
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

    // Exit if no vaccine was selected (e.g., user dismissed the dialog).
    if (selectedVaccine == null || !context.mounted) return;

    // Step 2 & 3: Pick Date and Time
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (pickedDate == null || !context.mounted) return;

    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) return;

    // Step 4: Create and save the vaccination appointment
    final DateTime finalDateTime = DateTime(pickedDate.year, pickedDate.month,
        pickedDate.day, pickedTime.hour, pickedTime.minute);

    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      patientId: patient.id,
      hospitalId: hospital.id,
      doctorName: selectedVaccine, // Use vaccine name as the "doctor/service name"
      specialty: 'Vaccination',
      dateTime: finalDateTime,
      isVaccination: true,
      type: AppointmentType.vaccination,
    );

    await UserDataService().bookAppointment(newAppointment);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Vaccination slot booked successfully!'),
        backgroundColor: const Color(0xFF199A8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.of(context).pop();
    }
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final hospitals = UserDataService().hospitals;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      appBar: AppBar(
        title: const Text(
          'Select a Hospital',
          style: TextStyle(
            color: Color(0xFF0D1F48),
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0D1F48)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE8F4F3)],
            stops: [0.1, 0.9],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: hospitals.length,
          itemBuilder: (context, index) {
            final hospital = hospitals[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF199A8E).withOpacity(0.1),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF199A8E).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  // Unified tap target to show booking options
                  onTap: () => _showBookingOptions(context, hospital),
                  splashColor: const Color(0xFF199A8E).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hospital Header with Name and Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                hospital.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0D1F48),
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF199A8E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF199A8E).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Color(0xFFFFD700),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "4.8", // Hardcoded rating, consider adding to model
                                    style: TextStyle(
                                      color: Color(0xFF199A8E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Address Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF199A8E).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Color(0xFF199A8E),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                hospital.address,
                                style: const TextStyle(
                                  color: Color(0xFF6E7899),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Divider(
                          color: const Color(0xFF199A8E).withOpacity(0.2),
                          height: 1,
                          thickness: 1,
                        ),
                        const SizedBox(height: 12),

                        // Hint text instead of multiple buttons
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Tap card for options...',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}