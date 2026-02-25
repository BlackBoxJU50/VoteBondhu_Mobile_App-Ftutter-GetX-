import 'package:flutter/material.dart';
import 'package:test_app/utils/custom_toast.dart';
import 'package:test_app/widgets/custom_card.dart';

class BallotSimulationWidget extends StatefulWidget {
  const BallotSimulationWidget({super.key});

  @override
  State<BallotSimulationWidget> createState() => _BallotSimulationWidgetState();
}

class _BallotSimulationWidgetState extends State<BallotSimulationWidget> {
  int? _selectedCandidate;
  bool _isSuccess = false;
  int _stampVersion = 0; // Incremented to trigger animation
  
  final List<Map<String, dynamic>> _candidates = [
    {'name': 'Candidate A', 'symbol': Icons.wb_sunny, 'image': 'https://img.icons8.com/color/96/000000/sun.png'},
    {'name': 'Candidate B', 'symbol': Icons.eco, 'image': 'https://img.icons8.com/color/96/000000/leaf.png'},
    {'name': 'Candidate C', 'symbol': Icons.directions_boat, 'image': 'https://img.icons8.com/color/96/000000/boat.png'},
  ];

  void _onStamp(int index) {
    if (_isSuccess) return;
    setState(() {
      _selectedCandidate = index;
      _stampVersion++;
    });
    // Visual feedback for the "Click"
  }

  void _verify() {
    if (_selectedCandidate == null) {
      CustomToast.showInfo('Please select a candidate to stamp');
      return;
    }
    setState(() {
      _isSuccess = true;
    });
    CustomToast.showSuccess('Perfect! You voted correctly without spoiling the ballot.');
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: Colors.yellow[50],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_note, color: Colors.brown),
              const SizedBox(width: 8),
              const Text(
                "Practice Your Vote",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Tap the box once to stamp. Avoid the edges!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.brown, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.brown[300]!, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: List.generate(_candidates.length, (index) {
                bool isThisSelected = _selectedCandidate == index;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Icon(_candidates[index]['symbol'], size: 35, color: Colors.blueGrey)),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        _candidates[index]['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _onStamp(index),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.brown, width: 2),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isThisSelected)
                                TweenAnimationBuilder(
                                  key: ValueKey('stamp_$_stampVersion'),
                                  duration: const Duration(milliseconds: 200),
                                  tween: Tween<double>(begin: 2.0, end: 1.0),
                                  curve: Curves.bounceOut,
                                  builder: (context, double scale, child) {
                                    return Transform.scale(
                                      scale: scale,
                                      child: Transform.rotate(
                                        angle: -0.2,
                                        child: const Icon(Icons.check_circle, color: Colors.purple, size: 40),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSuccess ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSuccess ? Colors.grey : Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isSuccess ? "PRACTICE COMPLETED" : "VERIFY MY VOTE",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          if (_isSuccess)
            TextButton(
              onPressed: () {
                setState(() {
                  _isSuccess = false;
                  _selectedCandidate = null;
                });
              },
              child: const Text("Try Again to Master", style: TextStyle(color: Colors.brown)),
            ),
        ],
      ),
    );
  }
}
