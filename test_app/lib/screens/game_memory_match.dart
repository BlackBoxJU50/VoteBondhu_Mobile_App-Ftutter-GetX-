import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/games_controller.dart';

class MemoryMatchPage extends StatefulWidget {
  const MemoryMatchPage({super.key});

  @override
  State<MemoryMatchPage> createState() => _MemoryMatchPageState();
}

class _MemoryMatchPageState extends State<MemoryMatchPage> {
  final GamesController _gamesController = Get.find<GamesController>();

  final List<IconData> _icons = [
    Icons.wb_sunny, Icons.wb_sunny,
    Icons.eco, Icons.eco,
    Icons.directions_boat, Icons.directions_boat,
    Icons.electric_bolt, Icons.electric_bolt,
    Icons.agriculture, Icons.agriculture,
    Icons.umbrella, Icons.umbrella,
  ];

  late List<bool> _isFlipped;
  late List<bool> _isMatched;
  int _firstSelectedIndex = -1;
  bool _canFlip = true;
  int _matchesFound = 0;
  int _tries = 0;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _icons.shuffle();
      _isFlipped = List.generate(_icons.length, (_) => false);
      _isMatched = List.generate(_icons.length, (_) => false);
      _firstSelectedIndex = -1;
      _matchesFound = 0;
      _tries = 0;
      _canFlip = true;
    });
  }

  void _onCardTap(int index) {
    if (!_canFlip || _isFlipped[index] || _isMatched[index]) return;

    setState(() {
      _isFlipped[index] = true;
    });

    if (_firstSelectedIndex == -1) {
      _firstSelectedIndex = index;
    } else {
      _tries++;
      _canFlip = false;
      if (_icons[_firstSelectedIndex] == _icons[index]) {
        // Match!
        setState(() {
          _isMatched[_firstSelectedIndex] = true;
          _isMatched[index] = true;
          _matchesFound++;
          _canFlip = true;
          _firstSelectedIndex = -1;
        });
        if (_matchesFound == _icons.length ~/ 2) {
          _showWinDialog();
        }
      } else {
        // No match
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            _isFlipped[_firstSelectedIndex] = false;
            _isFlipped[index] = false;
            _firstSelectedIndex = -1;
            _canFlip = true;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    int points = (50 - _tries).clamp(10, 50); // Higher points for fewer tries
    _gamesController.addPoints(points);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 60, color: Colors.orange),
            const SizedBox(height: 10),
            Text('You cleared the board in $_tries tries.'),
            const SizedBox(height: 5),
            Text('Points Earned: $points', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('New Game')),
          ElevatedButton(onPressed: () { Get.back(); Get.back(); }, child: const Text('Exit')),
        ],
      ),
    ).then((_) => _resetGame());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Symbol Memory Match')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Matches: $_matchesFound / ${_icons.length ~/ 2}   |   Tries: $_tries', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: _isMatched[index] ? Colors.green[200] : (_isFlipped[index] ? Colors.white : Colors.green),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Center(
                        child: _isFlipped[index] || _isMatched[index]
                          ? Icon(_icons[index], size: 40, color: Colors.green[800])
                          : const Icon(Icons.how_to_vote, size: 40, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(onPressed: _resetGame, child: const Text('Reset Game')),
          ],
        ),
      ),
    );
  }
}
