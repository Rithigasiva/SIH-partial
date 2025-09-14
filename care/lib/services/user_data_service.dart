// lib/services/user_data_service.dart

import 'package:care/models/user_models.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class UserDataService {
  // Singleton
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  // Hive Boxes
  final Box<Patient> _patientsBox = Hive.box('patients');
  final Box<Doctor> _doctorsBox = Hive.box('doctors');
  final Box<Pharmacy> _pharmaciesBox = Hive.box('pharmacies');
  final Box<Hospital> _hospitalsBox = Hive.box('hospitals');
  final Box<Appointment> _appointmentsBox = Hive.box('appointments');
  final Box<Medicine> _medicinesBox = Hive.box('medicines');
  final Box<MedicineRequest> _medicineRequestsBox = Hive.box('medicineRequests');
  final Box<AppNotification> _appNotificationsBox = Hive.box('appNotifications');


  // --- Getters ---
  List<Patient> get patients => _patientsBox.values.toList();
  List<Doctor> get doctors => _doctorsBox.values.toList();
  List<Pharmacy> get pharmacies => _pharmaciesBox.values.toList();
  List<Hospital> get hospitals => _hospitalsBox.values.toList();
  List<Medicine> get medicines => _medicinesBox.values.toList();

  // --- Registration & Deletion ---
  Future<void> registerPatient(Patient patient) async => await _patientsBox.put(patient.id, patient);
  Future<void> registerDoctor(Doctor doctor) async => await _doctorsBox.put(doctor.id, doctor);
  Future<void> registerPharmacy(Pharmacy pharmacy) async => await _pharmaciesBox.put(pharmacy.id, pharmacy);
  Future<void> registerHospital(Hospital hospital) async => await _hospitalsBox.put(hospital.id, hospital);

  dynamic validateUser(String email, String password, String role) {
    try {
      if (role == 'Patient') return patients.firstWhere((p) => p.email == email && p.password == password);
      if (role == 'Doctor') return doctors.firstWhere((d) => d.email == email && d.password == password);
      if (role == 'Hospital') return hospitals.firstWhere((h) => h.email == email && h.password == password);
      if (role == 'Pharmacy') return pharmacies.firstWhere((p) => p.email == email && p.password == password);
    } catch (e) {
      return null;
    }
    return null;
  }
  Future<void> deleteUser(dynamic user) async {
    if (user is Patient) await _patientsBox.delete(user.id);
    else if (user is Doctor) await _doctorsBox.delete(user.id);
    else if (user is Pharmacy) await _pharmaciesBox.delete(user.id);
    else if (user is Hospital) await _hospitalsBox.delete(user.id);
  }

  // --- Notification & Medicine Request Logic ---
  Future<void> addMedicineRequest(MedicineRequest request) async {
    await _medicineRequestsBox.put(request.id, request);
  }

  Future<void> _checkRequestsAndCreateNotifications(Medicine addedMedicine) async {
    final matchingRequests = _medicineRequestsBox.values
        .where((req) => req.medicineName.toLowerCase() == addedMedicine.name.toLowerCase())
        .toList();

    if (matchingRequests.isEmpty) return;

    final pharmacy = _pharmaciesBox.get(addedMedicine.pharmacyId);
    if (pharmacy == null) return;

    for (final request in matchingRequests) {
      final notification = AppNotification(
        id: const Uuid().v4(),
        patientId: request.patientId,
        title: 'Medicine Now Available!',
        body: '"${addedMedicine.name}" is now in stock at ${pharmacy.pharmacyName}.',
        createdAt: DateTime.now(),
      );
      await _appNotificationsBox.put(notification.id, notification);
      await _medicineRequestsBox.delete(request.key);
    }
  }
  
  List<AppNotification> getNotificationsForPatient(String patientId) {
    return _appNotificationsBox.values
        .where((n) => n.patientId == patientId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markNotificationsAsRead(List<AppNotification> notifications) async {
    for (final notification in notifications) {
      if (!notification.isRead) {
        notification.isRead = true;
        await notification.save();
      }
    }
  }

  // --- NEW: Function to delete a single notification ---
  Future<void> deleteNotification(String notificationId) async {
    await _appNotificationsBox.delete(notificationId);
  }


  // --- Appointment Management ---
  Future<void> bookAppointment(Appointment appointment) async => await _appointmentsBox.put(appointment.id, appointment);

  List<Appointment> getAppointmentsForPatient(String patientId) =>
      _appointmentsBox.values.where((appt) => appt.patientId == patientId).toList();

  List<Doctor> getDoctorsForHospital(String hospitalId) =>
      doctors.where((doctor) => doctor.hospitalId == hospitalId).toList();

  List<Appointment> getAppointmentsForDoctor(String doctorId) =>
      _appointmentsBox.values.where((appt) => appt.doctorId == doctorId).toList();

  List<Appointment> getAppointmentsForHospital(String hospitalId) =>
      _appointmentsBox.values.where((appt) => appt.hospitalId == hospitalId).toList();

  Future<void> addSessionLink(String appointmentId, String link) async {
    final appointment = _appointmentsBox.get(appointmentId);
    if (appointment != null) {
      appointment.sessionLink = link;
      await appointment.save();
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    final appointment = _appointmentsBox.get(appointmentId);
    if (appointment != null) {
      final updatedAppointment = Appointment(
        id: appointment.id,
        patientId: appointment.patientId,
        hospitalId: appointment.hospitalId,
        doctorId: appointment.doctorId,
        doctorName: appointment.doctorName,
        specialty: appointment.specialty,
        dateTime: appointment.dateTime,
        status: status,
        type: appointment.type,
        sessionLink: appointment.sessionLink,
        isVaccination: appointment.isVaccination,
        paid: appointment.paid,
      );
      await _appointmentsBox.put(appointmentId, updatedAppointment);
    }
  }
  
  Future<void> markAppointmentAsPaid(String appointmentId) async {
    final appointment = _appointmentsBox.get(appointmentId);
    if (appointment != null) {
       final updatedAppointment = Appointment(
        id: appointment.id, patientId: appointment.patientId, hospitalId: appointment.hospitalId,
        doctorId: appointment.doctorId, doctorName: appointment.doctorName, specialty: appointment.specialty,
        dateTime: appointment.dateTime, status: appointment.status, type: appointment.type,
        isVaccination: appointment.isVaccination, paid: true, sessionLink: appointment.sessionLink,
      );
      await _appointmentsBox.put(appointmentId, updatedAppointment);
    }
  }

  Future<void> addMedicine(Medicine medicine) async {
    await _medicinesBox.put(medicine.id, medicine);
    await _checkRequestsAndCreateNotifications(medicine);
  }

  Future<void> updateMedicineStock(Medicine updatedMedicine) async {
    await _medicinesBox.put(updatedMedicine.id, updatedMedicine);
    await _checkRequestsAndCreateNotifications(updatedMedicine);
  }

  Future<void> deleteMedicine(Medicine medicine) async => await _medicinesBox.delete(medicine.id);
  List<Medicine> getMedicinesForPharmacy(String pharmacyId) => medicines.where((m) => m.pharmacyId == pharmacyId).toList();

  List<TimeSlot> getDoctorAvailability(Doctor doctor, DateTime date) {
    final dayName = DateFormat('EEEE').format(date).toLowerCase();
    final slotsData = doctor.weeklyAvailability[dayName] ?? [];
    return slotsData.map((slotMap) => TimeSlot.fromMap(slotMap)).toList();
  }

  bool isDoctorAvailable(Doctor doctor, DateTime dateTime) {
    final dayName = DateFormat('EEEE').format(dateTime).toLowerCase();
    final slotsData = doctor.weeklyAvailability[dayName] ?? [];
    final time = TimeOfDay.fromDateTime(dateTime);
    
    return slotsData.any((slotMap) {
      final slot = TimeSlot.fromMap(slotMap);
      return slot.contains(time);
    });
  }

  List<Doctor> getAvailableDoctors(DateTime dateTime, String specialty) {
    return doctors.where((doctor) {
      final hasSpecialty = specialty.isEmpty || doctor.specialist.toLowerCase().contains(specialty.toLowerCase());
      return hasSpecialty && isDoctorAvailable(doctor, dateTime);
    }).toList();
  }

  Future<void> updateDoctorAvailability(String doctorId, Map<String, List<Map<String, dynamic>>> weeklyAvailability) async {
    final doctor = _doctorsBox.get(doctorId);
    if (doctor != null) {
      final updatedDoctor = Doctor(
        id: doctor.id,
        name: doctor.name,
        email: doctor.email,
        password: doctor.password,
        mobile: doctor.mobile,
        hospitalId: doctor.hospitalId,
        specialist: doctor.specialist,
        experience: doctor.experience,
        availableSlots: doctor.availableSlots,
        weeklyAvailability: weeklyAvailability,
      );
      await _doctorsBox.put(doctorId, updatedDoctor);
    }
  }

  bool hasAppointmentConflict(String doctorId, DateTime dateTime) {
    final doctorAppointments = getAppointmentsForDoctor(doctorId);
    return doctorAppointments.any((appt) {
      return isSameDay(appt.dateTime, dateTime) && 
             appt.status != AppointmentStatus.rejected &&
             _isTimeOverlap(appt.dateTime, dateTime);
    });
  }

  bool _isTimeOverlap(DateTime time1, DateTime time2) {
    final difference = time1.difference(time2).abs();
    return difference.inMinutes < 30;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}