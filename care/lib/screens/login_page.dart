import 'package:flutter/material.dart';
// --- IMPORTS to connect to the data service and new pages ---
import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:care/screens/admin/admin_dashboard_page.dart';
import 'package:care/screens/pharmacy/pharmacy_dashboard_page.dart';
import 'package:care/screens/hospital/hospital_dashboard_page.dart';
import 'package:care/screens/patient/patient_dashboard_page.dart';
import 'package:care/screens/registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole = 'Patient';
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // --- UPDATED LIST of roles to match our system ---
  final List<String> _roles = ['Patient', 'Hospital', 'Pharmacy', 'Admin'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Background decoration
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE3F2FD),
                  Color(0xFFF8F9FA),
                ],
              ),
            ),
          ),
          // Background pattern
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF2A7FBA).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF2A7FBA).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildHeader(),
                  ),
                  Expanded(
                    flex: 3,
                    child: _buildLoginForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated medical icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2A7FBA), Color(0xFF1A5F9A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A7FBA).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_outlined,
            color: Colors.white,
            size: 60,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome to Care+',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A7FBA),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Your trusted healthcare companion for seamless medical services',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6C757D),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Decorative dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(const Color(0xFF2A7FBA)),
            const SizedBox(width: 8),
            _buildDot(const Color(0xFF2A7FBA).withOpacity(0.5)),
            const SizedBox(width: 8),
            _buildDot(const Color(0xFF2A7FBA).withOpacity(0.3)),
          ],
        ),
      ],
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login to Your Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A7FBA),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: const TextStyle(color: Color(0xFF6C757D)),
                prefixIcon: const Icon(Icons.email, color: Color(0xFF2A7FBA)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A7FBA), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Color(0xFF6C757D)),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF2A7FBA)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF6C757D),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A7FBA), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                labelText: 'Login as',
                labelStyle: const TextStyle(color: Color(0xFF6C757D)),
                prefixIcon: const Icon(Icons.person_pin_rounded, color: Color(0xFF2A7FBA)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A7FBA), width: 2),
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
              ),
              items: _roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
              },
              validator: (value) => value == null ? 'Please select a role' : null,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2A7FBA)))
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A7FBA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: Color(0xFF6C757D)),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Register Now',
                    style: TextStyle(
                      color: Color(0xFF2A7FBA),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ## --- UPDATED LOGIN LOGIC --- ##
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      // Simulate network delay
      Future.delayed(const Duration(milliseconds: 500), () {
        final email = _emailController.text;
        final password = _passwordController.text;
        final role = _selectedRole!;

        if (role == 'Admin' && email == 'admin@app.com' && password == 'admin123') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardPage()));
          return;
        }

        final user = UserDataService().validateUser(email, password, role);

        if (user != null) {
          if (user is Patient) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PatientDashboardPage(patient: user)));
          } else if (user is Hospital) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HospitalDashboardPage(hospital: user)));
          } else if (user is Pharmacy) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PharmacyDashboardPage(pharmacy: user)));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Invalid credentials. Please try again or register.'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
        
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}