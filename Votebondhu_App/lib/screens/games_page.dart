import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/games_controller.dart';
import 'package:test_app/screens/quiz_page.dart';
import 'package:test_app/screens/game_ballot_collector.dart';
import 'package:test_app/screens/game_memory_match.dart';
import 'package:test_app/screens/game_wheel_fortune.dart';
import 'package:test_app/screens/game_whack_ballot.dart';
import 'package:test_app/screens/redemption_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GamesController controller = Get.find<GamesController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Games & Quiz',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Premium Points Summary with Glassmorphism
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your Election Points',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        '${controller.userPoints.value}',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      )),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(() => const RedemptionPage()),
                        icon: const Icon(Icons.redeem),
                        label: Text(
                          'Redeem Rewards',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'New & Interactive',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  Icons.slow_motion_video,
                  'Wheel of Fortune',
                  'Spin to win up to 200 points!',
                  Colors.amber,
                  () => Get.to(() => const WheelOfFortunePage()),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  Icons.touch_app,
                  'Whack-a-Ballot',
                  'Fast tapping game! 5 pts per whack.',
                  Colors.brown,
                  () => Get.to(() => const WhackABallotPage()),
                ),
                const SizedBox(height: 24),
                Text(
                  'Classics',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  Icons.quiz,
                  'Election Trivia',
                  'Earn points by learning!',
                  Colors.purple,
                  () => Get.to(() => const QuizPage()),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  Icons.catching_pokemon,
                  'Ballot Collector',
                  'Catch falling ballots.',
                  Colors.orange,
                  () => Get.to(() => const BallotCollectorPage()),
                ),
                const SizedBox(height: 12),
                _buildGameCard(
                  Icons.grid_view,
                  'Symbol Memory Match',
                  'Test your memory.',
                  Colors.blue,
                  () => Get.to(() => const MemoryMatchPage()),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(IconData icon, String title, String desc, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
