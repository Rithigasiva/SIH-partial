import 'package:care/models/user_models.dart';
import 'package:care/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PharmacyDashboardPage extends StatefulWidget {
  final Pharmacy pharmacy;
  const PharmacyDashboardPage({super.key, required this.pharmacy});

  @override
  State<PharmacyDashboardPage> createState() => _PharmacyDashboardPageState();
}

class _PharmacyDashboardPageState extends State<PharmacyDashboardPage> {
  final UserDataService _userDataService = UserDataService();
  List<Medicine> _medicines = [];

  // ✅ Master list of medicines (50–60)
  final List<String> medicineNames = [
    "Paracetamol",
    "Ibuprofen",
    "Amoxicillin",
    "Ciprofloxacin",
    "Azithromycin",
    "Cetirizine",
    "Metformin",
    "Atorvastatin",
    "Losartan",
    "Omeprazole",
    "Amlodipine",
    "Levothyroxine",
    "Dolo 650",
    "Pantoprazole",
    "Insulin",
    "Vitamin D",
    "Calcium Tablet",
    "Multivitamin",
    "Ranitidine",
    "Diclofenac",
    "Aspirin",
    "Clopidogrel",
    "Hydrochlorothiazide",
    "Glibenclamide",
    "Gliclazide",
    "Furosemide",
    "Spironolactone",
    "Warfarin",
    "Heparin",
    "Prednisolone",
    "Hydrocortisone",
    "Salbutamol Inhaler",
    "Budesonide Inhaler",
    "Montelukast",
    "Erythromycin",
    "Doxycycline",
    "Clarithromycin",
    "Nitrofurantoin",
    "Fluconazole",
    "Itraconazole",
    "Metronidazole",
    "Chloroquine",
    "Hydroxychloroquine",
    "Albendazole",
    "Mebendazole",
    "Iron Tablets",
    "Folic Acid",
    "Vitamin B12",
    "Vitamin C",
    "Vitamin A",
    "Zinc Supplement",
    "ORS Solution",
    "Domperidone",
    "Ondansetron",
    "Hyoscine",
    "Rabeprazole",
    "Esomeprazole",
    "Sucralfate",
    "Loperamide",
    "ORS Sachets"
  ];

  @override
  void initState() {
    super.initState();
    // Pre-load data to avoid initial reloading state
    _loadMedicines();
  }

  void _loadMedicines() async {
    try {
      // Get initial data instead of just streaming
      final medicines = _userDataService.getMedicinesForPharmacy(widget.pharmacy.id);
      if (mounted) {
        setState(() {
          _medicines = medicines;
        });
      }
    } catch (e) {
      print("Error loading medicines: $e");
    }
  }

