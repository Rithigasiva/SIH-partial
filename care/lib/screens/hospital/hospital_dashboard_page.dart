// lib/screens/hospital/hospital_dashboard_page.dart

import 'package:care/models/user_models.dart';
import 'package:care/screens/doctor/doctor_dashboard_page.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HospitalDashboardPage extends StatefulWidget {
  final Hospital hospital;
  const HospitalDashboardPage({super.key, required this.hospital});

  @override
  State<HospitalDashboardPage> createState() => _HospitalDashboardPageState();
}

class _HospitalDashboardPageState extends State<HospitalDashboardPage> {
  final UserDataService _userDataService = UserDataService();
  // State variable to track if the requests tab is accessible
  bool _isRequestsTabUnlocked = false;

  // This dialog is for the doctor login from the 'Doctors' tab
  void _showDoctorLoginDialog(Doctor doctor) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.medical_services, size: 40, color: Colors.blue[700]),
                  const SizedBox(height: 16),
                  Text('Doctor Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                  const SizedBox(height: 8),
                  Text('Dr. ${doctor.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
                        child: const Text('Login'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (passwordController.text == doctor.password) {
                              Navigator.of(context).pop();
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorDashboardPage(doctor: doctor)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Incorrect password.'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // --- NEW: Password Dialog specifically for the Requests Tab ---
  void _showRequestsPasswordDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false, // User must enter password or cancel
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.admin_panel_settings, size: 40, color: Colors.teal),
                  const SizedBox(height: 16),
                  const Text('Admin Access Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Enter admin password to view requests.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Admin Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        child: const Text('Unlock'),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            // Check if the password is 'admin'
                            if (passwordController.text == 'admin') {
                              Navigator.of(context).pop(); // Close the dialog
                              setState(() {
                                _isRequestsTabUnlocked = true; // Set state to unlock the tab
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Incorrect admin password.'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  Future<void> _showAllocationDialog(Appointment appointment) async {
    final availableDoctors = _userDataService
        .getDoctorsForHospital(widget.hospital.id)
        .where((doctor) => _userDataService.isDoctorAvailable(doctor, appointment.dateTime))
        .toList();

    Doctor? selectedDoctor = availableDoctors.isNotEmpty ? availableDoctors.first : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            bool hasConflict = selectedDoctor != null
                ? _userDataService.hasAppointmentConflict(selectedDoctor!.id, appointment.dateTime)
                : false;

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_add, size: 36, color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    const Text('Allocate Appointment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${DateFormat.yMMMd().add_jm().format(appointment.dateTime)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    if (availableDoctors.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Doctors:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButton<Doctor>(
                              isExpanded: true,
                              value: selectedDoctor,
                              underline: const SizedBox(),
                              items: availableDoctors.map((doc) {
                                final hasDoctorConflict = _userDataService.hasAppointmentConflict(doc.id, appointment.dateTime);
                                return DropdownMenuItem(
                                  value: doc,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Dr. ${doc.name} (${doc.specialist})",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: hasDoctorConflict ? Colors.grey : Colors.black,
                                          ),
                                        ),
                                      ),
                                      if (hasDoctorConflict)
                                        const Icon(Icons.warning, size: 16, color: Colors.orange),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (doc) {
                                setStateInDialog(() {
                                  selectedDoctor = doc;
                                  hasConflict = doc != null
                                      ? _userDataService.hasAppointmentConflict(doc.id, appointment.dateTime)
                                      : false;
                                });
                              },
                            ),
                          ),
                          if (hasConflict && selectedDoctor != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning, size: 16, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Dr. ${selectedDoctor!.name} already has an appointment at this time',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: Colors.orange),
                          const SizedBox(height: 16),
                          const Text(
                            'No doctors available',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'No doctors are available at ${DateFormat.jm().format(appointment.dateTime)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: hasConflict ? Colors.grey : Colors.blue[700],
                              foregroundColor: Colors.white),
                          onPressed: (availableDoctors.isEmpty || hasConflict)
                              ? null
                              : () {
                                  if (selectedDoctor != null) {
                                    final updatedAppointment = Appointment(
                                      id: appointment.id,
                                      patientId: appointment.patientId,
                                      hospitalId: appointment.hospitalId,
                                      doctorId: selectedDoctor!.id,
                                      doctorName: selectedDoctor!.name,
                                      specialty: selectedDoctor!.specialist,
                                      dateTime: appointment.dateTime,
                                      status: AppointmentStatus.approved,
                                      type: appointment.type,
                                      isVaccination: appointment.isVaccination,
                                      paid: appointment.paid,
                                      sessionLink: appointment.sessionLink,
                                    );
                                    _userDataService.bookAppointment(updatedAppointment);
                                    Navigator.pop(context);
                                  }
                                },
                          child: const Text('Allocate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showEditServicesDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            final nameController = TextEditingController();
            final hospitalData = _userDataService.hospitals.firstWhere((h) => h.id == widget.hospital.id);
            List<String> currentServices = List<String>.from(hospitalData.services ?? []);

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.medical_services, size: 36, color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    const Text('Manage Hospital Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                                labelText: 'New Service Name',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green, size: 30),
                          onPressed: () {
                            if (nameController.text.isNotEmpty) {
                              currentServices.add(nameController.text);
                              final updatedHospital = hospitalData.copyWith(services: currentServices);
                              _userDataService.registerHospital(updatedHospital);
                              nameController.clear();
                              setStateInDialog(() {});
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    const Text('Existing Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: currentServices.isEmpty
                          ? const Center(child: Text('No services added yet.'))
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: currentServices.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(currentServices[index]),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      currentServices.removeAt(index);
                                      final updatedHospital =
                                          hospitalData.copyWith(services: currentServices);
                                      _userDataService.registerHospital(updatedHospital);
                                      setStateInDialog(() {});
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentHospitalData = _userDataService.hospitals.firstWhere((h) => h.id == widget.hospital.id);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentHospitalData.name),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.analytics_outlined), text: 'Dashboard'),
              Tab(icon: Icon(Icons.pending_actions_outlined), text: 'Requests'),
              Tab(icon: Icon(Icons.medical_services_outlined), text: 'Doctors'),
              Tab(icon: Icon(Icons.miscellaneous_services_rounded), text: 'Services'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[50]!, Colors.grey[100]!])),
          child: TabBarView(
            children: [
              _buildAnalyticsTab(),
              _buildRequestsTab(),
              _buildDoctorsTab(),
              _buildServicesTab(currentHospitalData),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB BUILDERS ---

  // MODIFIED: This widget now acts as a gatekeeper for the requests content.
  Widget _buildRequestsTab() {
    if (_isRequestsTabUnlocked) {
      return _buildRequestsTabContent(); // Show content if unlocked
    } else {
      // Show a locked view with a button to enter password
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'Admin Access Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please enter the password to view appointment requests.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.vpn_key),
              label: const Text('Enter Password'),
              onPressed: _showRequestsPasswordDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      );
    }
  }

  // RENAMED: This is the original content of the requests tab.
  Widget _buildRequestsTabContent() {
    final pendingAppointments = _userDataService
        .getAppointmentsForHospital(widget.hospital.id)
        .where((a) => a.status == AppointmentStatus.pending && a.doctorId == null)
        .toList();

    if (pendingAppointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending requests to allocate.', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: pendingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = pendingAppointments[index];
        final patient = _userDataService.patients.firstWhere((p) => p.id == appointment.patientId,
            orElse: () => Patient(id: '', name: 'Unknown', email: '', password: '', mobile: '', dob: '', address: ''));

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person_outline, color: Colors.blue),
            ),
            title: Text('Request from ${patient.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('On: ${DateFormat.yMMMd().add_jm().format(appointment.dateTime)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _userDataService.updateAppointmentStatus(appointment.id, AppointmentStatus.rejected);
                    setState(() {}); // Refresh the UI to remove the item
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
                  onPressed: () async {
                    await _showAllocationDialog(appointment);
                    setState(() {});
                  },
                  child: const Text('Allocate'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesTab(Hospital currentHospital) {
    final services = currentHospital.services ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: services.isNotEmpty
                ? Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListView.separated(
                      itemCount: services.length,
                      separatorBuilder: (context, index) => const Divider(indent: 16, endIndent: 16),
                      itemBuilder: (context, index) => ListTile(
                        leading: Icon(Icons.check_circle_outline, color: Colors.green[700]),
                        title: Text(services[index], style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  )
                : const Center(child: Text('No services listed.')),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16)),
            icon: const Icon(Icons.edit),
            label: const Text('Add / Edit Services'),
            onPressed: () async {
              await _showEditServicesDialog();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final appointments = _userDataService.getAppointmentsForHospital(widget.hospital.id);
    final pendingCount = appointments.where((a) => a.status == AppointmentStatus.pending).length;
    final approvedCount = appointments.where((a) => a.status == AppointmentStatus.approved).length;
    final rejectedCount = appointments.where((a) => a.status == AppointmentStatus.rejected).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hospital Analytics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total', appointments.length.toString(), Icons.calendar_today, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Pending', pendingCount.toString(), Icons.pending_actions, Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Approved', approvedCount.toString(), Icons.check_circle, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Rejected', rejectedCount.toString(), Icons.cancel, Colors.red)),
            ],
          ),
          const SizedBox(height: 30),
          const Text('Appointments by Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                        value: pendingCount.toDouble(), title: '$pendingCount\nPending', color: Colors.orange, radius: 60),
                    PieChartSectionData(
                        value: approvedCount.toDouble(), title: '$approvedCount\nApproved', color: Colors.green, radius: 60),
                    PieChartSectionData(
                        value: rejectedCount.toDouble(), title: '$rejectedCount\nRejected', color: Colors.red, radius: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildDoctorsTab() {
    final doctors = _userDataService.getDoctorsForHospital(widget.hospital.id);
    if (doctors.isEmpty) {
      return const Center(child: Text('No doctors registered for this hospital.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(doctor.name.substring(0, 1))),
            title: Text('Dr. ${doctor.name}'),
            subtitle: Text(doctor.specialist),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white),
              onPressed: () => _showDoctorLoginDialog(doctor),
              child: const Text('Login'),
            ),
          ),
        );
      },
    );
  }
}
