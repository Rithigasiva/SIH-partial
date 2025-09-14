import 'package:care/screens/login_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide CarouselController;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isPunjabi = false;
  final List<_HospitalInfo> _hospitals = [
    _HospitalInfo(
      isGovernment: true,
      name: 'Civil Hospital, Nabha',
      description: 'The primary government healthcare facility in Nabha, providing a wide range of medical services to the public.',
      imageUrl: 'https://images.bhaskarassets.com/web2images/521/2020/09/12/11batala-gurudaspur-bhaskar-pg1-0_1599860005.jpg',
      namePunjabi: 'ਸਿਵਲ ਹਸਪਤਾਲ, ਨਾਭਾ',
      descriptionPunjabi: 'ਨਾਭਾ ਵਿੱਚ ਪ੍ਰਾਇਮਰੀ ਸਰਕਾਰੀ ਸਿਹਤ ਸੁਵਿਧਾ, ਜਨਤਾ ਨੂੰ ਵਿਸਤ੍ਰਿਤ ਡਾਕਟਰੀ ਸੇਵਾਵਾਂ ਪ੍ਰਦਾਨ ਕਰਦੀ ਹੈ।',
    ),
    _HospitalInfo(
      name: 'Akal Hospital', 
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRLhLeCLrjZT4h-KzyzqSWezYN3gkaoekynKw&s',
      namePunjabi: 'ਅਕਾਲ ਹਸਪਤਾਲ'
    ),
    _HospitalInfo(
      name: 'Jindal Hospital', 
      imageUrl: 'https://content.jdmagicbox.com/comp/muktsar/l7/9999p1633.1633.170927185000.a5l7/catalogue/jindal-hospital-and-heart-centre-sri-muktsar-sahib-muktsar-hospitals-ieqctjt9p6.jpg',
      namePunjabi: 'ਜਿੰਦਲ ਹਸਪਤਾਲ'
    ),
    _HospitalInfo(
      name: 'Rajindra Hospital', 
      imageUrl: 'https://content3.jdmagicbox.com/comp/nabha/y6/9999p1765.1765.220713210556.g7y6/catalogue/raj-general-hospital-nabha-ho-nabha-hospitals-06427mregg.jpg',
      namePunjabi: 'ਰਾਜਿੰਦਰਾ ਹਸਪਤਾਲ'
    ),
    _HospitalInfo(
      name: 'Gupta Hospital', 
      imageUrl: 'https://content.jdmagicbox.com/comp/bhatinda/g7/9999px164.x164.200314194625.g5g7/catalogue/gupta-hospital-batinda-bhatinda-orthopaedic-hospitals-gtppf9ds19.jpg',
      namePunjabi: 'ਗੁਪਤਾ ਹਸਪਤਾਲ'
    ),
    _HospitalInfo(
      name: 'Prem Medicals', 
      imageUrl: 'https://content3.jdmagicbox.com/v2/comp/nabha/l9/9999p1765.1765.140616103549.l2l9/catalogue/prem-medical-store-bhawra-bazar-nabha-chemists-c1caq84idl.jpg',
      namePunjabi: 'ਪ੍ਰੇਮ ਮੈਡੀਕਲਸ'
    ),
    _HospitalInfo(
      name: 'Munish Med Hall', 
      imageUrl: 'https://content.jdmagicbox.com/comp/mohali/j1/0172px172.x172.110617102652.a6j1/catalogue/munish-medical-hall-mohali-wi8th.jpg',
      namePunjabi: 'ਮੁਨੀਸ਼ ਮੈਡ ਹਾਲ'
    ),
    _HospitalInfo(
      name: 'Mittal Mediclas', 
      imageUrl: 'https://content3.jdmagicbox.com/comp/nabha/m8/9999p1765.1765.221225142855.r1m8/catalogue/mittal-superspeciality-dental-hospital-nabha-clinics-8v4b7mpswu.jpg',
      namePunjabi: 'ਮਿੱਤਲ ਮੈਡੀਕਲਸ'
    ),
    _HospitalInfo(
      name: 'Sharma Nursing Home', 
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSC8u-Vo_2eHsCMIFls_SPefHrfrj7J8RHXHw&s',
      namePunjabi: 'ਸ਼ਰਮਾ ਨਰਸਿੰਗ ਹੋਮ'
    ),
    _HospitalInfo(
      name: 'Verma Hospital', 
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTZrPpb7mkiz8LJgIxlKVu-KGR94mE4UbLsUw&s',
      namePunjabi: 'ਵਰਮਾ ਹਸਪਤਾਲ'
    ),
  ];

  // Text translations
  final Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': 'Care+',
      'loginButton': 'Login / Sign Up',
      'heroTitle': 'Your Health, Your Way',
      'heroSubtitle': 'Seamlessly connect with trusted hospitals and doctors, manage appointments, and access nearby pharmacies all in one place.',
      'getStarted': 'Get Started Now',
      'howItWorks': 'How It Works',
      'step1Title': 'Find Hospitals & Doctors',
      'step1Subtitle': 'Browse verified hospitals and find the right specialist.',
      'step2Title': 'Book Your Slot',
      'step2Subtitle': 'Choose a convenient time for an online or offline consultation.',
      'step3Title': 'Get Consultation',
      'step3Subtitle': 'Connect with your doctor via secure video call or visit the clinic.',
      'step4Title': 'Receive Prescription',
      'step4Subtitle': 'Get your digital prescription instantly in the app.',
      'hospitals': 'Hospitals in Nabha',
      'privateHospitals': 'Our Network of Private Hospitals',
      'government': 'Government',
      'whyChooseUs': 'Why Choose Us?',
      'benefit1Title': 'Wide Network of Hospitals',
      'benefit1Subtitle': 'Access both government and private hospitals in Nabha.',
      'benefit2Title': 'Verified Doctors',
      'benefit2Subtitle': 'All doctors are board-certified and vetted for quality.',
      'benefit3Title': 'Secure & Private',
      'benefit3Subtitle': 'Your health data is encrypted and confidential.',
    },
    'pa': {
      'appTitle': 'ਹੈਲਥਕਨੈਕਟ',
      'loginButton': 'ਲਾਗਇਨ / ਸਾਈਨ ਅਪ',
      'heroTitle': 'ਤੁਹਾਡੀ ਸਿਹਤ, ਤੁਹਾਡਾ ਤਰੀਕਾ',
      'heroSubtitle': 'ਭਰੋਸੇਯੋਗ ਹਸਪਤਾਲਾਂ ਅਤੇ ਡਾਕਟਰਾਂ ਨਾਲ ਜੁੜੋ, ਅਪਾਇੰਟਮੈਂਟਾਂ ਦਾ ਪ੍ਰਬੰਧਨ ਕਰੋ, ਅਤੇ ਇੱਕ ਹੀ ਜਗ੍ਹਾ \'ਤੇ ਨਜ਼ਦੀਕੀ ਫਾਰਮੇਸੀਆਂ ਤੱਕ ਪਹੁੰਚ ਕਰੋ।',
      'getStarted': 'ਹੁਣੇ ਸ਼ੁਰੂ ਕਰੋ',
      'howItWorks': 'ਇਹ ਕਿਵੇਂ ਕੰਮ ਕਰਦਾ ਹੈ',
      'step1Title': 'ਹਸਪਤਾਲ ਅਤੇ ਡਾਕਟਰ ਲੱਭੋ',
      'step1Subtitle': 'ਵੈਰੀਫਾਈਡ ਹਸਪਤਾਲਾਂ ਨੂੰ ਬ੍ਰਾਉਜ਼ ਕਰੋ ਅਤੇ ਸਹੀ ਵਿਸ਼ੇਸ਼ਜ ਲੱਭੋ।',
      'step2Title': 'ਆਪਣਾ ਸਲਾਟ ਬੁੱਕ ਕਰੋ',
      'step2Subtitle': 'ਇੱਕ ਔਨਲਾਈਨ ਜਾਂ ਔਫਲਾਈਨ ਕਨਸਲਟੇਸ਼ਨ ਲਈ ਸੁਵਿਧਾਜਨਕ ਸਮਾਂ ਚੁਣੋ।',
      'step3Title': 'ਕਨਸਲਟੇਸ਼ਨ ਪ੍ਰਾਪਤ ਕਰੋ',
      'step3Subtitle': 'ਸੁਰੱਖਿਅਤ ਵੀਡੀਓ ਕਾਲ ਦੁਆਰਾ ਆਪਣੇ ਡਾਕਟਰ ਨਾਲ ਜੁੜੋ ਜਾਂ ਕਲੀਨਿਕ ਦਾ ਦੌਰਾ ਕਰੋ।',
      'step4Title': 'ਪ੍ਰੈਸਕ੍ਰੀਪਸ਼ਨ ਪ੍ਰਾਪਤ ਕਰੋ',
      'step4Subtitle': 'ਆਪਣੀ ਡਿਜੀਟਲ ਪ੍ਰੈਸਕ੍ਰੀਪਸ਼ਨ ਐਪ ਵਿੱਚ ਤੁਰੰਤ ਪ੍ਰਾਪਤ ਕਰੋ।',
      'hospitals': 'ਨਾਭਾ ਵਿੱਚ ਹਸਪਤਾਲ',
      'privateHospitals': 'ਸਾਡੇ ਨਿਜੀ ਹਸਪਤਾਲਾਂ ਦਾ ਨੈਟਵਰਕ',
      'government': 'ਸਰਕਾਰੀ',
      'whyChooseUs': 'ਅਸੀਂ ਕਿਉਂ ਚੁਣੀਏ?',
      'benefit1Title': 'ਹਸਪਤਾਲਾਂ ਦਾ ਵਿਸਤ੍ਰਿਤ ਨੈਟਵਰਕ',
      'benefit1Subtitle': 'ਨਾਭਾ ਵਿੱਚ ਸਰਕਾਰੀ ਅਤੇ ਨਿਜੀ ਦੋਨਾਂ ਹਸਪਤਾਲਾਂ ਤੱਕ ਪਹੁੰਚ।',
      'benefit2Title': 'ਵੈਰੀਫਾਈਡ ਡਾਕਟਰ',
      'benefit2Subtitle': 'ਸਾਰੇ ਡਾਕਟਰ ਬੋਰਡ-ਸਰਟੀਫਾਈਡ ਹਨ ਅਤੇ ਕੁਆਲਿਟੀ ਲਈ ਵੈਰੀਫਾਈਡ ਹਨ।',
      'benefit3Title': 'ਸੁਰੱਖਿਅਤ ਅਤੇ ਨਿਜੀ',
      'benefit3Subtitle': 'ਤੁਹਾਡਾ ਸਿਹਤ ਡਾਟਾ ਐਨਕ੍ਰਿਪਟਡ ਅਤੇ ਕੰਫੀਡੈਂਸ਼ੀਅਲ ਹੈ।',
    },
  };

  String _getText(String key) {
    return _translations[_isPunjabi ? 'pa' : 'en']![key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getText('appTitle'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isPunjabi ? Icons.language : Icons.translate),
            onPressed: () {
              setState(() {
                _isPunjabi = !_isPunjabi;
              });
            },
            tooltip: _isPunjabi ? 'Switch to English' : 'ਅੰਗਰੇਜ਼ੀ ਵਿੱਚ ਬਦਲੋ',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () => _navigateToLogin(context),
              icon: const Icon(Icons.login),
              label: Text(_getText('loginButton')),
              style: TextButton.styleFrom(foregroundColor: Colors.teal),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal,
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(context),
            _buildSectionHeader(context, _getText('howItWorks')),
            _buildHowItWorksStep(context, '1', _getText('step1Title'), _getText('step1Subtitle')),
            _buildHowItWorksStep(context, '2', _getText('step2Title'), _getText('step2Subtitle')),
            _buildHowItWorksStep(context, '3', _getText('step3Title'), _getText('step3Subtitle')),
            _buildHowItWorksStep(context, '4', _getText('step4Title'), _getText('step4Subtitle')),
            _buildHospitalsSection(context),
            _buildSectionHeader(context, _getText('whyChooseUs')),
            _buildBenefitItem(Icons.business, _getText('benefit1Title'), _getText('benefit1Subtitle')),
            _buildBenefitItem(Icons.verified_user, _getText('benefit2Title'), _getText('benefit2Subtitle')),
            _buildBenefitItem(Icons.lock, _getText('benefit3Title'), _getText('benefit3Subtitle')),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.teal.shade50,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_getText('heroTitle'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
          const SizedBox(height: 8),
          Text(_getText('heroSubtitle'), style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => _navigateToLogin(context), child: Text(_getText('getStarted'))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildHowItWorksStep(BuildContext context, String step, String title, String subtitle) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.teal, child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildHospitalsSection(BuildContext context) {
    final governmentHospital = _hospitals.firstWhere((h) => h.isGovernment);
    final privateHospitals = _hospitals.where((h) => !h.isGovernment).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, _getText('hospitals')),
        _buildGovernmentHospitalCard(context, governmentHospital),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(_getText('privateHospitals'), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        _buildPrivateHospitalsCarousel(privateHospitals),
      ],
    );
  }

  Widget _buildGovernmentHospitalCard(BuildContext context, _HospitalInfo hospital) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Image.network(hospital.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(_isPunjabi && hospital.namePunjabi != null ? hospital.namePunjabi! : hospital.name, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0), 
                child: Text(_isPunjabi && hospital.descriptionPunjabi != null ? hospital.descriptionPunjabi! : hospital.description ?? '')
              ),
              trailing: Chip(
                label: Text(_getText('government')), 
                backgroundColor: Colors.teal.shade100, 
                labelStyle: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      ),
    );
  }
  


  Widget _buildPrivateHospitalsCarousel(List<_HospitalInfo> hospitals) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        enlargeCenterPage: true,
        viewportFraction: 0.45,
        aspectRatio: 16 / 9,
      ),
      items: hospitals.map((hospital) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(hospital.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _isPunjabi && hospital.namePunjabi != null ? hospital.namePunjabi! : hospital.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class _HospitalInfo {
  final String name;
  final String imageUrl;
  final String? description;
  final bool isGovernment;
  final String? namePunjabi;
  final String? descriptionPunjabi;

  _HospitalInfo({
    required this.name,
    required this.imageUrl,
    this.description,
    this.isGovernment = false,
    this.namePunjabi,
    this.descriptionPunjabi,
  });
}