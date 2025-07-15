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
      // 1. Membuat dokumen baru di koleksi 'deliveries'
      // Dokumen ini akan menjadi dasar untuk riwayat dan ceklis admin
      final newDeliveryRef = await FirebaseFirestore.instance
          .collection('deliveries')
          .add({
            'schoolName': _schoolName,
            'deliveryDate': _selectedDate,
            'totalStudents': int.tryParse(_studentsController.text) ?? 0,
            'totalMeals': int.tryParse(_foodTotalController.text) ?? 0,
            'surplusMeals': int.tryParse(_extraFoodController.text) ?? 0,
            'reportIssueType': _selectedIssue,
            'reportDescription': _descriptionController.text,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dikirim!')),
        );
        // 2. Setelah berhasil, navigasi ke halaman ceklis siswa
        // dengan mengirimkan ID dari dokumen pengiriman yang baru dibuat.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    DeliveryChecklistScreen(deliveryId: newDeliveryRef.id),
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
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Distribution Report',
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
              Text(
                _schoolName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text("[Distribution Chart]")),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _studentsController,
                      label: "Total Siswa",
                      keyboardType: TextInputType.number,
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _extraFoodController,
                      label: "Makanan Berlebih",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                "Report an Issue",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: "Description",
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Submit Report',
                            style: TextStyle(color: Colors.black, fontSize: 16),
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
          lastDate: DateTime(2100),
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

  // **PERBAIKAN:** Mengubah parameter menjadi named parameter
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: _buildInputDecoration(label: label),
      validator: (value) {
        if (label != 'Description' && (value == null || value.isEmpty)) {
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
      decoration: _buildInputDecoration(label: "Issue Type"),
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
      suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
