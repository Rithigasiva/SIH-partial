// lib/models/user_models.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_models.g.dart';

// --- ENUMS ---
@HiveType(typeId: 5)
enum AppointmentStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  approved,
  @HiveField(2)
  rejected,
}

@HiveType(typeId: 6)
enum AppointmentType {
  @HiveField(0)
  online,
  @HiveField(1)
  offline,
  @HiveField(2)
  vaccination,
}

// --- NEW NOTIFICATION MODEL ---
@HiveType(typeId: 9) // Using the next available typeId
class AppNotification extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String patientId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String body;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  bool isRead;

  AppNotification({
    required this.id,
    required this.patientId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
}


// --- MODIFIED MEDICINE REQUEST MODEL ---
@HiveType(typeId: 8)
class MedicineRequest extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicineName;

  @HiveField(2)
  final String patientId; // Changed from userEmail

  MedicineRequest({
    required this.id,
    required this.medicineName,
    required this.patientId, // Changed from userEmail
  });
}

// --- MEDICINE ---
@HiveType(typeId: 7)
class Medicine {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String pharmacyId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  int stock;

  Medicine({
    required this.id,
    required this.pharmacyId,
    required this.name,
    required this.stock,
  });

  Medicine copyWith({String? id, String? pharmacyId, String? name, int? stock}) {
    return Medicine(
      id: id ?? this.id,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      name: name ?? this.name,
      stock: stock ?? this.stock,
    );
  }
}

// --- BASE USER ---
class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final String mobile;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
  });
}

// --- PATIENT ---
@HiveType(typeId: 0)
class Patient extends AppUser {
  @HiveField(0)
  @override
  final String id;
  @HiveField(1)
  @override
  final String name;
  @HiveField(2)
  @override
  final String email;
  @HiveField(3)
  @override
  final String password;
  @HiveField(4)
  @override
  final String mobile;
  @HiveField(5)
  final String dob;
  @HiveField(6)
  final String address;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
    required this.dob,
    required this.address,
  }) : super(id: id, name: name, email: email, password: password, mobile: mobile);
}

// --- DOCTOR ---
@HiveType(typeId: 1)
class Doctor extends AppUser {
  @HiveField(0)
  @override
  final String id;
  @HiveField(1)
  @override
  final String name;
  @HiveField(2)
  @override
  final String email;
  @HiveField(3)
  @override
  final String password;
  @HiveField(4)
  @override
  final String mobile;
  @HiveField(5)
  final String hospitalId;
  @HiveField(6)
  final String specialist;
  @HiveField(7)
  final String experience;
  @HiveField(8)
  final List<DateTime> availableSlots;
  @HiveField(9)
  final Map<String, List<Map<String, dynamic>>> weeklyAvailability;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.mobile,
    required this.hospitalId,
    required this.specialist,
    required this.experience,
    this.availableSlots = const [],
    this.weeklyAvailability = const {},
  }) : super(id: id, name: name, email: email, password: password, mobile: mobile);
}

// --- PHARMACY ---
@HiveType(typeId: 2)
class Pharmacy {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String pharmacyName;
  @HiveField(2)
  final String licenseNumber;
  @HiveField(3)
  final String email;
  @HiveField(4)
  final String mobile;
  @HiveField(5)
  final String address;
  @HiveField(6)
  final String password;
  @HiveField(7)
  final double latitude;
  @HiveField(8)
  final double longitude;

  Pharmacy({
    required this.id,
    required this.pharmacyName,
    required this.licenseNumber,
    required this.email,
    required this.mobile,
    required this.address,
    required this.password,
    required this.latitude,
    required this.longitude,
  });
}

// --- APPOINTMENT ---
@HiveType(typeId: 3)
class Appointment extends HiveObject{
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String patientId;
  @HiveField(2)
  final String? doctorId;
  @HiveField(3)
  final String? doctorName;
  @HiveField(4)
  final String? specialty;
  @HiveField(5)
  final DateTime dateTime;
  @HiveField(6)
  final AppointmentStatus status;
  @HiveField(7)
  final AppointmentType type;
  @HiveField(8)
  String? sessionLink;
  @HiveField(9)
  final String hospitalId;
  @HiveField(10)
  final bool isVaccination;
  @HiveField(11)
  final bool paid;

  Appointment({
    required this.id,
    required this.patientId,
    required this.hospitalId,
    this.doctorId,
    this.doctorName,
    this.specialty,
    required this.dateTime,
    this.status = AppointmentStatus.pending,
    this.type = AppointmentType.offline,
    this.sessionLink,
    this.isVaccination = false,
    this.paid = false,
  });
}

// --- HOSPITAL ---
@HiveType(typeId: 4)
class Hospital {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String password;

  @HiveField(5)
  final double latitude;

  @HiveField(6)
  final double longitude;

  @HiveField(7)
  final List<String>? services;

  @HiveField(8)
  final List<String> vaccines;

  @HiveField(9)
  final String? timings;

  @HiveField(10)
  final String? contactNumber;

  @HiveField(11)
  final String? imageUrl;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.password,
    required this.latitude,
    required this.longitude,
    this.services,
    this.vaccines = const [],
    this.timings,
    this.contactNumber,
    this.imageUrl,
  });

  Hospital copyWith({
    String? id,
    String? name,
    String? address,
    String? email,
    String? password,
    double? latitude,
    double? longitude,
    List<String>? services,
    List<String>? vaccines,
    String? timings,
    String? contactNumber,
    String? imageUrl,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      email: email ?? this.email,
      password: password ?? this.password,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
      vaccines: vaccines ?? this.vaccines,
      timings: timings ?? this.timings,
      contactNumber: contactNumber ?? this.contactNumber,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

}

class FamilyMember {
  final String id;
  final String patientId;
  final String name;
  final String relationship;
  final DateTime dateOfBirth;
  final String? gender;
  
  FamilyMember({
    required this.id,
    required this.patientId,
    required this.name,
    required this.relationship,
    required this.dateOfBirth,
    this.gender,
  });
}

class Prescription {
  final String id;
  final String patientId;
  final String doctorName;
  final DateTime date;
  final String diagnosis;
  final List<Medication> medications;

  Prescription({
    required this.id,
    required this.patientId,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    required this.medications,
  });
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });
}

class Receipt {
  final String id;
  final String patientId;
  final DateTime date;
  final double amount;
  final String hospitalName;
  final String service;

  Receipt({
    required this.id,
    required this.patientId,
    required this.date,
    required this.amount,
    required this.hospitalName,
    required this.service,
  });
}
class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  
  TimeSlot({
    required this.startTime,
    required this.endTime,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'endHour': endTime.hour,
      'endMinute': endTime.minute,
    };
  }
  
  static TimeSlot fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      startTime: TimeOfDay(hour: map['startHour'], minute: map['startMinute']),
      endTime: TimeOfDay(hour: map['endHour'], minute: map['endMinute']),
    );
  }
  
  bool contains(TimeOfDay time) {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    final checkMinutes = time.hour * 60 + time.minute;
    
    return checkMinutes >= startMinutes && checkMinutes <= endMinutes;
  }
  
  String format(BuildContext context) {
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }
}