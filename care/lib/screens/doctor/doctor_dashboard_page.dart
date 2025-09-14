// lib/screens/doctor/doctor_dashboard_page.dart

import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

class DoctorDashboardPage extends StatefulWidget {
  final Doctor doctor;
  const DoctorDashboardPage({super.key, required this.doctor});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Appointment> _selectedAppointments = [];
  int _currentBottomNavIndex = 0;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointmentsForSelectedDay(_selectedDay!);
    _loadDoctorAvailability();
  }

  void _loadAppointmentsForSelectedDay(DateTime day) {
    final allAppointments = UserDataService().getAppointmentsForDoctor(widget.doctor.id);
    setState(() {
      _selectedAppointments = allAppointments.where((appointment) {
        return UserDataService().isSameDay(appointment.dateTime, day);
      }).toList();
    });
  }

  Map<String, List<Map<String, dynamic>>> _weeklyAvailability = {};

  Future<void> _updateAppointmentStatus(Appointment appointment, AppointmentStatus status) async {
    await UserDataService().updateAppointmentStatus(appointment.id, status);
    _loadAppointmentsForSelectedDay(_selectedDay!);
  }

  void _loadDoctorAvailability() {
    setState(() {
      _weeklyAvailability = Map<String, List<Map<String, dynamic>>>.from(widget.doctor.weeklyAvailability);
    });
  }
  
  // --- MODIFICATION START ---
  // Updated the _buildOnlineActions widget to check for payment status.
  Widget _buildOnlineActions(Appointment appointment) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Only show actions if the appointment has been paid for
          if (appointment.paid)
            if (appointment.sessionLink == null || appointment.sessionLink!.isEmpty)
              ElevatedButton.icon(
                icon: const Icon(Icons.add_link, size: 16),
                label: const Text('Add Link'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _addSessionLinkDialog(appointment),
              )
            else
              ElevatedButton.icon(
                icon: const Icon(Icons.video_call, size: 16),
                label: const Text('Join Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _addSessionLinkDialog(appointment), // Or launch URL
              )
          else
            // Show a message if payment is pending
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.payment_rounded, size: 16, color: Colors.orange.shade800),
                  const SizedBox(width: 8),
                  Text(
                    'Waiting for patient payment',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  // --- MODIFICATION END ---
  
  // (The rest of the file remains unchanged. I am including it all for completeness)

  void _showAvailabilityEditor() {
    final daysOfWeek = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Set Weekly Availability',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...daysOfWeek.map((day) {
                        return _buildDayAvailabilityEditor(day, setState);
                      }).toList(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              UserDataService().updateDoctorAvailability(widget.doctor.id, _weeklyAvailability);
                              Navigator.pop(context);
                            },
                            child: const Text('Save'),
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
      },
    );
  }

  void _addSessionLinkDialog(Appointment appointment) {
    final linkController = TextEditingController(text: appointment.sessionLink);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.video_call, size: 40, color: Colors.blue[700]),
                const SizedBox(height: 16),
                const Text('Add Session Link', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: linkController,
                  decoration: InputDecoration(
                    hintText: 'Enter video call link...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (linkController.text.isNotEmpty) {
                          UserDataService().addSessionLink(appointment.id, linkController.text);
                          _loadAppointmentsForSelectedDay(_selectedDay!);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add Link'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hospital = UserDataService().hospitals.firstWhere(
          (h) => h.id == widget.doctor.hospitalId,
          orElse: () => Hospital(id: '', name: 'Unknown Hospital', address: '', email: '', password: '', latitude: 0.0, longitude: 0.0),
        );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dr. ${widget.doctor.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(hospital.name, style: TextStyle(fontSize: 14.0, color: Colors.grey[600])),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
            color: Colors.blue[700],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBodyContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBodyContent() {
    switch (_currentBottomNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildScheduleTab();
      case 2:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildScheduleTab() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ],
          ),
          margin: const EdgeInsets.all(16),
          child: _buildCalendar(),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _selectedAppointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No appointments for this day',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _selectedAppointments.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildAppointmentCard(_selectedAppointments[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDayAvailabilityEditor(String day, StateSetter setState) {
    final daySlots = _weeklyAvailability[day] ?? [];
    final dayName = day[0].toUpperCase() + day.substring(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              onPressed: () async {
                final TimeOfDay? startTime = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 9, minute: 0),
                );

                if (startTime != null) {
                  final TimeOfDay? endTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute),
                  );

                  if (endTime != null) {
                    setState(() {
                      final newSlot = TimeSlot(startTime: startTime, endTime: endTime);
                      if (_weeklyAvailability.containsKey(day)) {
                        _weeklyAvailability[day]!.add(newSlot.toMap());
                      } else {
                        _weeklyAvailability[day] = [newSlot.toMap()];
                      }
                    });
                  }
                }
              },
            ),
          ],
        ),
        ...daySlots.asMap().entries.map((entry) {
          final index = entry.key;
          final slotMap = entry.value;
          final slot = TimeSlot.fromMap(slotMap);

          return Row(
            children: [
              Expanded(
                child: Text(
                  slot.format(context),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _weeklyAvailability[day]!.removeAt(index);
                    if (_weeklyAvailability[day]!.isEmpty) {
                      _weeklyAvailability.remove(day);
                    }
                  });
                },
              ),
            ],
          );
        }),
        const Divider(),
      ],
    );
  }

  Widget _buildAvailabilityPreview() {
    final days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Availability:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...days.map((day) {
            final slotsData = _weeklyAvailability[day];
            if (slotsData == null || slotsData.isEmpty) {
              return const SizedBox();
            }

            final slots = slotsData.map((slotMap) => TimeSlot.fromMap(slotMap)).toList();
            final dayName = day[0].toUpperCase() + day.substring(1);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(dayName, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: slots.map((slot) {
                        return Chip(
                          label: Text(
                            slot.format(context),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue[50],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (_weeklyAvailability.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('No availability set. Tap edit to add slots.'),
            ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildQuickStats(),
            const SizedBox(height: 24),
            _buildAppointmentsChart(),
            const SizedBox(height: 24),
            _buildUpcomingAppointments(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue[100]!, width: 3)),
                  child: Icon(Icons.person, size: 60, color: Colors.blue[700]),
                ),
                const SizedBox(height: 16),
                Text('Dr. ${widget.doctor.name}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.doctor.specialist, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.medical_services, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text('${widget.doctor.experience} years experience',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.blue[700]),
                  title: const Text('Availability Schedule'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue[700]),
                    onPressed: _showAvailabilityEditor,
                  ),
                ),
                _buildAvailabilityPreview(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                _buildProfileOption(Icons.edit, 'Edit Profile'),
                const Divider(height: 1, indent: 16),
                _buildProfileOption(Icons.work, 'Professional Details'),
                const Divider(height: 1, indent: 16),
                _buildProfileOption(Icons.settings, 'Account Settings'),
                const Divider(height: 1, indent: 16),
                _buildProfileOption(Icons.exit_to_app, 'Logout', isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final allAppointments = UserDataService().getAppointmentsForDoctor(widget.doctor.id);
    final todayAppointments = allAppointments.where((a) => UserDataService().isSameDay(a.dateTime, DateTime.now())).length;
    final pendingAppointments = allAppointments.where((a) => a.status == AppointmentStatus.pending).length;
    final totalApproved = allAppointments.where((a) => a.status == AppointmentStatus.approved).length;
    final totalPatients = allAppointments.map((a) => a.patientId).toSet().length;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      children: [
        _buildStatItem('Today', todayAppointments.toString(), Icons.today, Colors.blue),
        _buildStatItem('Pending', pendingAppointments.toString(), Icons.pending_actions, Colors.orange),
        _buildStatItem('Approved', totalApproved.toString(), Icons.check_circle, Colors.green),
        _buildStatItem('Patients', totalPatients.toString(), Icons.people, Colors.purple),
      ],
    );
  }

  Widget _buildAppointmentsChart() {
    final allAppointments = UserDataService().getAppointmentsForDoctor(widget.doctor.id);

    final pendingCount = allAppointments.where((a) => a.status == AppointmentStatus.pending).length;
    final approvedCount = allAppointments.where((a) => a.status == AppointmentStatus.approved).length;
    final rejectedCount = allAppointments.where((a) => a.status == AppointmentStatus.rejected).length;

    final List<PieChartSectionData> chartSections = [
      _buildChartSection('Pending', pendingCount, Colors.orange, 0),
      _buildChartSection('Approved', approvedCount, Colors.green, 1),
      _buildChartSection('Rejected', rejectedCount, Colors.red, 2),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Appointments Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 60,
                sections: chartSections,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChartLegend(Colors.orange, 'Pending ($pendingCount)'),
              _buildChartLegend(Colors.green, 'Approved ($approvedCount)'),
              _buildChartLegend(Colors.red, 'Rejected ($rejectedCount)'),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildChartSection(String title, int value, Color color, int index) {
    final isTouched = _touchedIndex == index;
    final fontSize = isTouched ? 16.0 : 14.0;
    final radius = isTouched ? 60.0 : 50.0;

    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: value > 0 ? '$value' : '',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color(0xffffffff),
      ),
    );
  }

  Widget _buildChartLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    final upcoming = UserDataService()
        .getAppointmentsForDoctor(widget.doctor.id)
        .where((a) => a.dateTime.isAfter(DateTime.now()) && a.status == AppointmentStatus.approved)
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upcoming Appointments',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          if (upcoming.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text('No upcoming approved appointments.', style: TextStyle(color: Colors.grey[600])),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcoming.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                return _buildAppointmentCard(upcoming[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.now().subtract(const Duration(days: 365)),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _loadAppointmentsForSelectedDay(selectedDay);
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() => _calendarFormat = format);
        }
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(color: Colors.blue.shade700, shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(color: Colors.blue.shade400, shape: BoxShape.circle),
        todayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        weekendTextStyle: TextStyle(
          color: Colors.blue.shade700,
        ),
        defaultTextStyle: const TextStyle(
          color: Colors.black87,
        ),
        outsideTextStyle: TextStyle(
          color: Colors.grey.shade400,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
        formatButtonDecoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
        formatButtonTextStyle: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500),
        titleTextStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Colors.blue[700],
          size: 28,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.blue[700],
          size: 28,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
        weekendStyle: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final patient = UserDataService().patients.firstWhere((p) => p.id == appointment.patientId,
        orElse: () => Patient(id: '', name: 'Unknown', email: '', password: '', mobile: '', dob: '',address: ''));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(patient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
              ),
              _buildStatusChip(appointment.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(_getAppointmentTypeIcon(appointment.type), size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(appointment.type.name.capitalize(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(DateFormat.jm().format(appointment.dateTime), style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ],
          ),
          if (appointment.status == AppointmentStatus.pending) _buildPendingActions(appointment),
          if (appointment.status == AppointmentStatus.approved && appointment.type == AppointmentType.online)
            _buildOnlineActions(appointment),
        ],
      ),
    );
  }

  Widget _buildPendingActions(Appointment appointment) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => _updateAppointmentStatus(appointment, AppointmentStatus.rejected),
            child: const Text('Reject'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onPressed: () => _updateAppointmentStatus(appointment, AppointmentStatus.approved),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppointmentStatus status) {
    Color chipColor;
    String label;
    IconData icon;
    switch (status) {
      case AppointmentStatus.approved:
        chipColor = Colors.green;
        label = 'Approved';
        icon = Icons.check_circle;
        break;
      case AppointmentStatus.rejected:
        chipColor = Colors.red;
        label = 'Rejected';
        icon = Icons.cancel;
        break;
      default:
        chipColor = Colors.orange;
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: chipColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: chipColor, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: chipColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue[700]),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isLogout ? Colors.red : Colors.grey[600]),
      onTap: () {},
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        child: BottomNavigationBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) => setState(() => _currentBottomNavIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue[700],
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  IconData _getAppointmentTypeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.online:
        return Icons.videocam;
      case AppointmentType.offline:
        return Icons.people;
      case AppointmentType.vaccination:
        return Icons.vaccines;
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}