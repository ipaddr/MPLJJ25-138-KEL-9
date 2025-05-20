import 'package:flutter/material.dart';
import 'dashboard_admin.dart';
import 'profil_admin.dart';
import 'scanner.dart';

class RecipientDataScreen extends StatefulWidget {
  const RecipientDataScreen({super.key});

  @override
  State<RecipientDataScreen> createState() => _RecipientDataScreenState();
}

class _RecipientDataScreenState extends State<RecipientDataScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final int _currentIndex = 2;

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

  String? _selectedGender;
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFFFA500);
    return Scaffold(
      backgroundColor: const Color(0xFFFEF7EF),
      appBar: AppBar(
        backgroundColor: orangeColor,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Recipient Data',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Full Name
            buildLabel("Name"),
            buildTextField(controller: _nameController, hintText: "Full Name"),

            // Date of Birth
            buildLabel("Date of Birth"),
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "dd/mm/yyyy",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2015),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _dobController.text =
                          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                    }
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 1),

            // Gender
            buildLabel("Gender"),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              hint: const Text("choose your gender"),
              items:
                  genderOptions
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 1),

            // Grade
            buildLabel("Grade"),
            buildTextField(controller: _gradeController, hintText: "ex: 5"),

            // Class
            buildLabel("Class"),
            buildTextField(controller: _classController, hintText: "ex: A"),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: orangeColor,
        selectedItemColor: Colors.black54,
        unselectedItemColor: Colors.black54,
        showUnselectedLabels: true,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
