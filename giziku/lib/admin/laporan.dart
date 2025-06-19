import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_admin.dart';
import 'profil_admin.dart';
import 'scanner.dart';

class DistributionReportScreen extends StatefulWidget {
  const DistributionReportScreen({super.key});

  @override
  State<DistributionReportScreen> createState() =>
      _DistributionReportScreenState();
}

class _DistributionReportScreenState extends State<DistributionReportScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _studentsController = TextEditingController();
  final TextEditingController _foodTotalController = TextEditingController();
  final TextEditingController _extraFoodController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final int _currentIndex = 2;

  String? _selectedIssue;
  String _schoolName = '';
  final List<String> _issueTypes = [
    'Penundaan Distribusi',
    'Paket Rusak',
    'Paket Salah',
    'Lainnya',
  ];

  List<Map<String, dynamic>> _chartData = [];

  void _onTabTapped(int index) {
    Widget destination;
    switch (index) {
      case 0:
        destination = const DashboardAdmin();
        break;
      case 1:
        destination = const ScannerScreen();
        break;
      case 2:
        destination = const ProfileAdmin();
        break;
      default:
        destination = const DashboardAdmin();
    }

    if (index != _currentIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  Future<void> _submitReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance.collection('distributions').doc();

    try {
      await docRef.set({
        'userId': user.uid,
        'sekolah': _schoolName,
        'tanggal': _dateController.text,
        'totalSiswa': int.tryParse(_studentsController.text) ?? 0,
        'totalMakanan': int.tryParse(_foodTotalController.text) ?? 0,
        'makananBerlebih': int.tryParse(_extraFoodController.text) ?? 0,
        'masalah': _selectedIssue,
        'deskripsi': _descriptionController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Laporan berhasil dikirim')));
      _fetchChartData(); // refresh grafik
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e')));
    }
  }

  Future<void> _fetchSchoolName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    if (userDoc.exists) {
      setState(() {
        _schoolName = userDoc['sekolah'] ?? 'Sekolah Tidak Dikenal';
      });
    }
  }

  Future<void> _fetchChartData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('distributions')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .get();

    final List<Map<String, dynamic>> data = [];

    for (var doc in snapshot.docs) {
      try {
        final tanggal = doc['tanggal'] ?? '??/??';
        final total = doc['totalMakanan'];
        final totalDouble =
            total is int
                ? total.toDouble()
                : double.tryParse(total.toString()) ?? 0.0;

        data.add({'tanggal': tanggal, 'totalMakanan': totalDouble});
      } catch (e) {
        debugPrint("Error parsing chart data: $e");
      }
    }

    debugPrint("Loaded chart data: $data");

    setState(() {
      _chartData = data.reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSchoolName();
    _fetchChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF4E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text('Laporan Distribusi'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardAdmin()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _schoolName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // GRAFIK
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  _chartData.isEmpty
                      ? const Center(child: Text("Belum ada data grafik"))
                      : BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  int index = value.toInt();
                                  if (index >= 0 && index < _chartData.length) {
                                    return Text(
                                      _chartData[index]['tanggal']
                                          .toString()
                                          .split('/')
                                          .take(2)
                                          .join('/'),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          barGroups:
                              _chartData
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => BarChartGroupData(
                                      x: e.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: e.value['totalMakanan'],
                                          color: Colors.orange,
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTextField(
                  _dateController,
                  'Tanggal',
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                _buildTextField(
                  _studentsController,
                  'Total Siswa',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  _foodTotalController,
                  'Total Makanan',
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  _extraFoodController,
                  'Makanan Berlebih',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedIssue,
              decoration: InputDecoration(
                labelText: 'Tipe Masalah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items:
                  _issueTypes
                      .map(
                        (issue) =>
                            DropdownMenuItem(value: issue, child: Text(issue)),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedIssue = value),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Deskripsi Masalah',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                ),
                onPressed: _submitReport,
                child: const Text(
                  'Kirim Laporan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFFFFA500),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 48) / 2,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
