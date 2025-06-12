import 'package:flutter/material.dart';

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const QuizScreen(); // Tidak lagi menggunakan MaterialApp di sini
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _selectedOption = -1;

  final List<String> options = ['Rice', 'Chicken', 'Apple', 'Bread'];

  @override
  Widget build(BuildContext context) {
    print("QuizScreen sedang dibangun..."); // Untuk debug

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Tambahkan logika kembali jika diperlukan
          },
        ),
        title: const Text('QUIZ', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Question 3 of 10',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'What is the main source of protein in a balanced diet?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < options.length; i++)
                    RadioListTile(
                      activeColor: Colors.orange,
                      title: Text(
                        '${String.fromCharCode(65 + i)}. ${options[i]}',
                      ),
                      value: i,
                      groupValue: _selectedOption,
                      onChanged: (value) {
                        setState(() {
                          _selectedOption = value!;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: 0.3,
              color: Colors.orange,
              backgroundColor: Colors.grey[300],
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            const Text('3/10', style: TextStyle(fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  // Tambahkan logika untuk pindah ke pertanyaan selanjutnya
                },
                child: const Text(
                  'Next',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
