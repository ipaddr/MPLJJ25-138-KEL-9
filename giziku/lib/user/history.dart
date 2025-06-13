import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6EC),
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Riwayat', style: TextStyle(color: Colors.black)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          HistoryCard(
            date: 'Senin, 4 Januari 2025',
            meal: 'Makan Siang',
            isCompleted: true,
          ),
          SizedBox(height: 12),
          HistoryCard(
            date: 'Rabu, 12 Maret 2025',
            meal: 'Makan Siang',
            isCompleted: true,
          ),
          SizedBox(height: 12),
          HistoryCard(
            date: 'Jumat, 14 Maret 2025',
            meal: 'Makan Siang',
            isCompleted: false,
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String date;
  final String meal;
  final bool isCompleted;

  const HistoryCard({
    super.key,
    required this.date,
    required this.meal,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(meal, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Icon(
            isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: Colors.black54,
          ),
        ],
      ),
    );
  }
}
