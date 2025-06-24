import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MealDetailScreen extends StatelessWidget {
  // Menerima seluruh data meal dalam bentuk Map
  final Map<String, dynamic> mealData;

  const MealDetailScreen({super.key, required this.mealData});

  @override
  Widget build(BuildContext context) {
    // Ekstrak data dari Map dengan aman
    final String title = mealData['nama'] ?? 'Detail Menu';
    final String description = mealData['deskripsi'] ?? 'Tidak ada deskripsi.';
    final String imageUrl = mealData['image_url'] ?? '';
    final int time = mealData['waktu_persiapan'] ?? 0;
    final int calories = mealData['kalori'] ?? 0;

    // Ekstrak data array untuk bahan dan langkah-langkah
    // Konversi dari List<dynamic> ke List<String>
    final List<String> ingredients = List<String>.from(mealData['bahan'] ?? []);
    final List<String> steps = List<String>.from(mealData['tahapan'] ?? []);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- GAMBAR MAKANAN ---
            if (imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
                placeholder:
                    (context, url) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50),
                      ),
                    ),
              )
            else
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Text(
                    'Meal Image',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            // --- KONTEN DETAIL ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Deskripsi
                  Text(
                    description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),

                  // Info Waktu dan Kalori
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('$time mins', style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 20),
                      Icon(
                        Icons.local_fire_department_outlined,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$calories kcal',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),

                  // --- BAHAN-BAHAN ---
                  const Text(
                    'Bahan-Bahan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  // Menampilkan daftar bahan
                  if (ingredients.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          ingredients.map((ingredient) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4.0,
                                left: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Expanded(
                                    child: Text(
                                      ingredient,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    )
                  else
                    const Text('Bahan-bahan tidak tersedia.'),

                  const Divider(height: 32, thickness: 1),

                  // --- LANGKAH PERSIAPAN ---
                  const Text(
                    'Langkah-Langkah',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  // Menampilkan daftar langkah
                  if (steps.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(steps.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0, left: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  steps[index],
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    )
                  else
                    const Text('Langkah-langkah tidak tersedia.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
