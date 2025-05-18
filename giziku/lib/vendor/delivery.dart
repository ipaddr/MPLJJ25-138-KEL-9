import 'package:flutter/material.dart';

class DeliveryScreen extends StatelessWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Background krem/oranye muda
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA726), // Warna FFA726
        title: const Text('Deliveries', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: const [
          DeliveryCard(
            time: '08:00',
            location: 'SD N 12 Padang',
            status: DeliveryStatus.inProgress,
          ),
          DeliveryCard(time: '09:45', location: 'SMK N 2 Padang', meals: 120),
          DeliveryCard(time: '11:30', location: 'MTs N 1 Padang', meals: 100),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFFFF3E0),
        child: ElevatedButton(
          onPressed: () {
            // Add delivery action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Add Delivery',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

enum DeliveryStatus { inProgress, completed }

class DeliveryCard extends StatelessWidget {
  final String time;
  final String location;
  final int? meals;
  final DeliveryStatus? status;

  const DeliveryCard({
    super.key,
    required this.time,
    required this.location,
    this.meals,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Card putih
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: const Border(
        bottom: BorderSide(color: Color(0xFFFFA726), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            if (status == DeliveryStatus.inProgress)
              const Icon(Icons.circle, color: Colors.green, size: 12)
            else if (meals != null)
              Text('$meals meals', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