  void _showMedicineDialog({Medicine? medicine}) {
    String? selectedMedicine = medicine?.name;
    final stockController =
        TextEditingController(text: medicine?.stock.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                medicine == null ? 'Add New Medicine' : 'Update Medicine Stock',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E5AAC),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        value: selectedMedicine,
                        items: medicineNames.map((name) {
                          return DropdownMenuItem(
                            value: name,
                            child: Text(
                              name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: medicine == null
                            ? (value) {
                                selectedMedicine = value;
                              }
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Name',
                          border: InputBorder.none,
                          labelStyle: TextStyle(color: Color(0xFF2E5AAC)),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Please select medicine' : null,
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2E5AAC)),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: stockController,
                      decoration: InputDecoration(
                        labelText: 'Stock Quantity',
                        labelStyle: const TextStyle(color: Color(0xFF2E5AAC)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2E5AAC), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty || int.tryParse(v) == null
                          ? 'Enter valid number'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E5AAC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (medicine == null) {
                          final newMedicine = Medicine(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            pharmacyId: widget.pharmacy.id,
                            name: selectedMedicine!,
                            stock: int.parse(stockController.text),
                          );
                          await _userDataService.addMedicine(newMedicine);
                        } else {
                          await _userDataService.updateMedicineStock(
                            medicine.copyWith(stock: int.parse(stockController.text)),
                          );
                        }
                        if (mounted) {
                          Navigator.pop(context);
                          // Refresh the list after adding/updating
                          _loadMedicines();
                        }
                      }
                    },
                    child: Text(
                      medicine == null ? 'Add Medicine' : 'Update Stock',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            widget.pharmacy.pharmacyName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF2E5AAC),
          elevation: 0,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: const TabBar(
                indicatorColor: Color(0xFF2E5AAC),
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Color(0xFF2E5AAC),
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: [
                  Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                  Tab(icon: Icon(Icons.medication), text: 'Inventory'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnalyticsTab(_medicines),
            _buildInventoryTab(_medicines),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showMedicineDialog(),
          backgroundColor: const Color(0xFF2E5AAC),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(List<Medicine> medicines) {
    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
  'https://images.pexels.com/photos/139398/thermometer-headache-pain-pills-139398.jpeg',
  height: 760,
  width: 380,
  
  
  fit: BoxFit.cover, // Recommended to maintain aspect ratio
),
            const SizedBox(height: 20),
            const Text(
              'No Medicines Added Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Add your first medicine to see analytics',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final inStock = medicines.where((m) => m.stock > 0).length;
    final outOfStock = medicines.length - inStock;
    final lowStock = medicines.where((m) => m.stock > 0 && m.stock < 10).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inventory Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E5AAC),
            ),
          ),
          const SizedBox(height: 20),
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total Medicines', medicines.length.toString(), 
                    Icons.medication, const Color(0xFF2E5AAC)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('In Stock', inStock.toString(), 
                    Icons.inventory, const Color(0xFF4CAF50)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Out of Stock', outOfStock.toString(), 
                    Icons.error_outline, const Color(0xFFF44336)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Low Stock', lowStock.toString(), 
                    Icons.warning, const Color(0xFFFF9800)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Stock Distribution Chart
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stock Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E5AAC),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: inStock.toDouble(),
                          title: '$inStock\nIn Stock',
                          color: const Color(0xFF4CAF50),
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        PieChartSectionData(
                          value: outOfStock.toDouble(),
                          title: '$outOfStock\nOut of Stock',
                          color: const Color(0xFFF44336),
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      centerSpaceRadius: 50,
                      centerSpaceColor: Colors.grey[50],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Low Stock Alert
          if (lowStock > 0) ...[
            const Text(
              'Low Stock Alert',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFECB3)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Color(0xFFFF9800)),
                      const SizedBox(width: 10),
                      Text(
                        '$lowStock medicine(s) are running low',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...medicines.where((m) => m.stock > 0 && m.stock < 10).take(3).map((medicine) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              medicine.name,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                          Text(
                            '${medicine.stock} left',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInventoryTab(List<Medicine> medicines) {
    if (medicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Image.network(
  'https://static.vecteezy.com/system/resources/previews/059/968/578/non_2x/endless-aisles-a-warehouse-perspective-with-empty-shelves-industrial-storage-and-metal-racks-for-inventory-management-and-organized-distribution-system-photo.jpeg',
  height: 760,
  width: 380,
  
  
  fit: BoxFit.cover, // Recommended to maintain aspect ratio
),
            const SizedBox(height: 20),
            const Text(
              'Your Inventory is Empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Tap the + button to add your first medicine',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    // Sort medicines: out of stock first, then low stock, then by name
    medicines.sort((a, b) {
      if (a.stock == 0 && b.stock != 0) return -1;
      if (a.stock != 0 && b.stock == 0) return 1;
      if (a.stock < 10 && b.stock >= 10) return -1;
      if (a.stock >= 10 && b.stock < 10) return 1;
      return a.name.compareTo(b.name);
    });
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicines.length,
      itemBuilder: (_, i) {
        final m = medicines[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getMedicineColor(m.stock),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getMedicineIcon(m.stock),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              m.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Stock: ${m.stock}',
              style: TextStyle(
                color: _getTextColor(m.stock),
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF2E5AAC)),
                  onPressed: () => _showMedicineDialog(medicine: m),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFF44336)),
                  onPressed: () {
                    _showDeleteConfirmation(m);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _userDataService.deleteMedicine(medicine);
              if (mounted) {
                Navigator.pop(context);
                _loadMedicines(); // Refresh the list
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMedicineColor(int stock) {
    if (stock == 0) return const Color(0xFFF44336); // Red for out of stock
    if (stock < 10) return const Color(0xFFFF9800); // Orange for low stock
    return const Color(0xFF4CAF50); // Green for in stock
  }

  IconData _getMedicineIcon(int stock) {
    if (stock == 0) return Icons.error_outline;
    if (stock < 10) return Icons.warning;
    return Icons.check_circle;
  }

  Color _getTextColor(int stock) {
    if (stock == 0) return const Color(0xFFF44336);
    if (stock < 10) return const Color(0xFFFF9800);
    return const Color(0xFF4CAF50);
  }
}