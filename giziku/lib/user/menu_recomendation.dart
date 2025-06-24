import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dashboard.dart'; // Pastikan nama file dan kelas sudah benar
import 'progress.dart'; // Pastikan nama file dan kelas sudah benar
import 'profil.dart'; // Pastikan nama file dan kelas sudah benar
import 'detail_menu.dart'; // Ini diasumsikan sebagai MealDetailScreen

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final int _currentIndex = 1;

  // <<< DIHAPUS: Fungsi _addDummyMeal() tidak diperlukan di aplikasi pengguna.
  // Fungsi ini hanya untuk admin.

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        return;
      case 2:
        screen = const ProgressScreen();
        break;
      case 3:
        screen = const ProfileScreen();
        break;
      default:
        screen = const HomeScreen();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Rekomendasi Menu',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('meals')
                .orderBy('created_at', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // <<< DIPERBARUI: Pesan saat data kosong, tanpa instruksi menambah data.
            return const Center(
              child: Text(
                'Saat ini belum ada rekomendasi menu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final meals = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              80,
            ), // Padding bawah agar tidak tertutup nav bar
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final data = meals[index].data() as Map<String, dynamic>;

              // Menggunakan 'kategori' dari database jika ada
              final String title = data['nama'] ?? 'Nama Makanan';
              final String description =
                  data['deskripsi'] ?? 'Deskripsi makanan.';
              final int timeInMinutes = data['waktu_persiapan'] ?? 0;
              final int caloriesKcal = data['kalori'] ?? 0;
              final String imageUrl = data['image_url'] ?? '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: MealCard(
                  title: title,
                  description: description,
                  time: '$timeInMinutes mins',
                  calories: '$caloriesKcal kcal',
                  imageUrl: imageUrl,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealDetailScreen(mealData: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // <<< DIHAPUS: FloatingActionButton tidak diperlukan di aplikasi pengguna.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: Colors.orange,
        type: BottomNavigationBarType.fixed,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progres',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// ... Kelas MealCard dan MealDetailScreen tetap sama, tidak perlu diubah ...
class MealCard extends StatelessWidget {
  // ... kode MealCard Anda ...
  final String title;
  final String description;
  final String time;
  final String calories;
  final String imageUrl; // <<< Tambahkan ini
  final VoidCallback? onTap;

  const MealCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.calories,
    this.imageUrl = '', // <<< Beri nilai default kosong
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Meal
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300, // Placeholder warna latar belakang
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  topRight: Radius.circular(11),
                ),
                child:
                    imageUrl
                            .isNotEmpty // <<< Tampilkan gambar dari URL jika ada
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                        : const Center(
                          child: Icon(
                            Icons.no_photography_outlined,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(color: Colors.black54)),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.local_fire_department_outlined,
                        size: 16,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        calories,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
