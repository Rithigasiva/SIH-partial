// lib/screens/pharmacy/pharmacy_page.dart

import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class PharmacyPage extends StatefulWidget {
  // MODIFIED: Added patient parameter
  final Patient patient;
  const PharmacyPage({super.key, required this.patient});

  @override
  State<PharmacyPage> createState() => _PharmacyPageState();
}

class _PharmacyPageState extends State<PharmacyPage> {
  final LatLng _nabhaCenter = const LatLng(30.3773, 76.1524);
  final List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  Position? _currentPosition;
  final MapController _mapController = MapController();
  final Distance _distance = const Distance();
  final ScrollController _scrollController = ScrollController();
  final UserDataService _userDataService = UserDataService();

  final TextEditingController _medicineController = TextEditingController();
  List<Medicine> _allMedicines = [];
  List<Medicine> _filteredMedicines = [];
  List<Pharmacy> _filteredPharmacies = [];
  bool _showSearchScreen = true;
  String? _selectedMedicineName;
  Pharmacy? _selectedPharmacyForDirections;
  bool _isLoadingRoute = false;

  final List<String> _navigationStack = ['search'];

  @override
  void initState() {
    super.initState();
    _loadAllMedicines();
    _requestLocationPermission();
  }

  void _loadAllMedicines() {
    Set<String> uniqueMedicineNames = {};
    List<Medicine> uniqueMedicines = [];
    for (final pharmacy in _userDataService.pharmacies) {
      final pharmacyMedicines = _userDataService.getMedicinesForPharmacy(pharmacy.id);
      for (final medicine in pharmacyMedicines) {
        if (uniqueMedicineNames.add(medicine.name)) {
          uniqueMedicines.add(medicine);
        }
      }
    }
    
    setState(() {
      _allMedicines = uniqueMedicines;
      _filteredMedicines = _allMedicines;
    });
  }

