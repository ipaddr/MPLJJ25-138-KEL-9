import 'package:flutter/material.dart';
import 'quiz.dart';

class FoodGroupsGuideScreen extends StatefulWidget {
  const FoodGroupsGuideScreen({super.key});

  @override
  State<FoodGroupsGuideScreen> createState() => _FoodGroupsGuideScreenState();
}

class _FoodGroupsGuideScreenState extends State<FoodGroupsGuideScreen> {
  String selectedGroup = 'Carbohydrates';

  final Map<String, String> groupDescriptions = {
    'Proteins':
        'Sources like meat, fish, eggs, and legumes help build and repair body tissues.',
    'Carbohydrates':
        'Sources like rice, bread, pasta, and potatoes help provide energy for the body and brain to function properly.',
    'Vegetables':
        'Vegetables are rich in vitamins, minerals, and fiber that support good health.',
    'Fruits':
        'Fruits provide essential nutrients and antioxidants for overall well-being.',
    'Dairy':
        'Dairy products like milk and cheese are important sources of calcium and vitamin D.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFFFA726),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Food Groups Guide',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // balance for icon spacing
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Food group buttons
            ...[
              'Proteins',
              'Carbohydrates',
              'Vegetables',
              'Fruits',
              'Dairy',
            ].map((group) {
              final isSelected = group == selectedGroup;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedGroup = group;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? const Color(0xFFFFA726) : Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(
                      color: Color(0xFFFFA726),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(group, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Description box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFFA726)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Text(
                  '$selectedGroup: ${groupDescriptions[selectedGroup]}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // QUIZ button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QuizApp()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'QUIZ>>',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
