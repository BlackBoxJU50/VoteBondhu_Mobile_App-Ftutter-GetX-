import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class VoterChecklist extends StatefulWidget {
  const VoterChecklist({super.key});

  @override
  State<VoterChecklist> createState() => _VoterChecklistState();
}

class _VoterChecklistState extends State<VoterChecklist> {
  final box = GetStorage();
  late List<Map<String, dynamic>> _checklist;

  @override
  void initState() {
    super.initState();
    _loadChecklist();
  }

  void _loadChecklist() {
    List<dynamic>? stored = box.read('voter_checklist');
    if (stored != null) {
      _checklist = List<Map<String, dynamic>>.from(stored);
    } else {
      _checklist = [
        {'title': 'National ID (NID) Card', 'done': false},
        {'title': 'Identify your Polling Station', 'done': false},
        {'title': 'Check your Serial Number', 'done': false},
        {'title': 'Know your Candidate Symbols', 'done': false},
        {'title': 'Charge your Phone (to find center)', 'done': false},
        {'title': 'Wear Comfortable Clothes', 'done': false},
      ];
    }
  }

  void _toggle(int index) {
    setState(() {
      _checklist[index]['done'] = !_checklist[index]['done'];
    });
    box.write('voter_checklist', _checklist);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 700),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.checklist, color: Colors.white, size: 24),
                    SizedBox(width: 10),
                    Text(
                      "Election Day Checklist",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Get ready for the big day! Tick off items below:",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_checklist.length, (index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween<double>(begin: 0, end: 1),
                  curve: Curves.easeOut,
                  builder: (context, double value, child) {
                    return Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: CheckboxListTile(
                    title: Text(
                      _checklist[index]['title'],
                      style: TextStyle(
                        decoration: _checklist[index]['done'] ? TextDecoration.lineThrough : null,
                        color: _checklist[index]['done'] ? Colors.grey : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _checklist[index]['done'],
                    onChanged: (_) => _toggle(index),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.blue,
                    checkColor: Colors.white,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
