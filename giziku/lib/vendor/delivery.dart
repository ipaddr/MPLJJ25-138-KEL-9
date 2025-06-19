import 'package:flutter/material.dart';
import 'form_delivery.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final List<DeliveryData> _deliveries = [
    DeliveryData(
      time: '08:00',
      location: 'SD N 12 Padang',
      meals: 100,
      status: DeliveryStatus.inProgress,
    ),
    DeliveryData(time: '09:45', location: 'SMK N 2 Padang', meals: 120),
    DeliveryData(time: '11:30', location: 'MTs N 1 Padang', meals: 100),
  ];

  void _navigateAndAddDelivery() async {
    final newDelivery = await Navigator.push<DeliveryData>(
      context,
      MaterialPageRoute(builder: (context) => const FormDeliveryPage()),
    );

    if (newDelivery != null) {
      setState(() {
        _deliveries.add(newDelivery);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title Section (bukan AppBar)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFA726),
          child: const Text(
            'Pengiriman',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Delivery List
        Expanded(
          child: ListView.builder(
            itemCount: _deliveries.length,
            itemBuilder: (context, index) {
              final delivery = _deliveries[index];
              return DeliveryCard(
                time: delivery.time,
                location: delivery.location,
                meals: delivery.meals,
                status: delivery.status,
              );
            },
          ),
        ),

        // Add Delivery Button
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFF3E0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateAndAddDelivery,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Tambah Pengiriman',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum DeliveryStatus { inProgress, completed }

class DeliveryData {
  final String time;
  final String location;
  final int meals;
  final DeliveryStatus status;

  DeliveryData({
    required this.time,
    required this.location,
    required this.meals,
    this.status = DeliveryStatus.completed,
  });
}

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
      color: Colors.white,
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
              Text('$meals Makanan', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
