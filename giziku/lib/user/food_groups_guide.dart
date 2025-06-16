import 'package:flutter/material.dart';
import 'quiz.dart';

class FoodGroupsGuideScreen extends StatefulWidget {
  const FoodGroupsGuideScreen({super.key});

  @override
  State<FoodGroupsGuideScreen> createState() => _FoodGroupsGuideScreenState();
}

class _FoodGroupsGuideScreenState extends State<FoodGroupsGuideScreen> {
  String selectedGroup = 'Karbohidrat';

  final Map<String, String> groupDescriptions = {
    'Protein':
        'Sumber seperti daging, ikan, telur, dan kacang-kacangan membantu membangun dan memperbaiki jaringan tubuh.',
    'Karbohidrat':
        'Sumber seperti nasi, roti, pasta, dan kentang memberikan energi untuk tubuh dan otak agar berfungsi dengan baik.',
    'Sayuran':
        'Sayuran kaya akan vitamin, mineral, dan serat yang mendukung kesehatan tubuh.',
    'Buah-buahan':
        'Buah-buahan memberikan nutrisi penting dan antioksidan untuk kesehatan secara keseluruhan.',
    'Produk Susu':
        'Produk susu seperti susu dan keju merupakan sumber kalsium dan vitamin D yang penting.',
    'Lemak':
        'Sumber energi, membantu penyerapan vitamin larut lemak (A, D, E, K), melindungi organ, dan menjaga kesehatan otak.',
    'Vitamin':
        'Senyawa organik yang dibutuhkan tubuh dalam jumlah kecil namun sangat penting, untuk metabolisme, pertumbuhan, dan pemeliharaan kesehatan',
  };

  final List<String> foodGroups = [
    'Protein',
    'Karbohidrat',
    'Sayuran',
    'Buah-buahan',
    'Produk Susu',
    'Lemak',
    'Vitamin',
  ];

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
                      'Panduan Nutrisi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tombol kelompok makanan
            ...foodGroups.map((group) {
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Text(
                      group,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Kotak deskripsi
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
                  '$selectedGroup: ${groupDescriptions[selectedGroup] ?? 'Deskripsi tidak tersedia.'}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tombol Quiz
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuizScreen(),
                      ),
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
                    'KUIS >>',
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
