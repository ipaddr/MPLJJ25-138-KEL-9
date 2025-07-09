import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController openHoursController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Referensi ke dokumen profil di Firestore
  final DocumentReference _profileRef = FirebaseFirestore.instance
      .collection('vendors')
      .doc('main_profile');

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Mengambil data profil dari Firestore untuk diisi ke dalam form.
  Future<void> _loadProfileData() async {
    try {
      final snapshot = await _profileRef.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        vendorNameController.text = data['vendorName'] ?? '';
        openHoursController.text = data['openHours'] ?? '';
        locationController.text = data['location'] ?? '';
        contactNumberController.text = data['contactNumber'] ?? '';
        descriptionController.text = data['description'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat profil: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Menyimpan perubahan ke Firestore.
  Future<void> _saveChanges() async {
    if (vendorNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama Vendor tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _profileRef.set({
        'vendorName': vendorNameController.text,
        'openHours': openHoursController.text,
        'location': locationController.text,
        'contactNumber': contactNumberController.text,
        'description': descriptionController.text,
      }, SetOptions(merge: true)); // merge:true agar aman untuk update/create

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan berhasil disimpan!')),
      );
      Navigator.pop(context); // Kembali ke halaman profil
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan perubahan: $e")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    vendorNameController.dispose();
    openHoursController.dispose();
    locationController.dispose();
    contactNumberController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF9800),
        title: const Text('Edit Profile'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(
                      label: 'Vendor Name',
                      hintText: 'Example: Healthy Kitchen',
                      controller: vendorNameController,
                    ),
                    _buildTextField(
                      label: 'Open Hours',
                      hintText: 'Example: 08:00 - 20:00',
                      controller: openHoursController,
                    ),
                    _buildTextField(
                      label: 'Location',
                      hintText: 'Example: Jakarta, Indonesia',
                      controller: locationController,
                    ),
                    _buildTextField(
                      label: 'Contact Number',
                      hintText: 'Example: +62 812 3456 7890',
                      controller: contactNumberController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      label: 'Description',
                      hintText: 'Example: Trusted Healthy Food Supplier',
                      controller: descriptionController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Change',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFFF9800),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
