// lib/screens/patient/patient_dashboard_page.dart

import 'package:care/models/user_models.dart';
import 'package:care/screens/chatbot/chat_page.dart';
import 'package:care/screens/hospital/hospital_list_page.dart';
import 'package:care/screens/hospital/vaccination_page.dart';
import 'package:care/screens/pharmacy/pharmacy_page.dart';
import 'package:care/screens/landing_page.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDashboardPage extends StatefulWidget {
  final Patient patient;
  const PatientDashboardPage({super.key, required this.patient});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  int _currentIndex = 0;
  int _healthcareTabIndex = 0;

  final UserDataService _userDataService = UserDataService();
  List<AppNotification> _notifications = [];
  bool _hasUnreadNotifications = false;

  // --- MOCK DATA ---
  final List<ConsultationVideo> videoRecordings = [
    ConsultationVideo(doctorName: "Dr. John", thumbnailUrl: "https://www.kumodent.com/storage/2021/07/kumodent_image_106a.png"),
    ConsultationVideo(doctorName: "Dr. Catherin", thumbnailUrl: "https://cdn.prod.website-files.com/5dda6844d31f0f476963dac6/63eb2b2ac4510c7a655924f6_online-doctor-tab-consultation.png"),
  ];
  final List<Prescription> prescriptions = [
    Prescription(id: '1', patientId: '1', doctorName: 'Dr. John Smith', date: DateTime(2023, 10, 15), diagnosis: 'Upper respiratory infection', medications: [Medication(name: 'Amoxicillin', dosage: '500mg', frequency: '3 times daily', duration: '7 days')]),
  ];
  final List<Receipt> receipts = [
    Receipt(id: '1', patientId: '1', date: DateTime(2023, 10, 15), amount: 150.00, hospitalName: 'City General Hospital', service: 'Consultation & Prescription'),
  ];
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  void _loadNotifications() {
    final notifications = _userDataService.getNotificationsForPatient(widget.patient.id);
    setState(() {
      _notifications = notifications;
      _hasUnreadNotifications = notifications.any((n) => !n.isRead);
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF2D6A9F);
    const Color secondaryColor = Color(0xFF4ECDC4);
    const Color accentColor = Color(0xFFFF6B6B);
  
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services, color: primaryColor, size: 24),
          ),
        ),
        title: Text('Welcome, ${widget.patient.name.split(" ")[0]}!', 
          style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: Badge(
              backgroundColor: accentColor,
              isLabelVisible: _hasUnreadNotifications,
              child: Icon(Icons.notifications, color: Colors.grey.shade700, size: 24),
            ), 
            onPressed: _showNotificationsDialog,
          ),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.account_circle, color: primaryColor, size: 24),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'profile') _showProfileInfo();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'profile', child: Text('Personal Information')),
              const PopupMenuItem<String>(value: 'logout', child: Text('Logout')),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          _buildBodyContent(primaryColor, secondaryColor, accentColor),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(primaryColor),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatPage()),
          );
        },
      ),
    );
  }

  // --- UI WIDGETS AND LOGIC ---

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter dialogSetState) {
            return AlertDialog(
              title: const Text('Notifications'),
              content: SizedBox(
                width: double.maxFinite,
                child: _notifications.isEmpty
                    ? const Center(
                        child: Text('No notifications yet.'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return ListTile(
                            leading: Icon(
                              notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                              color: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
                            ),
                            title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(notification.body),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'Delete notification',
                              onPressed: () {
                                _userDataService.deleteNotification(notification.id);
                                dialogSetState(() {
                                  _notifications.removeAt(index);
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      _loadNotifications();
    });
  }
  
  Widget _buildBodyContent(Color primaryColor, Color secondaryColor, Color accentColor) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardContent(primaryColor, secondaryColor, accentColor);
      case 1:
        return _buildAppointmentsContent(primaryColor);
      case 2:
        return _buildRecordsContent(primaryColor);
      case 3:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              Text('Name: ${widget.patient.name}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('Email: ${widget.patient.email}', style: const TextStyle(fontSize: 18)),
            ],
          )
        );
      default:
        return _buildDashboardContent(primaryColor, secondaryColor, accentColor);
    }
  }

  Widget _buildDashboardContent(Color primaryColor, Color secondaryColor, Color accentColor) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(primaryColor, secondaryColor),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildQuickActions(primaryColor, secondaryColor, accentColor),
            const SizedBox(height: 28),
            _buildSectionHeader('Upcoming Appointments', primaryColor, onViewAll: () {
              setState(() => _currentIndex = 1);
            }),
            const SizedBox(height: 12),
            _buildAppointmentsList(primaryColor, showAll: false),
            const SizedBox(height: 28),
            _buildSectionHeader('Recent Consultations', primaryColor, onViewAll: () {}),
            const SizedBox(height: 12),
            _buildVideosList(),
            const SizedBox(height: 28),
            _buildHealthcareSection(primaryColor, secondaryColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsContent(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Appointments', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
          const SizedBox(height: 16),
          Expanded(child: _buildAppointmentsList(primaryColor, showAll: true)),
        ],
      ),
    );
  }

  Widget _buildRecordsContent(Color primaryColor) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Medical Records', style: TextStyle(color: Colors.grey.shade800)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: primaryColor,
            labelColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Prescriptions'),
              Tab(text: 'Receipts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPrescriptionsList(),
            _buildReceiptsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(Color primaryColor, {bool showAll = false}) {
    final userAppointments = _userDataService.getAppointmentsForPatient(widget.patient.id);
    
    final displayedAppointments = showAll 
      ? userAppointments 
      : userAppointments.where((appt) => appt.dateTime.isAfter(DateTime.now())).toList();
    
    if (displayedAppointments.isEmpty) {
      return _buildEmptyState(
        showAll ? 'No appointments yet' : 'No upcoming appointments', 
        Icons.event_available, 
        'Book your first appointment now!'
      );
    }
    
    return ListView.builder(
      physics: showAll ? null : const NeverScrollableScrollPhysics(),
      shrinkWrap: !showAll,
      itemCount: displayedAppointments.length,
      itemBuilder: (context, index) {
        final appointment = displayedAppointments[index];
        final hospitalName = _userDataService.hospitals.firstWhere((h) => h.id == appointment.hospitalId, orElse: () => Hospital(id: '', name: 'Unknown Hospital', address: '', email: '', password: '', latitude: 0.0, longitude: 0.0)).name;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.isVaccination ? appointment.doctorName! : 'Dr. ${appointment.doctorName ?? 'General Consult'}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildAppointmentStatusChip(appointment),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  appointment.isVaccination ? hospitalName : (appointment.specialty ?? hospitalName), 
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    _buildModeIndicator(appointment.type),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(DateFormat('MMM d, yyyy').format(appointment.dateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(DateFormat('h:mm a').format(appointment.dateTime),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
                
                if (appointment.status == AppointmentStatus.approved &&
                    appointment.type == AppointmentType.online &&
                    appointment.sessionLink != null &&
                    appointment.sessionLink!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _joinCall(appointment.sessionLink!),
                        icon: const Icon(Icons.video_call_rounded, size: 18),
                        label: const Text('Join Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10)
                        ),
                      ),
                    ),
                  ),

                // --- MODIFIED: This now calls the fake payment dialog ---
                if (appointment.status == AppointmentStatus.approved && !appointment.paid)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => _processPayment(appointment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        ),
                        child: const Text('Pay Now', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Other helper widgets (unchanged) ---

  Widget _buildAppointmentStatusChip(Appointment appointment) {
    Color chipColor;
    String label;
    IconData icon;

    if (appointment.status == AppointmentStatus.pending && appointment.doctorId == null) {
      chipColor = const Color(0xFF1976D2);
      label = 'Pending Allocation';
      icon = Icons.hourglass_top_rounded;
    } else {
      switch (appointment.status) {
        case AppointmentStatus.approved:
          chipColor = const Color(0xFF4CAF50);
          label = 'Approved';
          icon = Icons.check_circle;
          break;
        case AppointmentStatus.rejected:
          chipColor = const Color(0xFFF44336);
          label = 'Rejected';
          icon = Icons.cancel;
          break;
        default:
          chipColor = const Color(0xFFFF9800);
          label = 'Pending';
          icon = Icons.pending;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: chipColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: chipColor, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  
  Widget _buildModeIndicator(AppointmentType type) {
    IconData icon;
    String text;
    Color color;

    switch (type) {
      case AppointmentType.online:
        icon = Icons.videocam_rounded;
        text = 'Online';
        color = Colors.teal;
        break;
      case AppointmentType.offline:
        icon = Icons.people_alt_rounded;
        text = 'In-Person';
        color = Colors.blue;
        break;
      case AppointmentType.vaccination:
        icon = Icons.vaccines_rounded;
        text = 'Vaccination';
        color = Colors.purple;
        break;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
  
  Widget _buildWelcomeCard(Color primaryColor, Color secondaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withOpacity(0.9), secondaryColor.withOpacity(0.8)]
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Health Journey', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 8),
                Text('Personalized care for your wellbeing', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalListPage(patient: widget.patient))).then((_) => setState(() {}));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    elevation: 2,
                  ),
                  child: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.health_and_safety, color: Colors.white, size: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(Color primaryColor, Color secondaryColor, Color accentColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.8,
      children: [
        _buildQuickActionItem(icon: Icons.local_pharmacy, label: 'Pharmacy', color: secondaryColor, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => PharmacyPage(patient: widget.patient))); }),
        _buildQuickActionItem(icon: Icons.emergency, label: 'Emergency', color: accentColor, onTap: () { _showEmergencyOptions(); }),
        _buildQuickActionItem(icon: Icons.local_hospital, label: 'Hospitals', color: primaryColor, onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => HospitalListPage(patient: widget.patient))).then((_) => setState(() {})); }),
        _buildQuickActionItem(icon: Icons.vaccines, label: 'Vaccination', color: Colors.purple, onTap: () { _bookVaccinationAppointment(); }),
      ],
    );
  }

  Widget _buildQuickActionItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.w500, height: 1.2), textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color primaryColor, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800, letterSpacing: -0.5)),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text('View All', style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search doctors, hospitals, services...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildVideosList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: videoRecordings.length,
        itemBuilder: (context, index) {
          final video = videoRecordings[index];
          return Container(
            width: 280,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(video.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFF3F4F6), child: Center(child: Icon(Icons.video_library, size: 48, color: Colors.grey.shade400)))),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.7), Colors.transparent]))),
                  Positioned(bottom: 16, left: 16, right: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(video.doctorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text('Video Consultation', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12))])),
                  Center(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle), child: const Icon(Icons.play_arrow, color: Colors.black, size: 32))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHealthcareSection(Color primaryColor, Color secondaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildHealthcareTab(label: 'Hospitals', isSelected: _healthcareTabIndex == 0, onTap: () => setState(() => _healthcareTabIndex = 0), color: primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildHealthcareTab(label: 'Pharmacies', isSelected: _healthcareTabIndex == 1, onTap: () => setState(() => _healthcareTabIndex = 1), color: secondaryColor)),
          ],
        ),
        const SizedBox(height: 20),
        _healthcareTabIndex == 0 ? _buildHospitalCarousel() : _buildPharmacyCarousel(),
      ],
    );
  }

  Widget _buildHealthcareTab({required String label, required bool isSelected, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300, width: 1.5),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.w600, fontSize: 14))),
      ),
    );
  }

  Widget _buildHospitalCarousel() {
    final hospitals = _userDataService.hospitals;
    if (hospitals.isEmpty) return _buildEmptyState('No hospitals available', Icons.business, 'Check back later');
    return CarouselSlider.builder(
      itemCount: hospitals.length,
      itemBuilder: (context, index, realIndex) => _buildCarouselCard(hospitals[index].name, Icons.local_hospital, const Color(0xFF2D6A9F)),
      options: CarouselOptions(height: 140, viewportFraction: 0.85, enlargeCenterPage: true, autoPlay: true, autoPlayInterval: const Duration(seconds: 3)),
    );
  }

  Widget _buildPharmacyCarousel() {
    final pharmacies = _userDataService.pharmacies;
    if (pharmacies.isEmpty) return _buildEmptyState('No pharmacies available', Icons.local_pharmacy, 'Check back later');
    return CarouselSlider.builder(
      itemCount: pharmacies.length,
      itemBuilder: (context, index, realIndex) => _buildCarouselCard(pharmacies[index].pharmacyName, Icons.local_pharmacy, const Color(0xFF4ECDC4)),
      options: CarouselOptions(height: 140, viewportFraction: 0.85, enlargeCenterPage: true, autoPlay: true, autoPlayInterval: const Duration(seconds: 3)),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String subtitle) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselCard(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: TextStyle(color: Colors.grey.shade800, fontSize: 16, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        backgroundColor: Colors.white,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Records'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsList() {
    if (prescriptions.isEmpty) return _buildEmptyRecordsState('No prescriptions found', Icons.medication);
    return ListView.builder(
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final p = prescriptions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            leading: const Icon(Icons.medical_services, color: Colors.blue),
            title: Text('Dr. ${p.doctorName}'),
            subtitle: Text(DateFormat('MMM d, yyyy').format(p.date)),
            children: [Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Diagnosis: ${p.diagnosis}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 16), const Text('Medications:', style: TextStyle(fontWeight: FontWeight.bold)), ...p.medications.map((med) => Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${med.dosage}, ${med.frequency}, ${med.duration}')]))])))]))],
          ),
        );
      },
    );
  }

  Widget _buildReceiptsList() {
    if (receipts.isEmpty) return _buildEmptyRecordsState('No receipts found', Icons.receipt);
    return ListView.builder(
      itemCount: receipts.length,
      itemBuilder: (context, index) {
        final receipt = receipts[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.receipt, color: Colors.green),
            title: Text(receipt.hospitalName),
            subtitle: Text(DateFormat('MMM d, yyyy').format(receipt.date)),
            trailing: Text('\$${receipt.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            onTap: () => _showReceiptDetails(receipt),
          ),
        );
      },
    );
  }

  Widget _buildEmptyRecordsState(String message, IconData icon) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 64, color: Colors.grey), const SizedBox(height: 16), Text(message, style: const TextStyle(fontSize: 18, color: Colors.grey))]));
  }

  void _showEmergencyOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Emergency Assistance'),
          content: const Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Please select an emergency option:'), SizedBox(height: 16)]),
          actions: [
            TextButton(onPressed: () { Navigator.pop(context); _callEmergency('108'); }, child: const Text('Call Ambulance (108)')),
            TextButton(onPressed: () { Navigator.pop(context); _callEmergency('104'); }, child: const Text('Toll-Free Medical Helpline (104)')),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        );
      },
    );
  }

  void _callEmergency(String number) async {
    final Uri telLaunchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    } else {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $number')));
    }
  }
  
  void _joinCall(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open the call link: $url')),
        );
      }
    }
  }

  // --- MODIFIED: This is the fake payment dialog function ---
  void _processPayment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Appointment with Dr. ${appointment.doctorName ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('MMM d, yyyy').format(appointment.dateTime)}'),
              const SizedBox(height: 8),
              Text('Time: ${DateFormat('h:mm a').format(appointment.dateTime)}'),
              const Divider(height: 24),
              const Text('Amount: \$50.00', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                // 1. Update the data
                _userDataService.markAppointmentAsPaid(appointment.id);
                
                // 2. Close the dialog
                Navigator.pop(context);
                
                // 3. Refresh the UI
                setState(() {});
                
                // 4. Show a success message
                if(mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment successful!'),
                      backgroundColor: Colors.green,
                    )
                  );
                }
              },
              child: const Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
  }

  void _bookVaccinationAppointment() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => VaccinationPage(patient: widget.patient,)));
  }

  void _showReceiptDetails(Receipt receipt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Receipt Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hospital: ${receipt.hospitalName}'),
              const SizedBox(height: 8),
              Text('Date: ${DateFormat('MMM d, yyyy').format(receipt.date)}'),
              const SizedBox(height: 8),
              Text('Service: ${receipt.service}'),
              const SizedBox(height: 8),
              Text('Amount: \$${receipt.amount.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('Download')),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _showProfileInfo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Personal Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.patient.name}'),
              const SizedBox(height: 8),
              Text('Email: ${widget.patient.email}'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        );
      },
    );
  }
}

// Dummy class for video consultations
class ConsultationVideo {
  final String doctorName;
  final String thumbnailUrl;
  ConsultationVideo({required this.doctorName, required this.thumbnailUrl});
}