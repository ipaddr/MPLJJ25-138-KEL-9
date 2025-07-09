import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddMenuScreen extends StatefulWidget {
  const AddMenuScreen({super.key});

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController foodController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();

  bool _isLoading = false;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  /// Mengirim data form ke Firebase Firestore
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Mengirim data ke koleksi 'menus'
        await FirebaseFirestore.instance.collection('menus').add({
          'date': dateController.text,
          'foodItems': foodController.text,
          'calories': int.tryParse(caloriesController.text) ?? 0,
          'protein': int.tryParse(proteinController.text) ?? 0,
          'carbs': int.tryParse(carbsController.text) ?? 0,
          'deliveryTime': timeController.text,
          'createdAt': FieldValue.serverTimestamp(), // Untuk pengurutan
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu berhasil ditambahkan!')),
        );
        Navigator.pop(context); // Kembali ke halaman menu
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan menu: $e')));
      }
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    foodController.dispose();
    caloriesController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    super.dispose();
  }

  // ... (build method dan helper widget buildOrangeInputDecoration tetap sama)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726),
        title: const Text('Add New Menu'),
      ),
      body: Container(
        color: Colors.orange[50],
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: buildOrangeInputDecoration(
                  'Delivery Date',
                  'e.g., 21 May 2025',
                  icon: Icons.calendar_today,
                ),
                validator:
                    (value) => value!.isEmpty ? 'Select delivery date' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: foodController,
                decoration: buildOrangeInputDecoration(
                  'Food Items',
                  'e.g., Nasi, Ayam Goreng, Sayur Bayam',
                ),
                validator:
                    (value) => value!.isEmpty ? 'Enter food items' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: buildOrangeInputDecoration(
                  'Calories (kkal)',
                  'e.g., 500',
                ),
                validator: (value) => value!.isEmpty ? 'Enter calories' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: proteinController,
                keyboardType: TextInputType.number,
                decoration: buildOrangeInputDecoration(
                  'Protein (grams)',
                  'e.g., 30',
                ),
                validator: (value) => value!.isEmpty ? 'Enter protein' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: carbsController,
                keyboardType: TextInputType.number,
                decoration: buildOrangeInputDecoration(
                  'Carbohydrates (grams)',
                  'e.g., 60',
                ),
                validator: (value) => value!.isEmpty ? 'Enter carbs' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: timeController,
                readOnly: true,
                onTap: _selectTime,
                decoration: buildOrangeInputDecoration(
                  'Estimated Delivery Time',
                  'Select time',
                  icon: Icons.access_time,
                ),
                validator:
                    (value) => value!.isEmpty ? 'Select delivery time' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Add',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration buildOrangeInputDecoration(
    String label,
    String hint, {
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFFA726), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
