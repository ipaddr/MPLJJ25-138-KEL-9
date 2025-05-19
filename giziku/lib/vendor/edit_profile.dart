import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController vendorNameController = TextEditingController();
  final TextEditingController openHoursController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    // Penting untuk menghindari memory leaks
    vendorNameController.dispose();
    openHoursController.dispose();
    locationController.dispose();
    contactNumberController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Contoh validasi sederhana
    if (vendorNameController.text.isEmpty || openHoursController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vendor Name dan Open Hours tidak boleh kosong'),
        ),
      );
      return;
    }

    // TODO: Simpan data ke database atau API
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Perubahan disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF6ED), // krem muda
      appBar: AppBar(
        backgroundColor: Color(0xFFFF9800), // oranye
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
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
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
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
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
