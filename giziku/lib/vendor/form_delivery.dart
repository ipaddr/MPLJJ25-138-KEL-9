import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddDeliveryScreen extends StatefulWidget {
  const AddDeliveryScreen({super.key});

  @override
  State<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends State<AddDeliveryScreen> {
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _mealsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        // Mengisi controller dengan waktu yang sudah diformat
        _timeController.text = picked.format(context);
      });
    }
  }

  /// Fungsi untuk mengirim data ke Firebase Firestore.
  Future<void> _submitForm() async {
    final schoolName = _schoolController.text.trim();
    final meals = int.tryParse(_mealsController.text.trim()) ?? 0;
    final deliveryTime = _timeController.text.trim();

    // Validasi input
    if (schoolName.isEmpty || deliveryTime.isEmpty || meals <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua field dengan benar'),
        ),
      );
      return;
    }

    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Mengirim data ke koleksi 'deliveries' di Firestore
      await FirebaseFirestore.instance.collection('deliveries').add({
        'schoolName': schoolName,
        'numberOfMeals': meals,
        'deliveryTime': deliveryTime,
        'status': 'Pending', // Status default untuk setiap pengiriman baru
        'createdAt': FieldValue.serverTimestamp(), // Timestamp dari server
      });

      // Tutup loading indicator
      Navigator.of(context).pop();
      // Tutup halaman form setelah berhasil
      Navigator.of(context).pop();
    } catch (e) {
      // Tutup loading indicator
      Navigator.of(context).pop();
      // Tampilkan pesan error jika gagal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan data: $e')));
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _mealsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        title: const Text('Add Delivery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _schoolController,
              label: 'Name of school',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _mealsController,
              label: 'Number of Meals',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTimeField(
              controller: _timeController,
              label: 'Delivery Time',
              onTap: _pickTime,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget untuk membuat text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget untuk membuat field waktu
  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.access_time),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
