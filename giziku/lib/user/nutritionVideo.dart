import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'food_groups_guide.dart';

class NutritionVideoScreen extends StatelessWidget {
  const NutritionVideoScreen({super.key});

  // Daftar video
  final List<Map<String, String>> videoList = const [
    {
      'thumbnail': 'https://img.youtube.com/vi/OgmFQ3yGJXM/0.jpg',
      'url': 'https://youtu.be/OgmFQ3yGJXM?si=-7D9BuFjuSKizOTv',
      'title': 'Gizi Buruk dan Nutrisi',
    },
    {
      'thumbnail': 'https://img.youtube.com/vi/p4W-bvGvyfk/0.jpg',
      'url': 'https://youtu.be/p4W-bvGvyfk?si=pQlEAGrKN__TE9gL',
      'title': 'Pedoman Gizi Seimbang',
    },
    {
      'thumbnail': 'https://img.youtube.com/vi/yoFP3-N8TM4/0.jpg',
      'url': 'https://youtu.be/yoFP3-N8TM4?si=ARO4ozDyHz8Jqn43',
      'title':
          'Karbohidrat, Lemak, & Protein | Hubungan Makanan dengan Kesehatan ',
    },
  ];

  Future<void> _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint("Tidak dapat membuka URL $url.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Custom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: const Color(0xFFFFA726),
              height: 50,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Dasar - Dasar Nutrisi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: videoList.length,
                itemBuilder: (context, index) {
                  final video = videoList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(video['thumbnail']!),
                        ),
                        const SizedBox(height: 12),
                        Text(video['title']!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Tonton'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _openURL(video['url']!);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodGroupsGuideScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Panduan Nutrisi>>',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
