import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  const MealDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E1),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // agar tombol kembali bisa berfungsi
          },
        ),
        title: const Text(
          'Grilled Salmon Bowl',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // <- Tambahkan ini
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image placeholder
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('Meal Image', style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),

            // Meal title and description
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Grilled Salmon Bowl',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fresh salmon with quinoa, avocado, and seasonal vegetables',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),

            // Time and Calories
            Row(
              children: const [
                Icon(Icons.access_time, size: 16),
                SizedBox(width: 4),
                Text('25 mins'),
                SizedBox(width: 16),
                Icon(Icons.local_fire_department, size: 16),
                SizedBox(width: 4),
                Text('420 kcal'),
              ],
            ),
            const SizedBox(height: 16),

            // Ingredients and Preparation card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ingredients',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• 100gr Salmon'),
                  Text('• 1/2 Avocado'),
                  Text('• 1 cup Quinoa'),
                  Text('• Olive oil, Salt, Pepper'),
                  SizedBox(height: 16),
                  Text(
                    'Preparation Steps',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('1. Cook the quinoa according to package instruction'),
                  Text('2. Grill the salmon until fully cooked'),
                  Text('3. Slice the avocado'),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
