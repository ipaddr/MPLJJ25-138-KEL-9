import 'package:flutter/material.dart';
import 'food_groups_guide.dart'; // Pastikan file ini ada dan sudah dibuat

class NutritionVideoScreen extends StatelessWidget {
  const NutritionVideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Custom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFFFA726),
              height: 50,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Basic Of Nutrition',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // untuk mengimbangi icon di kiri
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Placeholder video
            Container(
              height: 180,
              width: 300,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.play_circle, size: 50, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 32),

            // Mark as Complete Button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFFA726)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as Complete!')),
                );
              },
              child: const Text(
                'Mark as Complete',
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 16),

            // Navigate to Food Groups Guide
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoodGroupsGuideScreen(),
                  ),
                );
              },
              child: const Text(
                'Food Groups Guide>>',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
