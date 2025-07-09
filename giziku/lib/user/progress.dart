import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dashboard.dart';
import 'menu_recomendation.dart';
import 'profil.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final int _currentIndex = 2;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const MealsScreen();
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
    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Silakan login untuk melihat progres.")),
      );
    }

    // Menggunakan StreamBuilder untuk data profil (berat & tinggi saat ini)
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Lacak Progres',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('users')
                .doc(_currentUser!.uid)
                .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text("Data profil tidak ditemukan."));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final currentWeight = (userData['weight'] as num? ?? 0).toDouble();
          final currentHeight = (userData['height'] as num? ?? 0).toDouble();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStatBox('Berat Sekarang', '$currentWeight kg'),
                    const SizedBox(width: 12),
                    _buildStatBox('Tinggi', '$currentHeight cm'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressChart(),
                const SizedBox(height: 24),
                const Text(
                  'Entri Terbaru',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildEntryList()),
                const SizedBox(height: 12),
                _buildAddEntryButton(),
              ],
            ),
          );
        },
      ),
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

  Widget _buildStatBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.orange),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Expanded(
                child: Text(
                  'Grafik Progres',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text('30 hari terakhir', style: TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(_currentUser!.uid)
                    .collection('growth_entries')
                    .orderBy('date', descending: false)
                    .limitToLast(30) // More efficient for getting the latest
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox(
                  height: 180,
                  child: Center(child: Text('Belum ada data untuk grafik')),
                );
              }

              List<FlSpot> points = [];
              double minWeight = double.maxFinite;
              double maxWeight = double.minPositive;

              for (int i = 0; i < snapshot.data!.docs.length; i++) {
                final doc = snapshot.data!.docs[i];
                final weight = (doc['weight'] as num).toDouble();
                // Gunakan index sebagai sumbu X untuk kesederhanaan
                points.add(FlSpot(i.toDouble(), weight));
                if (weight < minWeight) minWeight = weight;
                if (weight > maxWeight) maxWeight = weight;
              }

              return SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    // ... (Konfigurasi LineChartData tetap sama)
                    minY: (minWeight - 5).floorToDouble(),
                    maxY: (maxWeight + 5).ceilToDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                    // ...
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEntryList() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .collection('growth_entries')
              .orderBy('date', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Belum ada entri'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final weight = (doc['weight'] as num).toDouble();
            final date = (doc['date'] as Timestamp).toDate();
            return _buildEntryTile(
              '$weight kg',
              DateFormat('dd MMMM yyyy').format(date),
            );
          },
        );
      },
    );
  }

  Widget _buildEntryTile(String weight, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: ListTile(
        title: Text(
          weight,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(date),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildAddEntryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => const GrowthFormSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Entri Baru'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

/// Bottom sheet untuk menambah entri baru
class GrowthFormSheet extends StatefulWidget {
  const GrowthFormSheet({super.key});

  @override
  State<GrowthFormSheet> createState() => _GrowthFormSheetState();
}

class _GrowthFormSheetState extends State<GrowthFormSheet> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  DateTime? _selectedDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    if (_selectedDate == null ||
        _weightController.text.isEmpty ||
        _heightController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi")));
      return;
    }

    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Masukkan angka yang valid")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User tidak login.");

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      // 1. Tambahkan entri baru ke sub-koleksi
      await userDocRef.collection('growth_entries').add({
        'date': _selectedDate,
        'weight': weight,
        'height': height,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. **PERBAIKAN:** Update data di dokumen profil utama
      await userDocRef.update({'weight': weight, 'height': height});

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Wrap(
        runSpacing: 16,
        children: [
          const Center(
            child: Text(
              'Tambah Entri Pertumbuhan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Tanggal',
              hintText:
                  _selectedDate == null
                      ? 'Pilih tanggal'
                      : DateFormat('dd MMMM yyyy').format(_selectedDate!),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Berat (kg)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
            ),
          ),
          TextField(
            controller: _heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Tinggi (cm)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Colors.black,
              ),
              child:
                  _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
