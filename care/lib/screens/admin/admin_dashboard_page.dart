import 'package:care/models/user_models.dart';
import 'package:care/screens/hospital/hospital_doctors_page.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final UserDataService _userDataService = UserDataService();

  // --- DIALOGS FOR DETAILS ---

  // Shows detailed information for a Patient
  void _showPatientDetails(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Patient Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.person, 'Name', patient.name),
              _buildDetailRow(Icons.email, 'Email', patient.email),
              _buildDetailRow(Icons.phone, 'Mobile', patient.mobile),
              _buildDetailRow(Icons.cake, 'Date of Birth', patient.dob),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Shows detailed information for a Doctor
  void _showDoctorDetails(BuildContext context, Doctor doctor) {
    // Find the hospital name from the hospitalId
    final hospital = _userDataService.hospitals.firstWhere(
      (h) => h.id == doctor.hospitalId,
      orElse: () => Hospital(
          id: '',
          name: 'Unknown Hospital',
          address: '',
          email: '',
          password: '',
          latitude: 0,
          longitude: 0),
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Doctor Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.person_pin_rounded, 'Name', doctor.name),
              _buildDetailRow(Icons.email_outlined, 'Email', doctor.email),
              _buildDetailRow(
                  Icons.phone_android, 'Mobile', doctor.mobile),
              _buildDetailRow(
                  Icons.medical_services_outlined, 'Specialty', doctor.specialist),
              _buildDetailRow(
                  Icons.work_history_outlined, 'Experience', '${doctor.experience} years'),
              _buildDetailRow(
                  Icons.local_hospital, 'Hospital', hospital.name),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Shows detailed information for a Hospital
  void _showHospitalDetails(BuildContext context, Hospital hospital) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(hospital.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(Icons.location_on, 'Address', hospital.address),
              _buildDetailRow(Icons.email, 'Email', hospital.email),
              _buildDetailRow(Icons.phone, 'Contact', hospital.contactNumber ?? 'N/A'),
              _buildDetailRow(Icons.access_time_filled, 'Timings', hospital.timings ?? 'N/A'),
              const SizedBox(height: 10),
              const Divider(),
              const Text("Services", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: hospital.services?.map((service) => Chip(label: Text(service)))
                        .toList() ??
                    [const Text('No services listed.')],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const Text("Vaccines", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8.0,
                children: hospital.vaccines.isNotEmpty
                    ? hospital.vaccines.map((v) => Chip(label: Text(v))).toList()
                    : [const Text('No vaccines listed.')],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HospitalDoctorsPage(hospital: hospital),
                ),
              );
            },
            child: const Text('View Doctors'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Reusable widget for displaying a row of details in the dialogs
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              SizedBox(
                width: 180, // Adjust width to prevent overflow
                child: Text(value, style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- DELETE FUNCTIONALITY ---
  void _deleteUser(dynamic user) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this user? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _userDataService.deleteUser(user);
                setState(() {}); // Refresh the UI
                Navigator.of(ctx).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('User deleted successfully'),
                        backgroundColor: Colors.green),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Increased length for the new "Vaccines" tab
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 2,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.people_alt_rounded), text: 'Patients'),
              Tab(icon: Icon(Icons.local_hospital_rounded), text: 'Hospitals'),
              Tab(icon: Icon(Icons.medical_services_rounded), text: 'Doctors'),
              Tab(icon: Icon(Icons.local_pharmacy_rounded), text: 'Pharmacies'),
              Tab(icon: Icon(Icons.vaccines_rounded), text: 'Vaccines'), // New tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserList<Patient>(_userDataService.patients),
            _buildUserList<Hospital>(_userDataService.hospitals),
            _buildUserList<Doctor>(_userDataService.doctors),
            _buildUserList<Pharmacy>(_userDataService.pharmacies),
            _buildVaccineList(), // View for the new tab
          ],
        ),
      ),
    );
  }

  // --- LIST BUILDERS ---

  Widget _buildUserList<T>(List<T> users) {
    if (users.isEmpty) {
      return _buildEmptyState(T);
    }
    // Create a map for quick hospital name lookup
    final hospitalMap = {for (var h in _userDataService.hospitals) h.id: h.name};

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        String title = 'Unknown User';
        String subtitle = 'No details';
        IconData leadingIcon = Icons.person;
        Color iconColor = Colors.teal;
        VoidCallback? onTap;
        List<Widget> chips = [];

        // Logic to handle different user types
        if (user is Patient) {
          title = user.name;
          subtitle = user.email;
          leadingIcon = Icons.personal_injury_rounded;
          iconColor = Colors.blue;
          onTap = () => _showPatientDetails(context, user);
        } else if (user is Doctor) {
          title = user.name;
          subtitle = hospitalMap[user.hospitalId] ?? 'Unknown Hospital';
          leadingIcon = Icons.medical_services;
          iconColor = Colors.green;
          onTap = () => _showDoctorDetails(context, user);
          chips.add(_buildChip(user.specialist, Colors.green.shade100, Colors.green.shade800));
        } else if (user is Pharmacy) {
          title = user.pharmacyName;
          subtitle = user.address;
          leadingIcon = Icons.local_pharmacy;
          iconColor = Colors.orange;
          // Here we simulate the 'active' status with a chip
          chips.add(_buildChip('Active', Colors.green.shade100, Colors.green.shade800));
        } else if (user is Hospital) {
          title = user.name;
          subtitle = user.address;
          leadingIcon = Icons.local_hospital;
          iconColor = Colors.red;
          onTap = () => _showHospitalDetails(context, user);
        }

        return _buildInfoCard(
          title: title,
          subtitle: subtitle,
          leadingIcon: leadingIcon,
          iconColor: iconColor,
          chips: chips,
          onTap: onTap,
          onDelete: () => _deleteUser(user),
        );
      },
    );
  }

  // Widget for the new "Vaccines" tab
  Widget _buildVaccineList() {
    // Filter hospitals that offer vaccines
    final vaccineHospitals = _userDataService.hospitals
        .where((h) => h.vaccines.isNotEmpty)
        .toList();

    if (vaccineHospitals.isEmpty) {
      return _buildEmptyState(null, message: "No hospitals are offering vaccines currently.");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: vaccineHospitals.length,
      itemBuilder: (context, index) {
        final hospital = vaccineHospitals[index];
        return _buildInfoCard(
            title: hospital.name,
            subtitle: hospital.address,
            leadingIcon: Icons.vaccines_rounded,
            iconColor: Colors.deepPurple,
            onTap: () => _showHospitalDetails(context, hospital),
            onDelete: () => _deleteUser(hospital),
            chips: hospital.vaccines
                .map((v) => _buildChip(v, Colors.deepPurple.shade100, Colors.deepPurple.shade900))
                .toList());
      },
    );
  }

  // --- UI HELPER WIDGETS ---

  // A standardized, reusable card for displaying user/entity info
  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    required Color iconColor,
    required VoidCallback onDelete,
    VoidCallback? onTap,
    List<Widget> chips = const [],
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconColor.withOpacity(0.15),
                child: Icon(leadingIcon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (chips.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(spacing: 6.0, runSpacing: 6.0, children: chips),
                    ]
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color backgroundColor, Color textColor) {
    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 11),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
  
  Widget _buildEmptyState(Type? type, {String? message}) {
    IconData icon = Icons.info_outline;
    String text = message ?? 'No registered ${type.toString().toLowerCase()}s yet.';
    if (type != null) {
      if (type == Patient) icon = Icons.people_alt_outlined;
      if (type == Doctor) icon = Icons.medical_services_outlined;
      if (type == Pharmacy) icon = Icons.local_pharmacy_outlined;
      if (type == Hospital) icon = Icons.local_hospital_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(text, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}