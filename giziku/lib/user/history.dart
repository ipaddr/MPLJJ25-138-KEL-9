import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Riwayat Makan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListTile(
          title: Text('Senin, 4 Januari 2025'),
          subtitle: Text('Makan Siang'),
        ),
        ListTile(
          title: Text('Rabu, 12 Maret 2025'),
          subtitle: Text('Makan Siang'),
        ),
        ListTile(
          title: Text('Jumat, 14 Maret 2025'),
          subtitle: Text('Makan Siang'),
        ),
      ],
    );
  }
}
