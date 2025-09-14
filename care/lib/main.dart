import 'package:care/models/user_models.dart';
import 'package:care/screens/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await dotenv.load(fileName: ".env");
  // ✅ Register all adapters
  Hive.registerAdapter(PatientAdapter());
  Hive.registerAdapter(DoctorAdapter());
  Hive.registerAdapter(PharmacyAdapter());
  Hive.registerAdapter(AppointmentAdapter());
  Hive.registerAdapter(HospitalAdapter());
  Hive.registerAdapter(AppointmentStatusAdapter());
  Hive.registerAdapter(AppointmentTypeAdapter());
  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(MedicineRequestAdapter()); // For requests
Hive.registerAdapter(AppNotificationAdapter()); // For notifications

await Hive.openBox<MedicineRequest>('medicineRequests');
await Hive.openBox<AppNotification>('appNotifications');
  // ✅ Open Hive boxes
  await Hive.openBox<Patient>('patients');
  await Hive.openBox<Doctor>('doctors');
  await Hive.openBox<Pharmacy>('pharmacies');
  await Hive.openBox<Hospital>('hospitals');
  await Hive.openBox<Appointment>('appointments');
  await Hive.openBox<Medicine>('medicines');
  await Hive.openBox<MedicineRequest>('medicineRequests');
  // ✅ Insert sample data only if empty
  await _addInitialData();

  runApp(const MyApp());
}

