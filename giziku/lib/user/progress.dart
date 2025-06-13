import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'menu_recomendation.dart';
import 'profil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final int _currentIndex = 2;
  User? _currentUser;
  Stream<QuerySnapshot>? _entriesStream;
  double? _currentWeight;
  double? _currentHeight;

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
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid);

      // Fetch the last 30 entries for the chart, ordered by date ascending
      // so the chart shows progress from past to present correctly.
      // For the list, keep it descending to show latest first.
      _entriesStream =
          userDoc
              .collection('growth_entries')
              .orderBy('date', descending: true) // For latest entries in list
              .snapshots();

      userDoc
          .collection('growth_entries')
          .orderBy('date', descending: true)
          .limit(1)
          .get()
          .then((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final data = snapshot.docs.first.data();
              setState(() {
                _currentWeight = (data['weight'] as num).toDouble();
                _currentHeight = (data['height'] as num).toDouble();
              });
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatBox(
                  'Berat Sekarang',
                  _currentWeight != null ? '${_currentWeight!} kg' : '-',
                ),
                const SizedBox(width: 12),
                _buildStatBox(
                  'Tinggi',
                  _currentHeight != null ? '${_currentHeight!} cm' : '-',
                ),
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
          // We need to fetch data for the chart separately,
          // ordered ascending by date to display correctly from left to right.
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(_currentUser!.uid)
                    .collection('growth_entries')
                    .orderBy(
                      'date',
                      descending: false,
                    ) // Order ascending for chart
                    .limit(30) // Limit to last 30 entries for the chart
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Belum ada data untuk grafik'));
              }

              List<FlSpot> points = [];
              List<DateTime> dates = [];
              double minWeight = double.infinity;
              double maxWeight = double.negativeInfinity;
              double minDate = double.infinity;
              double maxDate = double.negativeInfinity;

              for (var doc in snapshot.data!.docs) {
                final weight = (doc['weight'] as num).toDouble();
                final timestamp = (doc['date'] as Timestamp).toDate();
                final dateInMs = timestamp.millisecondsSinceEpoch.toDouble();

                points.add(FlSpot(dateInMs, weight));
                dates.add(timestamp);

                if (weight < minWeight) minWeight = weight;
                if (weight > maxWeight) maxWeight = weight;
                if (dateInMs < minDate) minDate = dateInMs;
                if (dateInMs > maxDate) maxDate = dateInMs;
              }

              // Add some padding to min/max weight for better visualization
              if (minWeight == maxWeight) {
                // Handle case with single weight
                minWeight -= 5;
                maxWeight += 5;
              } else {
                minWeight -= (maxWeight - minWeight) * 0.1;
                maxWeight += (maxWeight - minWeight) * 0.1;
              }

              // Ensure minimum Y-axis is not negative
              if (minWeight < 0) minWeight = 0;

              return Container(
                height: 180, // Increased height for better readability
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine:
                          (value) => const FlLine(
                            color: Color(0xffececec),
                            strokeWidth: 1,
                          ),
                      getDrawingVerticalLine:
                          (value) => const FlLine(
                            color: Color(0xffececec),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: ((maxDate - minDate) / 4).clamp(
                            1.0,
                            double.infinity,
                          ), // Adjust interval dynamically
                          getTitlesWidget: (value, meta) {
                            final dateTime =
                                DateTime.fromMillisecondsSinceEpoch(
                                  value.toInt(),
                                );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                DateFormat(
                                  'dd/MM',
                                ).format(dateTime), // Format date as DD/MM
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(
                                0,
                              ), // Display whole numbers for weight
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 10,
                              ),
                            );
                          },
                          interval:
                              (maxWeight - minWeight) > 10
                                  ? 10
                                  : 5, // Adjust interval based on weight range
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: const Color(0xff37434d),
                        width: 1,
                      ),
                    ),
                    minX: minDate,
                    maxX: maxDate,
                    minY: minWeight,
                    maxY: maxWeight,
                    lineBarsData: [
                      LineChartBarData(
                        spots: points,
                        isCurved: true,
                        color: const Color.fromARGB(255, 255, 0, 0),
                        barWidth: 3, // Reduced bar width for cleaner look
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: false,
                        ), // No fill below the line
                      ),
                    ],
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
      stream: _entriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
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
              DateFormat('dd/MM/yyyy').format(date), // Consistent date format
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
        onTap: () {
          // You might want to implement an edit/view functionality here
        },
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

class GrowthFormSheet extends StatefulWidget {
  const GrowthFormSheet({super.key});

  @override
  State<GrowthFormSheet> createState() => _GrowthFormSheetState();
}

class _GrowthFormSheetState extends State<GrowthFormSheet> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
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
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Text(
            'Tambah Entri Pertumbuhan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Tanggal',
              hintText:
                  _selectedDate == null
                      ? 'Pilih tanggal'
                      : DateFormat(
                        'dd/MM/yyyy',
                      ).format(_selectedDate!), // Format selected date
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate:
                    _selectedDate ??
                    DateTime.now(), // Use selected date or current date
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Berat (kg)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.monitor_weight_outlined),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Tinggi (cm)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_selectedDate == null ||
                    _weightController.text.isEmpty ||
                    _heightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua field wajib diisi")),
                  );
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

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) throw Exception("User tidak login.");

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('growth_entries')
                      .add({
                        'date': _selectedDate,
                        'weight': weight,
                        'height': height,
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil disimpan")),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menyimpan: ${e.toString()}")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                foregroundColor: Colors.black,
              ),
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}
