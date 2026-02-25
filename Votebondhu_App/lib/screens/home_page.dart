import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/home_controller.dart';
import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/widgets/daily_poll_widget.dart';
import 'package:test_app/widgets/voter_checklist.dart';
import 'package:test_app/widgets/election_countdown_widget.dart';
import 'package:test_app/widgets/voter_level_widget.dart';
import 'package:test_app/screens/community_page.dart';
import 'package:test_app/features/news/news_screen.dart' as new_news;
import 'package:test_app/features/vote_guide/vote_guide_screen.dart';
import 'package:test_app/widgets/ai_chatbot_widget.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:test_app/widgets/footer_widget.dart';
import 'package:test_app/widgets/animated_title.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const AnimatedTitle(text: 'VoteBondhu'), 
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: Obx(
        () => Stack(
          children: [
            IndexedStack(
              index: homeController.tabIndex.value,
              children: [
                _buildHomeDashboard(context),
                CommunityPage(),
                const VoteGuideStepPage(),
                const new_news.NewsPage(),
              ],
            ),
             AiChatbotWidget(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: homeController.tabIndex.value,
          onTap: homeController.changeTabIndex,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined, size: 24), activeIcon: Icon(Icons.home, size: 28), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outlined, size: 24), activeIcon: Icon(Icons.people, size: 28), label: 'Community'),
            BottomNavigationBarItem(icon: Icon(Icons.school_outlined, size: 24), activeIcon: Icon(Icons.school, size: 28), label: 'Vote Guide'),
            BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined, size: 24), activeIcon: Icon(Icons.newspaper, size: 28), label: 'News'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Extraordinary Hero Section
          Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.green.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
              ],
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
            ),
            child: Stack(
              children: [
                _buildFloatingSphere(size: 150, top: -20, left: -20, opacity: 0.1),
                _buildFloatingSphere(size: 100, bottom: 20, right: -10, opacity: 0.05),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogoPulse(),
                      const SizedBox(height: 15),
                      const Text(
                        "VOTEBONDHU",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                        child: const Text(
                          "POWERED BY THE PEOPLE",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Voter Engagement Level
          const VoterLevelWidget(),

          // Countdown Card with Gradient
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_vote, color: Colors.green.shade700, size: 28),
                        const SizedBox(width: 8),
                        const Text(
                          "Your Vote is Your Voice!",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const ElectionCountdownWidget(),
                  ],
                ),
              ),
            ),
          ),

          // Daily Pulse Poll
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DailyPollWidget(),
          ),
          const SizedBox(height: 10),

          // Voter Preparation Checklist
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: VoterChecklist(),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                _buildFeatureCard(Icons.how_to_vote, "How to Vote", () => Get.find<HomeController>().changeTabIndex(2)),
                _buildFeatureCard(Icons.search, "Candidates", () => Get.toNamed('/candidates')),
                _buildFeatureCard(Icons.poll, "Live Results", () {}),
                _buildFeatureCard(Icons.quiz, "Games & Quiz", () => Get.toNamed('/games')),
                _buildFeatureCard(Icons.emoji_emotions, "Memes", () => Get.toNamed('/memes')),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FooterWidget(),
        ],
      ),
    );
  }

  Widget _buildFloatingSphere({required double size, double? top, double? left, double? right, double? bottom, required double opacity}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size, height: size,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildLogoPulse() {
    return TweenAnimationBuilder(
      duration: const Duration(seconds: 2),
      tween: Tween<double>(begin: 0.9, end: 1.1),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Transform.scale(scale: value, child: child);
      },
      onEnd: () {}, // This triggers a loop in effect if we uses a key but we'll keep it simple for now
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
          ],
        ),
        child: const Icon(Icons.how_to_vote, color: Colors.green, size: 50),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, VoidCallback onTap) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.green.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.green.shade100,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: Colors.green.shade700),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.green.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for diamond pattern
class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        final path = Path()
          ..moveTo(x, y - 10)
          ..lineTo(x + 10, y)
          ..lineTo(x, y + 10)
          ..lineTo(x - 10, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
