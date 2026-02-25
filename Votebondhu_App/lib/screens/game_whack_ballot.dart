import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/games_controller.dart';

class WhackABallotPage extends StatefulWidget {
  const WhackABallotPage({super.key});

  @override
  State<WhackABallotPage> createState() => _WhackABallotPageState();
}

class _WhackABallotPageState extends State<WhackABallotPage> {
  final GamesController _gamesController = Get.find<GamesController>();
  
  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  int _activeHole = -1;
  Timer? _gameTimer;
  Timer? _spawnTimer;
  final Random _random = Random();

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
      _activeHole = -1;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _endGame();
      }
    });

    _spawn();
  }

  void _spawn() {
    if (!_isPlaying) return;

    setState(() {
      _activeHole = _random.nextInt(9);
    });

    // Random duration for ballot to be up
    int duration = 600 + _random.nextInt(600);
    _spawnTimer = Timer(Duration(milliseconds: duration), () {
      if (_isPlaying) {
        setState(() {
          _activeHole = -1;
        });
        // Random wait before next spawn
        Timer(Duration(milliseconds: 200 + _random.nextInt(400)), _spawn);
      }
    });
  }

  void _whack(int index) {
    if (_isPlaying && _activeHole == index) {
      setState(() {
        _score++;
        _activeHole = -1; // Remove it once whacked
      });
      _spawnTimer?.cancel();
      _spawn(); // Spawn immediately after whack for faster gameplay
    }
  }

  void _endGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _activeHole = -1;
    });
    _gamesController.addPoints(_score * 5); // 5 points per whack
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Whack-a-Ballot')),
      backgroundColor: Colors.brown[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: $_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Time: $_timeLeft', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _timeLeft < 10 ? Colors.red : Colors.black)),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                bool isActive = _activeHole == index;
                return GestureDetector(
                  onTap: () => _whack(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.brown[600]!, width: 4),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 4))],
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: isActive ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 100),
                        child: Transform.translate(
                          offset: const Offset(0, -10),
                          child: Icon(Icons.mail, size: 60, color: Colors.green[700]),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (!_isPlaying)
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(_score == 0 ? 'START GAME' : 'PLAY AGAIN', style: const TextStyle(fontSize: 20)),
              ),
            ),
        ],
      ),
    );
  }
}