  void _filterMedicines(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMedicines = _allMedicines;
      });
      return;
    }
    
    setState(() {
      _filteredMedicines = _allMedicines
          .where((medicine) => 
              medicine.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectMedicine(Medicine medicine) {
    setState(() {
      _selectedMedicineName = medicine.name;
      _medicineController.text = medicine.name;
      FocusScope.of(context).unfocus();
    });
  }

  void _searchPharmacies() {
    if (_selectedMedicineName == null || _selectedMedicineName!.isEmpty) {
      _filteredPharmacies = List<Pharmacy>.from(_userDataService.pharmacies);
    } else {
      _filteredPharmacies = _userDataService.pharmacies.where((pharmacy) {
        final medicines = _userDataService.getMedicinesForPharmacy(pharmacy.id);
        return medicines.any((medicine) => 
            medicine.name == _selectedMedicineName && medicine.stock > 0);
      }).toList();
    }
    
    if (_currentPosition != null) {
      _filteredPharmacies.sort((a, b) {
        final userLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
        final distA = _distance.distance(userLatLng, LatLng(a.latitude, a.longitude));
        final distB = _distance.distance(userLatLng, LatLng(b.latitude, b.longitude));
        return distA.compareTo(distB);
      });
    }
    
    setState(() {
      _showSearchScreen = false;
      _navigationStack.add('results');
    });
    
    _loadMarkers();
  }

  void _showAllPharmacies() {
    setState(() {
      _selectedMedicineName = null;
      _medicineController.clear();
      _showSearchScreen = false;
      _filteredPharmacies = List<Pharmacy>.from(_userDataService.pharmacies);
      _navigationStack.add('results');
      
      if (_currentPosition != null) {
        _filteredPharmacies.sort((a, b) {
          final userLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
          final distA = _distance.distance(userLatLng, LatLng(a.latitude, a.longitude));
          final distB = _distance.distance(userLatLng, LatLng(b.latitude, b.longitude));
          return distA.compareTo(distB);
        });
      }
    });
    
    _loadMarkers();
  }

  Future<bool> _onWillPop() async {
    if (_navigationStack.length > 1) {
      setState(() {
        _navigationStack.removeLast();
        final currentState = _navigationStack.last;
        
        if (currentState == 'search') {
          _showSearchScreen = true;
          _polylines = [];
          _selectedPharmacyForDirections = null;
        } else if (currentState == 'results') {
          _showSearchScreen = false;
        }
      });
      return false;
    }
    return true;
  }

  Future<void> _requestLocationPermission() async {
    PermissionStatus permission = await Permission.locationWhenInUse.status;
    if (permission.isDenied) {
      permission = await Permission.locationWhenInUse.request();
    }
    if (permission.isGranted) {
      _getCurrentLocation();
    } else {
      _loadMarkers();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _mapController.move(
            LatLng(position.latitude, position.longitude), 14.0);
      });
      _loadMarkers();
    } catch (e) {
      _loadMarkers();
    }
  }

  void _loadMarkers() {
    _markers.clear();

    for (final pharmacy in _filteredPharmacies) {
      _markers.add(_buildPharmacyMarker(pharmacy));
    }

    if (_selectedMedicineName == null) {
      final hospitals = _userDataService.hospitals;
      for (final hospital in hospitals) {
        _markers.add(_buildHospitalMarker(hospital));
      }
    }
    
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 30),
        ),
      );
    }
    
    setState(() {});
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _adjustMapToShowAllMarkers();
      }
    });
  }

  void _adjustMapToShowAllMarkers() {
    if (_markers.length < 2) return;
    
    var bounds = LatLngBounds.fromPoints(
        _markers.map((m) => m.point).toList());
    
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50.0),
      ),
    );
  }

  Future<void> _getDirections(Pharmacy pharmacy) async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available. Please enable location services.')),
      );
      return;
    }

    setState(() {
      _isLoadingRoute = true;
      _selectedPharmacyForDirections = pharmacy;
    });

    try {
      final response = await http.get(Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${_currentPosition!.longitude},${_currentPosition!.latitude};'
        '${pharmacy.longitude},${pharmacy.latitude}'
        '?overview=full&geometries=geojson'
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok') {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          List<LatLng> polylineCoordinates = [];
          for (var coord in coordinates) {
            polylineCoordinates.add(LatLng(coord[1], coord[0]));
          }

          setState(() {
            _polylines = [
              Polyline(
                points: polylineCoordinates,
                strokeWidth: 4,
                color: Colors.blue,
              ),
            ];
          });
          
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(polylineCoordinates),
              padding: const EdgeInsets.all(50.0),
            ),
          );

          return;
        }
      }
      _openInExternalMaps(pharmacy);
    } catch (e) {
      _openInExternalMaps(pharmacy);
    } finally {
       if(mounted){
       setState(() {
         _isLoadingRoute = false;
       });
     }
    }
  }

  Future<void> _openInExternalMaps(Pharmacy pharmacy) async {
    if (_currentPosition == null) return;
    final String url = 'https://www.openstreetmap.org/directions?engine=osrm_car&route='
        '${_currentPosition!.latitude}%2C${_currentPosition!.longitude}%3B'
        '${pharmacy.latitude}%2C${pharmacy.longitude}';
    
    await _launchURL(url);
  }

  Future<void> _openHospitalInExternalMaps(Hospital hospital) async {
    if (_currentPosition == null) return;
    final String url = 'https://www.openstreetmap.org/directions?engine=osrm_car&route='
        '${_currentPosition!.latitude}%2C${_currentPosition!.longitude}%3B'
        '${hospital.latitude}%2C${hospital.longitude}';

    await _launchURL(url);
  }

  void _clearRoute() {
    setState(() {
      _polylines = [];
      _selectedPharmacyForDirections = null;
    });
    _loadMarkers();
  }

  Future<void> _callPharmacy(String phoneNumber) async {
    final Uri telUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not place the call.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not place the call.')),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open maps.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open maps.')),
        );
      }
    }
  }
  
  // --- NEW: Simplified notification request function ---
  void _requestNotification() {
    final medicineName = _medicineController.text;
    if (medicineName.isEmpty) return;

    // Use the patient object passed to this widget
    final request = MedicineRequest(
      id: const Uuid().v4(),
      medicineName: medicineName,
      patientId: widget.patient.id, // Use the patient's ID
    );

    _userDataService.addMedicineRequest(request);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request saved! We will notify you in the app when it\'s available.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- UI WIDGETS ---
  
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2A7FBA);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: _showSearchScreen 
        ? _buildMedicineSearchScreen(primaryColor) 
        : _buildMapAndListScreen(primaryColor),
    );
  }

  Widget _buildMapAndListScreen(Color primaryColor) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(_selectedMedicineName != null 
            ? 'Pharmacies with $_selectedMedicineName' 
            : 'Nearby Healthcare Services'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onWillPop(),
        ),
        actions: [
          if (_polylines.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearRoute,
              tooltip: 'Clear Route',
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _showSearchScreen = true;
                _polylines = [];
                _selectedPharmacyForDirections = null;
                _navigationStack.add('search');
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude)
                    : _nabhaCenter,
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.care',
                ),
                PolylineLayer(polylines: _polylines),
                MarkerLayer(markers: _markers),
              ],
            ),
          ),
          Expanded(
            child: _filteredPharmacies.isEmpty && _selectedMedicineName != null 
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No pharmacies currently have "${_medicineController.text}" in stock.',
                             textAlign: TextAlign.center,
                             style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.notifications_active_outlined),
                            label: const Text('Notify Me When Available'),
                            onPressed: _requestNotification, // MODIFIED
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                  ))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredPharmacies.length + 
                        (_selectedMedicineName == null ? _userDataService.hospitals.length : 0),
                    itemBuilder: (context, index) {
                      if (index < _filteredPharmacies.length) {
                        final pharmacy = _filteredPharmacies[index];
                        return _buildPharmacyListItem(pharmacy, primaryColor);
                      } else {
                        final hospital = _userDataService.hospitals[
                            index - _filteredPharmacies.length];
                        return _buildHospitalListItem(hospital, primaryColor);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSearchScreen(Color primaryColor) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Find Medicine'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onWillPop().then((shouldPop) {
            if (shouldPop) {
              Navigator.of(context).pop();
            }
          }),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search for a medicine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _medicineController,
              decoration: InputDecoration(
                hintText: 'Enter medicine name (e.g., Paracetamol)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _filterMedicines,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredMedicines.isEmpty && _medicineController.text.isNotEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No results found for "${_medicineController.text}"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.notifications_active_outlined),
                            label: const Text('Notify Me When Available'),
                            onPressed: _requestNotification, // MODIFIED
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                               shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _filteredMedicines.isEmpty && _medicineController.text.isEmpty
                      ? Center(
                          child: Text(
                            'Start typing to search medicines',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredMedicines.length,
                          itemBuilder: (context, index) {
                            final medicine = _filteredMedicines[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.medication, color: Colors.green),
                                title: Text(medicine.name),
                                onTap: () => _selectMedicine(medicine),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedMedicineName != null && _selectedMedicineName!.isNotEmpty
                        ? _searchPharmacies 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Find Pharmacies'),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _showAllPharmacies,
                  child: const Text('Show All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- The rest of your file is unchanged ---

  Widget _buildPharmacyListItem(Pharmacy pharmacy, Color primaryColor) {
    double? distanceKm;
    if (_currentPosition != null) {
      final userLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final pharmacyLatLng = LatLng(pharmacy.latitude, pharmacy.longitude);
      distanceKm =
          _distance.distance(userLatLng, pharmacyLatLng) / 1000;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.local_pharmacy, color: Colors.green),
        title: Text(pharmacy.pharmacyName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pharmacy.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (distanceKm != null)
              Text('${distanceKm.toStringAsFixed(1)} km away'),
          ],
        ),
        trailing: _currentPosition != null
            ? IconButton(
                icon: const Icon(Icons.directions, color: Colors.blue),
                onPressed: () => _getDirections(pharmacy),
              )
            : null,
        onTap: () {
          _showPharmacyDetails(pharmacy);
          _mapController.move(
              LatLng(pharmacy.latitude, pharmacy.longitude), 16.0);
        },
      ),
    );
  }

  Widget _buildHospitalListItem(Hospital hospital, Color primaryColor) {
    double? distanceKm;
    if (_currentPosition != null) {
      final userLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final hospitalLatLng = LatLng(hospital.latitude, hospital.longitude);
      distanceKm =
          _distance.distance(userLatLng, hospitalLatLng) / 1000;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.red),
        title: Text(hospital.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hospital.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            if (distanceKm != null)
              Text('${distanceKm.toStringAsFixed(1)} km away'),
          ],
        ),
        trailing: _currentPosition != null
            ? IconButton(
                icon: const Icon(Icons.directions, color: Colors.blue),
                onPressed: () => _openHospitalInExternalMaps(hospital),
              )
            : null,
        onTap: () {
          _showPlaceDetails(hospital.name, hospital.address,
              hospital.email, LatLng(hospital.latitude, hospital.longitude));
          _mapController.move(
              LatLng(hospital.latitude, hospital.longitude), 16.0);
        },
      ),
    );
  }

  Marker _buildPharmacyMarker(Pharmacy pharmacy) {
    return Marker(
      width: 120.0,
      height: 60.0,
      point: LatLng(pharmacy.latitude, pharmacy.longitude),
      child: GestureDetector(
        onTap: () => _showPharmacyDetails(pharmacy),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _selectedPharmacyForDirections == pharmacy 
                    ? Colors.orange.shade700 
                    : Colors.green.shade700,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.local_pharmacy,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                pharmacy.pharmacyName,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _buildHospitalMarker(Hospital hospital) {
    return Marker(
      width: 120.0,
      height: 60.0,
      point: LatLng(hospital.latitude, hospital.longitude),
      child: GestureDetector(
        onTap: () => _showPlaceDetails(hospital.name, hospital.address,
            hospital.email, LatLng(hospital.latitude, hospital.longitude)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.local_hospital,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                hospital.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPharmacyDetails(Pharmacy pharmacy) {
    double? distanceKm;
    if (_currentPosition != null) {
      final userLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final placeLocation = LatLng(pharmacy.latitude, pharmacy.longitude);
      distanceKm = _distance.distance(userLatLng, placeLocation) / 1000;
    }

    final medicines =
        _userDataService.getMedicinesForPharmacy(pharmacy.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pharmacy.pharmacyName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2A7FBA),
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.location_on, pharmacy.address),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.phone, pharmacy.mobile),
                if (distanceKm != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.directions,
                      '${distanceKm.toStringAsFixed(2)} km away'),
                ],
                const SizedBox(height: 20),
                
                Column(
                  children: [
                    if (_currentPosition != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: _isLoadingRoute
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.directions),
                          label: Text(_isLoadingRoute ? 'Loading Route...' : 'Get Directions'),
                          onPressed: _isLoadingRoute
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _getDirections(pharmacy);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delivery_dining, size: 20),
                        label: const Text('Call for Door Delivery'),
                        onPressed: () {
                          Navigator.pop(context);
                          _callPharmacy(pharmacy.mobile);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                const Text(
                  'Available Medicines',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                if (medicines.isEmpty)
                  const Text("No medicines listed yet")
                else
                  Column(
                    children: medicines
                        .map((m) => ListTile(
                              dense: true,
                              leading: const Icon(Icons.medication,
                                  color: Colors.green),
                              title: Text(m.name),
                              trailing: Text('Stock: ${m.stock}'),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlaceDetails(
    String name, String address, String contact, LatLng placeLocation) {
    double? distanceKm;
    if (_currentPosition != null) {
      final userLatLng =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      distanceKm = _distance.distance(userLatLng, placeLocation) / 1000;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2A7FBA),
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(Icons.location_on, address),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.phone, contact),
              if (distanceKm != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(Icons.directions,
                    '${distanceKm.toStringAsFixed(2)} km away'),
              ],
              if (_currentPosition != null) 
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    onPressed: () {
                      Navigator.pop(context);
                      _openHospitalInExternalMaps(Hospital (
                        id: '',
                        name: name,
                        address: address,
                        email: contact,
                        password: '',
                        latitude: placeLocation.latitude,
                        longitude: placeLocation.longitude,
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }
}