import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<DocumentSnapshot> _questions = []; // List soal
  int _currentQuestion = 0;
  int _selectedOption = -1;

  Future<void> _loadQuestions() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('quiz').get();

      setState(() {
        _questions = snapshot.docs;
      });
    } catch (e) {
      debugPrint("Gagal mengambil soal: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil soal")));
    }
  }

  void _checkAnswer(int selectedIndex) {
    int correctIndex = _questions[_currentQuestion].get('correctIndex') as int;

    if (selectedIndex == correctIndex) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Benar!")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Salah! Coba lagi.")));
      return;
    }

    // Lanjut ke soal selanjutnya
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedOption = -1;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Quiz Selesai!")));
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var soal = _questions[_currentQuestion];
    List<String> options = List.from(soal['options']);
    int correctIndex = soal['correctIndex'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('QUIZ', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Pertanyaan ${_currentQuestion + 1} dari ${_questions.length}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pertanyaan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(soal['question'], style: TextStyle(fontSize: 16)),
                  SizedBox(height: 16),
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
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 80,
              ), // misal default, atau dikurangi
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed:
                    _selectedOption == -1
                        ? null
                        : () => _checkAnswer(_selectedOption),
                child: Text(
                  _currentQuestion == _questions.length - 1
                      ? "Selesai"
                      : "Lanjut",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
