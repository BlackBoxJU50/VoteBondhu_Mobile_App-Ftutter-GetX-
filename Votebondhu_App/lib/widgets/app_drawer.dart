import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/controllers/home_controller.dart';
import 'package:test_app/screens/bondhu_list_page.dart';
import 'dart:ui';
import 'package:test_app/widgets/animated_title.dart';
import 'package:test_app/utils/image_utils.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final HomeController homeController = Get.find();

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        children: [
          // Glass Background
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade900.withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Obx(() {
              final isGuest = authController.isGuest.value;
              final user = authController.currentUserModel.value;

              return Column(
                children: [
                  // Extraordinary Header
                  Container(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white24,
                            backgroundImage: ImageUtils.getProfileImage(user?.profileImageUrl),
                            child: user?.profileImageUrl == null ? const Icon(Icons.person, color: Colors.white, size: 45) : null,
                          ),
                        ),
                        const SizedBox(height: 15),
                        AnimatedTitle(
                          text: isGuest ? 'GUEST VOTER' : (user?.username ?? 'Voter').toUpperCase(),
                          fontSize: 20,
                        ),
                        if (!isGuest)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('GOLD CITIZEN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
                          ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white24, indent: 30, endIndent: 30),

                  // Menu Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      children: [
                         _buildDrawerItem(Icons.home, 'Home Dashboard', () {
                           Get.back();
                           homeController.changeTabIndex(0);
                         }),
                         if (!isGuest) _buildDrawerItem(Icons.person, 'My Profile', () {
                           Get.back();
                           Get.toNamed('/profile');
                         }),
                         _buildDrawerItem(Icons.people, 'Voter Community', () {
                           Get.back();
                           homeController.changeTabIndex(1);
                         }),
                         if (!isGuest) _buildDrawerItem(Icons.group_add, 'My VoteBondhus', () {
                           Get.back();
                           Get.to(() => const BondhuListPage());
                         }),
                         _buildDrawerItem(Icons.school, 'Voter Education', () {
                           Get.back();
                           homeController.changeTabIndex(2);
                         }),
                         _buildDrawerItem(Icons.newspaper, 'Election News', () {
                           Get.back();
                           homeController.changeTabIndex(3);
                         }),
                         _buildDrawerItem(Icons.search, 'Candidate List', () {
                           Get.back();
                           Get.toNamed('/candidates');
                         }),
                         if (!isGuest) _buildDrawerItem(Icons.games, 'Games & Quiz', () {
                           Get.back();
                           Get.toNamed('/games');
                         }),
                         if (!isGuest) _buildDrawerItem(Icons.emoji_emotions, 'Meme Competition', () {
                           Get.back();
                           Get.toNamed('/memes');
                         }),
                      ],
                    ),
                  ),

                  // Footer Actions
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Logout Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.logout, color: Colors.amber),
                            title: const Text(
                              'LOGOUT',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            onTap: () => authController.logout(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 26),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      hoverColor: Colors.white10,
    );
  }
}
