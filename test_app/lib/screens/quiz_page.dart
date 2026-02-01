import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/games_controller.dart';
import 'package:test_app/widgets/custom_card.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final GamesController _gamesController = Get.find<GamesController>();
  
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isFinished = false;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What is the minimum age for voting in Bangladesh?',
      'options': ['16', '18', '21', '25'],
      'answer': 1,
    },
    {
      'question': 'Which commission is responsible for conducting elections in Bangladesh?',
      'options': ['Anti-Corruption Commission', 'Election Commission', 'Human Rights Commission', 'Public Service Commission'],
      'answer': 1,
    },
    {
      'question': 'How often are General Elections held in Bangladesh?',
      'options': ['Every 3 years', 'Every 4 years', 'Every 5 years', 'Every 6 years'],
      'answer': 2,
    },
    {
      'question': 'What is the color of the ballot box used in Bangladesh elections?',
      'options': ['Red', 'Green', 'Translucent/Plastic', 'Black'],
      'answer': 2,
    },
    {
      'question': 'Can a guest user (unregistered) vote in the national elections?',
      'options': ['Yes', 'No', 'Sometimes', 'If they have a NID'],
      'answer': 1,
    },
  ];

  void _answerQuestion(int selectedIndex) {
    if (_questions[_currentQuestionIndex]['answer'] == selectedIndex) {
      _score++;
    }

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _isFinished = true;
        _completeQuiz();
      }
    });
  }

  void _completeQuiz() {
    int earnedPoints = _score * 20; // 20 points per correct answer
    _gamesController.addPoints(earnedPoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Election Trivia')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isFinished ? _buildResultView() : _buildQuestionView(),
      ),
    );
  }

  Widget _buildQuestionView() {
    var question = _questions[_currentQuestionIndex];
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
        ),
        const SizedBox(height: 30),
        Text(
          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Text(
          question['question'],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        ...List.generate(
          (question['options'] as List).length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.green),
                ),
                onPressed: () => _answerQuestion(index),
                child: Text(question['options'][index], style: const TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    return Center(
      child: CustomCard(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
            const SizedBox(height: 20),
            const Text('Quiz Finished!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Your Score: $_score / ${_questions.length}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 5),
            Text('Points Earned: ${_score * 20}', style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Back to Games'),
            ),
          ],
        ),
      ),
    );
  }
}
