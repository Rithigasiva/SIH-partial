import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';

enum UserRole { patient, hospital, doctor, pharmacy }

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}
 final List<String> defaultVaccines = [
    'BCG',
    'Hepatitis B',
    'Polio',
    'DTP',
    'MMR',
    'Varicella',
    'Hepatitis A',
    'Typhoid',
    'Influenza',
    'COVID-19'
  ];

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.patient;

  List<Hospital> _hospitals = [];
  Hospital? _selectedHospital;

  // Controllers for all possible fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _dobController = TextEditingController();
  final _specialistController = TextEditingController();
  final _experienceController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();
  final _hospitalLatController = TextEditingController();
  final _hospitalLongController = TextEditingController();
  final _hospitalContactController = TextEditingController();
final _hospitalTimingsController = TextEditingController();
final _hospitalImageController = TextEditingController();
final _hospitalVaccinesController = TextEditingController();



  

  @override
void initState() {
  super.initState();
  _hospitals = UserDataService().hospitals;
  _hospitalVaccinesController.text = defaultVaccines.join(', ');
}


  @override
  void dispose() {
    // Dispose all controllers to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    _specialistController.dispose();
    _experienceController.dispose();
    _pharmacyNameController.dispose();
    _licenseController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _longController.dispose();
    _hospitalLatController.dispose();
    _hospitalLongController.dispose();
    _hospitalContactController.dispose();
_hospitalTimingsController.dispose();
_hospitalImageController.dispose();
_hospitalVaccinesController.dispose();


    super.dispose();
  }

  void _handleRegistration() async {
  if (_formKey.currentState!.validate()) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      switch (_selectedRole) {
        case UserRole.patient:
          final patient = Patient(
            id: id,
            name: _nameController.text,
            dob: _dobController.text,
            email: _emailController.text,
            mobile: _mobileController.text,
            password: _passwordController.text,
            address: _addressController.text,
          );
          await UserDataService().registerPatient(patient);
          break;

        case UserRole.hospital:
          final hospital = Hospital(
            id: id,
            name: _nameController.text,
            address: _addressController.text,
            email: _emailController.text,
            password: _passwordController.text,
            latitude: double.tryParse(_hospitalLatController.text) ?? 0.0,
            longitude: double.tryParse(_hospitalLongController.text) ?? 0.0,
            contactNumber: _hospitalContactController.text,
            timings: _hospitalTimingsController.text,
            imageUrl: _hospitalImageController.text,
             vaccines: _hospitalVaccinesController.text
            .split(',')
            .map((v) => v.trim())
            .where((v) => v.isNotEmpty)
            .toList(),
          );
          await UserDataService().registerHospital(hospital);
          break;

        case UserRole.doctor:
          final doctor = Doctor(
            id: id,
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            mobile: _mobileController.text,
            hospitalId: _selectedHospital!.id,
            specialist: _specialistController.text,
            experience: _experienceController.text,
          );
          await UserDataService().registerDoctor(doctor);
          break;

        case UserRole.pharmacy:
          final pharmacy = Pharmacy(
            id: id,
            pharmacyName: _pharmacyNameController.text,
            licenseNumber: _licenseController.text,
            address: _addressController.text,
            email: _emailController.text,
            mobile: _mobileController.text,
            password: _passwordController.text,
            latitude: double.tryParse(_latController.text) ?? 0.0,
            longitude: double.tryParse(_longController.text) ?? 0.0,
          );
          await UserDataService().registerPharmacy(pharmacy);
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful for ${_selectedRole.name}! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.teal.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join HealthConnect', 
                      textAlign: TextAlign.center, 
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: Colors.teal.shade800,
                        fontSize: 24
                      )
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select Your Role', 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700
                      )
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<UserRole>(
                      style: SegmentedButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        foregroundColor: Colors.teal.shade700,
                        selectedBackgroundColor: Colors.teal.shade700,
                        selectedForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      segments: const <ButtonSegment<UserRole>>[
                        ButtonSegment<UserRole>(value: UserRole.patient, label: Text('Patient'), icon: Icon(Icons.person)),
                        ButtonSegment<UserRole>(value: UserRole.hospital, label: Text('Hospital'), icon: Icon(Icons.business)),
                        ButtonSegment<UserRole>(value: UserRole.doctor, label: Text('Doctor'), icon: Icon(Icons.medical_services)),
                        ButtonSegment<UserRole>(value: UserRole.pharmacy, label: Text('Pharmacy'), icon: Icon(Icons.local_pharmacy)),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (Set<UserRole> newSelection) {
                        setState(() {
                          _formKey.currentState?.reset();
                          _selectedRole = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildDynamicFormFields(),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _handleRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.teal.shade700,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFormFields() {
    switch (_selectedRole) {
      case UserRole.patient:
        return _buildPatientForm();
      case UserRole.hospital:
        return _buildHospitalForm();
      case UserRole.doctor:
        return _buildDoctorForm();
      case UserRole.pharmacy:
        return _buildPharmacyForm();
    }
  }

  Widget _buildPatientForm() {
    return Column(children: [
      TextFormField(
        controller: _nameController, 
        decoration: InputDecoration(
          labelText: 'Full Name', 
          prefixIcon: Icon(Icons.person_outline, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        validator: (v) => v!.isEmpty ? 'Name is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _dobController, 
        decoration: InputDecoration(
          labelText: 'Date of Birth (DD/MM/YYYY)', 
          prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        validator: (v) => v!.isEmpty ? 'Date of Birth is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController, 
        decoration: InputDecoration(
          labelText: 'Email', 
          prefixIcon: Icon(Icons.email_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.emailAddress, 
        validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _mobileController, 
        decoration: InputDecoration(
          labelText: 'Mobile Number', 
          prefixIcon: Icon(Icons.phone_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.phone, 
        validator: (v) => v!.isEmpty ? 'Mobile number is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController, 
        decoration: InputDecoration(
          labelText: 'Password', 
          prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        obscureText: true, 
        validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _addressController, 
        decoration: InputDecoration(
          labelText: 'Address', 
          prefixIcon: Icon(Icons.location_city, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.streetAddress, 
        validator: (v) => v!.isEmpty ? 'Address is required' : null
      ),
    ]);
  }

  Widget _buildHospitalForm() {
  return Column(children: [
    TextFormField(
      controller: _nameController, 
      decoration: InputDecoration(
        labelText: 'Hospital Name', 
        prefixIcon: Icon(Icons.business_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ), 
      validator: (v) => v!.isEmpty ? 'Name is required' : null
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _addressController, 
      decoration: InputDecoration(
        labelText: 'Full Address', 
        prefixIcon: Icon(Icons.location_on_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ), 
      validator: (v) => v!.isEmpty ? 'Address is required' : null
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _emailController, 
      decoration: InputDecoration(
        labelText: 'Official Email', 
        prefixIcon: Icon(Icons.email_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ), 
      keyboardType: TextInputType.emailAddress, 
      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _hospitalLatController, 
      decoration: InputDecoration(
        labelText: 'Latitude', 
        prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ), 
      keyboardType: TextInputType.number, 
      validator: (v) => v!.isEmpty ? 'Latitude is required' : null
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _hospitalLongController, 
      decoration: InputDecoration(
        labelText: 'Longitude', 
        prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ), 
      keyboardType: TextInputType.number, 
      validator: (v) => v!.isEmpty ? 'Longitude is required' : null
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _hospitalContactController,
      decoration: InputDecoration(
        labelText: 'Contact Number',
        prefixIcon: Icon(Icons.phone_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ),
      keyboardType: TextInputType.phone,
      validator: (v) => v!.isEmpty ? 'Contact number is required' : null,
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _hospitalTimingsController,
      decoration: InputDecoration(
        labelText: 'Timings (e.g., 9:00 AM - 5:00 PM)',
        prefixIcon: Icon(Icons.access_time_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Timings are required' : null,
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _hospitalImageController,
      decoration: InputDecoration(
        labelText: 'Image URL',
        prefixIcon: Icon(Icons.image_outlined, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'Image URL is required' : null,
    ),
    const SizedBox(height: 16),
    TextFormField(
      controller: _passwordController, 
      decoration: InputDecoration(
        labelText: 'Password', 
        prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
        ),
      ), 
      obscureText: true, 
      validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null
    ),

    const SizedBox(height: 16),
      TextFormField(
  controller: _hospitalVaccinesController,
  decoration: InputDecoration(
    labelText: 'Available Vaccines (comma separated)',
    prefixIcon: Icon(Icons.medical_services_outlined, color: Colors.teal.shade700),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
    ),
  ),
  maxLines: 2,
),
    
  ]);
}


  Widget _buildDoctorForm() {
    if (_hospitals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.yellow.shade100, 
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200)
        ),
        child: Text(
          'No hospitals have been registered yet. Please register a hospital before adding a doctor.', 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.orange.shade800),
        ),
      );
    }
    return Column(children: [
      DropdownButtonFormField<Hospital>(
        value: _selectedHospital,
        decoration: InputDecoration(
          labelText: 'Select Hospital', 
          prefixIcon: Icon(Icons.business_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ),
        items: _hospitals.map((Hospital hospital) {
          return DropdownMenuItem<Hospital>(
            value: hospital, 
            child: Text(
              hospital.name,
              style: const TextStyle(fontSize: 16),
            )
          );
        }).toList(),
        onChanged: (Hospital? newValue) {
          setState(() {
            _selectedHospital = newValue;
          });
        },
        validator: (value) => value == null ? 'Please select a hospital' : null,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        icon: Icon(Icons.arrow_drop_down, color: Colors.teal.shade700),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _nameController, 
        decoration: InputDecoration(
          labelText: 'Full Name', 
          prefixIcon: Icon(Icons.person_outline, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        validator: (v) => v!.isEmpty ? 'Name is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController, 
        decoration: InputDecoration(
          labelText: 'Email', 
          prefixIcon: Icon(Icons.email_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.emailAddress, 
        validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _mobileController, 
        decoration: InputDecoration(
          labelText: 'Mobile Number', 
          prefixIcon: Icon(Icons.phone_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.phone, 
        validator: (v) => v!.isEmpty ? 'Mobile number is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _specialistController, 
        decoration: InputDecoration(
          labelText: 'Specialist In (e.g., Cardiology)', 
          prefixIcon: Icon(Icons.star_outline, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        validator: (v) => v!.isEmpty ? 'Specialty is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _experienceController, 
        decoration: InputDecoration(
          labelText: 'Years of Experience', 
          prefixIcon: Icon(Icons.work_history_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.number, 
        validator: (v) => v!.isEmpty ? 'Experience is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController, 
        decoration: InputDecoration(
          labelText: 'Password', 
          prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        obscureText: true, 
        validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null
      ),

      

          ]);
  }

  Widget _buildPharmacyForm() {
    return Column(children: [
      TextFormField(
        controller: _pharmacyNameController, 
        decoration: InputDecoration(
          labelText: 'Pharmacy Name', 
          prefixIcon: Icon(Icons.store_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        validator: (v) => v!.isEmpty ? 'Pharmacy name is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _licenseController, 
        decoration: InputDecoration(
          labelText: 'Registration / License Number', 
          prefixIcon: Icon(Icons.badge_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        validator: (v) => v!.isEmpty ? 'License is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _emailController, 
        decoration: InputDecoration(
          labelText: 'Contact Email', 
          prefixIcon: Icon(Icons.email_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.emailAddress, 
        validator: (v) => v!.isEmpty || !v.contains('@') ? 'Enter a valid email' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _mobileController, 
        decoration: InputDecoration(
          labelText: 'Contact Mobile Number', 
          prefixIcon: Icon(Icons.phone_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.phone, 
        validator: (v) => v!.isEmpty ? 'Mobile number is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _addressController, 
        decoration: InputDecoration(
          labelText: 'Full Address', 
          prefixIcon: Icon(Icons.location_on_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        validator: (v) => v!.isEmpty ? 'Address is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _latController, 
        decoration: InputDecoration(
          labelText: 'Latitude', 
          prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.number, 
        validator: (v) => v!.isEmpty ? 'Latitude is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _longController, 
        decoration: InputDecoration(
          labelText: 'Longitude', 
          prefixIcon: Icon(Icons.pin_drop_outlined, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        keyboardType: TextInputType.number, 
        validator: (v) => v!.isEmpty ? 'Longitude is required' : null
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _passwordController, 
        decoration: InputDecoration(
          labelText: 'Password', 
          prefixIcon: Icon(Icons.lock_outline, color: Colors.teal.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
          ),
        ), 
        obscureText: true, 
        validator: (v) => v!.length < 6 ? 'Password must be at least 6 characters' : null
      ),
    ]);
  }
}