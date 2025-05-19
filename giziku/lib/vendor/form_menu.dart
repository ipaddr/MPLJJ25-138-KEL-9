import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'menu_data.dart'; // import model MenuData

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newMenu = MenuData(
        date: dateController.text,
        food: foodController.text,
        calories: '${caloriesController.text} kkal',
        time: timeController.text,
      );

      Navigator.pop(context, newMenu); // Return the new menu item
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFA726),
        title: const Text('Add New Menu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.orange[50],
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Delivery Date
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

              // Food Items
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

              // Calories
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

              // Protein
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

              // Carbohydrates
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

              // Delivery Time
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFA726),
                  ),
                  child: const Text(
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
}
