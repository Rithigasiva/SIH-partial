// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 9;

  @override
  AppNotification read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNotification(
      id: fields[0] as String,
      patientId: fields[1] as String,
      title: fields[2] as String,
      body: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isRead: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNotificationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicineRequestAdapter extends TypeAdapter<MedicineRequest> {
  @override
  final int typeId = 8;

  @override
  MedicineRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicineRequest(
      id: fields[0] as String,
      medicineName: fields[1] as String,
      patientId: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MedicineRequest obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicineName)
      ..writeByte(2)
      ..write(obj.patientId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 7;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      id: fields[0] as String,
      pharmacyId: fields[1] as String,
      name: fields[2] as String,
      stock: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pharmacyId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.stock);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String,
      mobile: fields[4] as String,
      dob: fields[5] as String,
      address: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.mobile)
      ..writeByte(5)
      ..write(obj.dob)
      ..writeByte(6)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DoctorAdapter extends TypeAdapter<Doctor> {
  @override
  final int typeId = 1;

  @override
  Doctor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Doctor(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      password: fields[3] as String,
      mobile: fields[4] as String,
      hospitalId: fields[5] as String,
      specialist: fields[6] as String,
      experience: fields[7] as String,
      availableSlots: (fields[8] as List).cast<DateTime>(),
      weeklyAvailability: (fields[9] as Map).map((dynamic k, dynamic v) =>
          MapEntry(
              k as String,
              (v as List)
                  .map((dynamic e) => (e as Map).cast<String, dynamic>())
                  .toList())),
    );
  }

  @override
  void write(BinaryWriter writer, Doctor obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.mobile)
      ..writeByte(5)
      ..write(obj.hospitalId)
      ..writeByte(6)
      ..write(obj.specialist)
      ..writeByte(7)
      ..write(obj.experience)
      ..writeByte(8)
      ..write(obj.availableSlots)
      ..writeByte(9)
      ..write(obj.weeklyAvailability);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PharmacyAdapter extends TypeAdapter<Pharmacy> {
  @override
  final int typeId = 2;

  @override
  Pharmacy read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pharmacy(
      id: fields[0] as String,
      pharmacyName: fields[1] as String,
      licenseNumber: fields[2] as String,
      email: fields[3] as String,
      mobile: fields[4] as String,
      address: fields[5] as String,
      password: fields[6] as String,
      latitude: fields[7] as double,
      longitude: fields[8] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Pharmacy obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pharmacyName)
      ..writeByte(2)
      ..write(obj.licenseNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.mobile)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.password)
      ..writeByte(7)
      ..write(obj.latitude)
      ..writeByte(8)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PharmacyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentAdapter extends TypeAdapter<Appointment> {
  @override
  final int typeId = 3;

  @override
  Appointment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Appointment(
      id: fields[0] as String,
      patientId: fields[1] as String,
      hospitalId: fields[9] as String,
      doctorId: fields[2] as String?,
      doctorName: fields[3] as String?,
      specialty: fields[4] as String?,
      dateTime: fields[5] as DateTime,
      status: fields[6] as AppointmentStatus,
      type: fields[7] as AppointmentType,
      sessionLink: fields[8] as String?,
      isVaccination: fields[10] as bool,
      paid: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Appointment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.doctorId)
      ..writeByte(3)
      ..write(obj.doctorName)
      ..writeByte(4)
      ..write(obj.specialty)
      ..writeByte(5)
      ..write(obj.dateTime)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.sessionLink)
      ..writeByte(9)
      ..write(obj.hospitalId)
      ..writeByte(10)
      ..write(obj.isVaccination)
      ..writeByte(11)
      ..write(obj.paid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HospitalAdapter extends TypeAdapter<Hospital> {
  @override
  final int typeId = 4;

  @override
  Hospital read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hospital(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      email: fields[3] as String,
      password: fields[4] as String,
      latitude: fields[5] as double,
      longitude: fields[6] as double,
      services: (fields[7] as List?)?.cast<String>(),
      vaccines: (fields[8] as List).cast<String>(),
      timings: fields[9] as String?,
      contactNumber: fields[10] as String?,
      imageUrl: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Hospital obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.latitude)
      ..writeByte(6)
      ..write(obj.longitude)
      ..writeByte(7)
      ..write(obj.services)
      ..writeByte(8)
      ..write(obj.vaccines)
      ..writeByte(9)
      ..write(obj.timings)
      ..writeByte(10)
      ..write(obj.contactNumber)
      ..writeByte(11)
      ..write(obj.imageUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HospitalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentStatusAdapter extends TypeAdapter<AppointmentStatus> {
  @override
  final int typeId = 5;

  @override
  AppointmentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppointmentStatus.pending;
      case 1:
        return AppointmentStatus.approved;
      case 2:
        return AppointmentStatus.rejected;
      default:
        return AppointmentStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, AppointmentStatus obj) {
    switch (obj) {
      case AppointmentStatus.pending:
        writer.writeByte(0);
        break;
      case AppointmentStatus.approved:
        writer.writeByte(1);
        break;
      case AppointmentStatus.rejected:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppointmentTypeAdapter extends TypeAdapter<AppointmentType> {
  @override
  final int typeId = 6;

  @override
  AppointmentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppointmentType.online;
      case 1:
        return AppointmentType.offline;
      case 2:
        return AppointmentType.vaccination;
      default:
        return AppointmentType.online;
    }
  }

  @override
  void write(BinaryWriter writer, AppointmentType obj) {
    switch (obj) {
      case AppointmentType.online:
        writer.writeByte(0);
        break;
      case AppointmentType.offline:
        writer.writeByte(1);
        break;
      case AppointmentType.vaccination:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
