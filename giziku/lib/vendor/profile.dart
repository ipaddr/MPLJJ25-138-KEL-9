import 'package:flutter/material.dart';
import 'edit_profile.dart'; // Import file edit profile
import '../login/login.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.restaurant, size: 80),
            const SizedBox(height: 8),
            const Text(
              'Healthy Kitchen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Trusted Healthy Food Supplier',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Info Cards
            _infoCard(
              icon: Icons.access_time,
              label: 'Open Hours',
              value: '08:00 - 20:00',
            ),
            const SizedBox(height: 12),
            _infoCard(
              icon: Icons.location_on,
              label: 'Location',
              value: 'Padang,\nIndonesia',
            ),
            const SizedBox(height: 12),
            _infoCard(
              icon: Icons.phone,
              label: 'Phone Number',
              value: '+62 8123-124-2346',
            ),
            const SizedBox(height: 12),

            // Settings with Navigation
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: const [
                    Icon(Icons.settings, color: Colors.black),
                    SizedBox(width: 12),
                    Expanded(child: Text('Edit Profile')),
                    Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA726),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
