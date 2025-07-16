import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'halaman_checklis.dart'; // Pastikan nama file ini benar

class DistributionReportScreen extends StatefulWidget {
  const DistributionReportScreen({super.key});

  @override
  State<DistributionReportScreen> createState() =>
      _DistributionReportScreenState();
}

class _DistributionReportScreenState extends State<DistributionReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _studentsController = TextEditingController();
  final _foodTotalController = TextEditingController();
  final _extraFoodController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedIssue = 'Penundaan Distribusi';
  bool _isSubmitting = false;
  String _schoolName = 'Memuat nama sekolah...';

  final List<String> _issueTypes = [
    'Penundaan Distribusi',
    'Paket Rusak',
    'Paket Salah',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _fetchSchoolName();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _studentsController.dispose();
    _foodTotalController.dispose();
    _extraFoodController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchoolName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (mounted && userDoc.exists) {
        setState(() {
          _schoolName = userDoc['sekolah'] ?? 'Sekolah Tidak Dikenal';
        });
      }
    } catch (e) {
      debugPrint("Error fetching school name: $e");
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final selectedDate = _selectedDate ?? now;

      // Menggunakan format yang konsisten dengan halaman ceklis
      final deliveryId =
          '${user.uid}_${DateFormat('yyyy-MM-dd').format(selectedDate)}';

      // Cek apakah sudah ada delivery untuk tanggal ini
      final deliveryRef = FirebaseFirestore.instance
          .collection('deliveries')
          .doc(deliveryId);

      final deliveryDoc = await deliveryRef.get();

      if (deliveryDoc.exists) {
        // Update dokumen yang sudah ada
        await deliveryRef.update({
          'schoolName': _schoolName,
          'deliveryDate': Timestamp.fromDate(selectedDate),
          'totalStudents': int.tryParse(_studentsController.text) ?? 0,
          'totalMeals': int.tryParse(_foodTotalController.text) ?? 0,
          'surplusMeals': int.tryParse(_extraFoodController.text) ?? 0,
          'reportIssueType': _selectedIssue,
          'reportDescription': _descriptionController.text,
          'updatedAt': Timestamp.now(),
        });
      } else {
        // Buat dokumen baru dengan ID yang konsisten
        await deliveryRef.set({
          'schoolName': _schoolName,
          'deliveryDate': Timestamp.fromDate(selectedDate),
          'totalStudents': int.tryParse(_studentsController.text) ?? 0,
          'totalMeals': int.tryParse(_foodTotalController.text) ?? 0,
          'surplusMeals': int.tryParse(_extraFoodController.text) ?? 0,
          'reportIssueType': _selectedIssue,
          'reportDescription': _descriptionController.text,
          'createdAt': Timestamp.now(),
          'userId': user.uid,
          'receivedCount': 0, // Inisialisasi
          'absentCount': 0, // Inisialisasi
          'totalRecipients': 0, // Inisialisasi
          'isFinalized': false, // Belum selesai
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dikirim!')),
        );

        // Navigasi ke halaman ceklis dengan deliveryId yang konsisten
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CeklisAdminScreen(deliveryId: deliveryId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim laporan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFF6EC,
      ), // Konsisten dengan halaman ceklis
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Laporan Distribusi',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header sekolah
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          _schoolName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tanggal: ${_selectedDate != null ? DateFormat('dd MMMM yyyy').format(_selectedDate!) : 'Pilih tanggal'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Placeholder untuk chart
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Text(
                    "[Grafik Distribusi]",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form inputs
              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _studentsController,
                      label: "Total Siswa",
                      keyboardType: TextInputType.number,
                      icon: Icons.people,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _foodTotalController,
                      label: "Total Makanan",
                      keyboardType: TextInputType.number,
                      icon: Icons.fastfood,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _extraFoodController,
                      label: "Makanan Berlebih",
                      keyboardType: TextInputType.number,
                      icon: Icons.add_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section laporan masalah
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.report_problem, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          "Laporkan Masalah",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: "Deskripsi",
                      maxLines: 4,
                      icon: Icons.description,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Kirim Laporan & Lanjut ke Ceklis',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: _dateController,
      readOnly: true,
      decoration: _buildInputDecoration(
        label: "Tanggal",
        icon: Icons.calendar_today,
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2024),
          lastDate: DateTime.now().add(const Duration(days: 7)),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
          });
        }
      },
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? 'Tanggal tidak boleh kosong'
                  : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int? maxLines,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: _buildInputDecoration(label: label, icon: icon),
      validator: (value) {
        if (label != 'Deskripsi' && (value == null || value.isEmpty)) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedIssue,
      items:
          _issueTypes
              .map(
                (label) => DropdownMenuItem(value: label, child: Text(label)),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedIssue = value);
        }
      },
      decoration: _buildInputDecoration(
        label: "Jenis Masalah",
        icon: Icons.error_outline,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: Colors.orange) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
    );
  }
}