/// --- Function to load hospitals & pharmacies only once ---
Future<void> _addInitialData() async {
  final hospitalBox = Hive.box<Hospital>('hospitals');
  final pharmacyBox = Hive.box<Pharmacy>('pharmacies');

  if (hospitalBox.isEmpty && pharmacyBox.isEmpty) {
    final hospitals = [
      Hospital(
        id: 'h1',
        name: 'Civil Hospital, Nabha',
        address: 'Chandni Chowk, Nabha',
        email: 'civil@nabha.gov',
        password: 'password',
        latitude: 30.3724,
        longitude: 76.1555,
        vaccines: ['BCG', 'Hepatitis B', 'Polio'],
        timings: '9:00 AM - 5:00 PM',
        contactNumber: '9876543210',
        imageUrl:
            'https://www.unicef.org/laos/sites/unicef.org.laos/files/styles/press_release_feature/public/2I3A8686.webp?itok=DCErDlVa',
      ),
      Hospital(
        id: 'h2',
        name: 'Akal Charitable Hospital',
        address: 'Near Bus Stand, Nabha',
        email: 'akal@hospital.com',
        password: 'password',
        latitude: 30.3788,
        longitude: 76.1495,
        vaccines: ['MMR', 'DTP'],
        timings: '10:00 AM - 6:00 PM',
        contactNumber: '9876543211',
        imageUrl:
            'https://www.tribuneindia.com/sortd-service/imaginary/v22-01/jpg/large/high?url=dGhldHJpYnVuZS1zb3J0ZC1wcm8tcHJvZC1zb3J0ZC9tZWRpYTA3MTVlMWYwLTRlOGItMTFlZi1iY2VhLWU1MDI2ZDljNzJmMi5qcGc=',
      ),
  Hospital(
    id: 'h3',
    name: 'Jindal Hospital',
    address: 'Patiala Gate, Nabha',
    email: 'jindal@hospital.com',
    password: 'password',
    latitude: 30.3691,
    longitude: 76.1511,
    vaccines: [], // No vaccination
    timings: '9:00 AM - 5:00 PM',
    contactNumber: '9876543212',
    imageUrl: 'https://images.unsplash.com/photo-1588776814546-d9ae49f826d6?w=600&h=200&fit=crop',
  ),
  Hospital(
    id: 'h4',
    name: 'Gupta Hospital',
    address: 'Bypass Road, Nabha',
    email: 'gupta@hospital.com',
    password: 'password',
    latitude: 30.3810,
    longitude: 76.1580,
    vaccines: ['Hepatitis A', 'Polio'],
    timings: '9:30 AM - 4:30 PM',
    contactNumber: '9876543213',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTLVQdIJIG-fFA4avUrFrlXZuH3Pv7Bisy4BYtqN1Q-Sb1o_Z1dEkdKHp2StnbvkVKqiTc&usqp=CAU',
  ),
  Hospital(
    id: 'h5',
    name: 'Sharma Nursing Home',
    address: 'Circular Road, Nabha',
    email: 'sharma@hospital.com',
    password: 'password',
    latitude: 30.3795,
    longitude: 76.1532,
    vaccines: [], // No vaccination
    timings: '10:00 AM - 5:00 PM',
    contactNumber: '9876543214',
    imageUrl: 'https://images.unsplash.com/photo-1588776814546-d9ae49f826d6?w=600&h=200&fit=crop',
  ),
  Hospital(
    id: 'h6',
    name: 'Verma Hospital',
    address: 'Model Town, Nabha',
    email: 'verma@hospital.com',
    password: 'password',
    latitude: 30.3821,
    longitude: 76.1519,
    vaccines: ['BCG', 'DTP', 'Polio'],
    timings: '9:00 AM - 6:00 PM',
    contactNumber: '9876543215',
    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQOnARlUZp0C8hYsqkW0V7K9ixisCLbiAwJ2hZ551bGj7W4Qedi8I1YOnmlYJNTkBu9qyg&usqp=CAU',
  ),
  Hospital(
    id: 'h7',
    name: 'Mehta Chowk Hospital',
    address: 'Mehta Chowk, Nabha',
    email: 'mehta@hospital.com',
    password: 'password',
    latitude: 30.3711,
    longitude: 76.1578,
    vaccines: [], // No vaccination
    timings: '9:00 AM - 5:00 PM',
    contactNumber: '9876543216',
    imageUrl: 'https://images.unsplash.com/photo-1588776814546-d9ae49f826d6?w=600&h=200&fit=crop',
  ),
  Hospital(
    id: 'h8',
    name: 'Santokh Hospital',
    address: 'Duladdi Gate, Nabha',
    email: 'santokh@hospital.com',
    password: 'password',
    latitude: 30.3685,
    longitude: 76.1570,
    vaccines: ['Hepatitis B', 'MMR'],
    timings: '8:30 AM - 4:30 PM',
    contactNumber: '9876543217',
    imageUrl: 'https://images.cnbctv18.com/wp-content/uploads/2021/03/covid-4-1019x573.jpg',
  ),
  Hospital(
    id: 'h9',
    name: 'Nabha Heart Centre',
    address: 'Patiala Road, Nabha',
    email: 'nabhaheart@hospital.com',
    password: 'password',
    latitude: 30.3670,
    longitude: 76.1612,
    vaccines: [], // No vaccination
    timings: '9:00 AM - 5:00 PM',
    contactNumber: '9876543218',
    imageUrl: 'https://images.unsplash.com/photo-1588776814546-d9ae49f826d6?w=600&h=200&fit=crop',
  ),
  Hospital(
    id: 'h10',
    name: 'City Care Hospital',
    address: 'Heera Mahal Colony, Nabha',
    email: 'citycare@hospital.com',
    password: 'password',
    latitude: 30.3808,
    longitude: 76.1490,
    vaccines: ['BCG', 'Polio', 'DTP'],
    timings: '9:00 AM - 6:00 PM',
    contactNumber: '9876543219',
    imageUrl: 'https://images.cnbctv18.com/wp-content/uploads/2021/04/covid-10-768x432.jpg',
  ),
      // Add other hospitals here (h3 - h10)...
    ];

    final pharmacies = [
      Pharmacy(
        id: 'p1',
        pharmacyName: 'Prem Medical Store',
        licenseNumber: 'PB12345',
        address: 'Sadar Bazar, Nabha',
        email: 'prem@med.com',
        mobile: '9876543210',
        password: 'password',
        latitude: 30.3751,
        longitude: 76.1523,
      ),
      Pharmacy(
        id: 'p2',
        pharmacyName: 'Munish Med Hall',
        licenseNumber: 'PB12346',
        address: 'Circular Road, Nabha',
        email: 'munish@med.com',
        mobile: '9876543211',
        password: 'password',
        latitude: 30.3792,
        longitude: 76.1548,
      ),
      // Add other pharmacies here (p3 - p15)...
      Pharmacy(id: 'p3', pharmacyName: 'Mittal Medicos', licenseNumber: 'PB12347', address: 'Near Fauji Gali, Nabha', email: 'mittal@med.com', mobile: '9876543212', password: 'password', latitude: 30.3735, longitude: 76.1499),
      Pharmacy(id: 'p4', pharmacyName: 'Aggarwal Medical Agency', licenseNumber: 'PB12348', address: 'Duladdi Gate, Nabha', email: 'aggarwal@med.com', mobile: '9876543213', password: 'password', latitude: 30.3689, longitude: 76.1567),
      Pharmacy(id: 'p5', pharmacyName: 'Jain Medical Store', licenseNumber: 'PB12349', address: 'Kartarpur, Nabha', email: 'jain@med.com', mobile: '9876543214', password: 'password', latitude: 30.3762, longitude: 76.1478),
      Pharmacy(id: 'p6', pharmacyName: 'Singla Pharmacy', licenseNumber: 'PB12350', address: 'Heera Mahal Colony, Nabha', email: 'singla@med.com', mobile: '9876543215', password: 'password', latitude: 30.3805, longitude: 76.1501),
      Pharmacy(id: 'p7', pharmacyName: 'Goyal Medical Hall', licenseNumber: 'PB12351', address: 'Alhoran Gate, Nabha', email: 'goyal@med.com', mobile: '9876543216', password: 'password', latitude: 30.3701, longitude: 76.1593),
      Pharmacy(id: 'p8', pharmacyName: 'Royal Medicos', licenseNumber: 'PB12352', address: 'Model Town, Nabha', email: 'royal@med.com', mobile: '9876543217', password: 'password', latitude: 30.3822, longitude: 76.1534),
      Pharmacy(id: 'p9', pharmacyName: 'Verma Medical Store', licenseNumber: 'PB12353', address: 'Old Bus Stand, Nabha', email: 'verma@med.com', mobile: '9876543218', password: 'password', latitude: 30.3749, longitude: 76.1576),
      Pharmacy(id: 'p10', pharmacyName: 'National Medicos', licenseNumber: 'PB12354', address: 'Near Post Office, Nabha', email: 'national@med.com', mobile: '9876543219', password: 'password', latitude: 30.3718, longitude: 76.1529),
      Pharmacy(id: 'p11', pharmacyName: 'Punjab Medical Hall', licenseNumber: 'PB12355', address: 'Patiala Road, Nabha', email: 'punjab@med.com', mobile: '9876543220', password: 'password', latitude: 30.3675, longitude: 76.1610),
      Pharmacy(id: 'p12', pharmacyName: 'Friends Medicos', licenseNumber: 'PB12356', address: 'Bank Street, Nabha', email: 'friends@med.com', mobile: '9876543221', password: 'password', latitude: 30.3758, longitude: 76.1561),
      Pharmacy(id: 'p13', pharmacyName: 'Kansal Medicos', licenseNumber: 'PB12357', address: 'Circular Road, Nabha', email: 'kansal@med.com', mobile: '9876543222', password: 'password', latitude: 30.3780, longitude: 76.1555),
      Pharmacy(id: 'p14', pharmacyName: 'Shanti Medicos', licenseNumber: 'PB12358', address: 'Sadar Bazar, Nabha', email: 'shanti@med.com', mobile: '9876543223', password: 'password', latitude: 30.3745, longitude: 76.1530),
      Pharmacy(id: 'p15', pharmacyName: 'New Nabha Pharmacy', licenseNumber: 'PB12359', address: 'Patiala Gate, Nabha', email: 'newnabha@med.com', mobile: '9876543224', password: 'password', latitude: 30.3698, longitude: 76.1518),
    ];

    for (var hospital in hospitals) {
      await hospitalBox.put(hospital.id, hospital);
    }
    for (var pharmacy in pharmacies) {
      await pharmacyBox.put(pharmacy.id, pharmacy);
    }
  }
}

/// --- Main Application ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthConnect',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
    );
  }
}
