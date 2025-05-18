import 'package:flutter/material.dart';

class FormDeliveryPage extends StatefulWidget {
  const FormDeliveryPage({Key? key}) : super(key: key);

  @override
  State<FormDeliveryPage> createState() => _FormDeliveryPageState();
}

class _FormDeliveryPageState extends State<FormDeliveryPage> {
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _mealsController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  TimeOfDay? _selectedTime; // Digunakan dengan benar

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _submitForm() {
    final schoolName = _schoolController.text;
    final meals = int.tryParse(_mealsController.text) ?? 0;
    final deliveryTime = _selectedTime;

    if (schoolName.isEmpty || deliveryTime == null || meals <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the form correctly')),
      );
      return;
    }

    // Gunakan _selectedTime misalnya untuk simpan ke database, print, dsb
    print('School: $schoolName');
    print('Meals: $meals');
    print('Delivery Time: ${deliveryTime.format(context)}');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Delivery added!')));
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
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Add Delivery'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _schoolController,
              decoration: InputDecoration(
                labelText: 'Name of school',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mealsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Meals',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: _pickTime,
              decoration: InputDecoration(
                labelText: 'Delivery Time',
                suffixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _submitForm,
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
