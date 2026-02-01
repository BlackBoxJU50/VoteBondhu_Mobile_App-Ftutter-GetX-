import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/games_controller.dart';

class BallotCollectorPage extends StatefulWidget {
  const BallotCollectorPage({super.key});

  @override
  State<BallotCollectorPage> createState() => _BallotCollectorPageState();
}

class _BallotCollectorPageState extends State<BallotCollectorPage> {
  final GamesController _gamesController = Get.find<GamesController>();
  
  int _score = 0;
  bool _isPlaying = false;
  int _timeLeft = 30;
  Timer? _timer;
  
  final List<Ballot> _ballots = [];
  final Random _random = Random();

  void _startGame() {
    setState(() {
      _score = 0;
      _isPlaying = true;
      _timeLeft = 30;
      _ballots.clear();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
          // Add a new ballot every second
          _spawnBallot();
        });
      } else {
        _endGame();
      }
    });

    // Sub-timer for smoother spawning
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _spawnBallot();
    });
  }

  void _spawnBallot() {
    setState(() {
      _ballots.add(Ballot(
        id: DateTime.now().millisecondsSinceEpoch,
        x: _random.nextDouble() * 0.8 + 0.1, // 10% to 90% width
        y: 0.0,
        speed: _random.nextDouble() * 0.02 + 0.01,
      ));
    });
    _moveBallots();
  }

  void _moveBallots() {
    if (!_isPlaying) return;
    
    setState(() {
      for (var b in _ballots) {
        b.y += b.speed;
      }
      _ballots.removeWhere((b) => b.y > 1.0);
    });

    Future.delayed(const Duration(milliseconds: 50), _moveBallots);
  }

  void _catchBallot(int id) {
    if (!_isPlaying) return;
    setState(() {
      _ballots.removeWhere((b) => b.id == id);
      _score++;
    });
  }

  void _endGame() {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
    });
    _gamesController.addPoints(_score * 5); // 5 points per ballot
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ballot Collector')),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue[100]!, Colors.green[100]!],
              ),
            ),
          ),

          // Game Elements
          if (_isPlaying) ...[
            ..._ballots.map((b) => Positioned(
              left: b.x * MediaQuery.of(context).size.width,
              top: b.y * MediaQuery.of(context).size.height,
              child: GestureDetector(
                onTap: () => _catchBallot(b.id),
                child: const Icon(Icons.mail, size: 50, color: Colors.green),
              ),
            )),
            
            // Stats
            Positioned(
              top: 20,
              left: 20,
              child: Text('Score: $_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Text('Time: $_timeLeft', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
          ],

          // Overlay (Start/End)
          if (!_isPlaying)
            Center(
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_score == 0 ? Icons.play_circle : Icons.emoji_events, size: 80, color: Colors.green),
                      const SizedBox(height: 20),
                      Text(
                        _score == 0 ? 'Collect Ballots!' : 'Game Over!',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      if (_score > 0) ...[
                        Text('You caught $_score ballots', style: const TextStyle(fontSize: 18)),
                        Text('Points Earned: ${_score * 5}', style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        child: Text(_score == 0 ? 'START' : 'PLAY AGAIN'),
                      ),
                      if (_score > 0)
                        TextButton(onPressed: () => Get.back(), child: const Text('Exit')),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Ballot {
  final int id;
  double x;
  double y;
  double speed;
  Ballot({required this.id, required this.x, required this.y, required this.speed});
}
