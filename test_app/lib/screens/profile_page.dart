import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/utils/custom_toast.dart';
import 'package:test_app/utils/image_utils.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Get.back()),
      ),
      body: Obx(() {
        if (authController.isGuest.value) {
          return _buildGuestProfile(authController);
        }
  
        var user = authController.currentUserModel.value;
        if (user == null) return const Center(child: CircularProgressIndicator());

        return Stack(
          children: [
            // Header Gradient background
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade800, Colors.green.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  
                  // Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar area
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 3)),
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.green.shade50,
                                backgroundImage: ImageUtils.getProfileImage(user.profileImageUrl),
                                child: user.profileImageUrl == null ? const Icon(Icons.person, size: 60, color: Colors.green) : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0, right: 0,
                              child: GestureDetector(
                                onTap: () => _showAvatarSelectionDialog(context, authController),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 15),
                        Text(user.username.toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            user.role == 'admin' ? 'ADMINISTRATOR' : 'VERIFIED CITIZEN',
                            style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                        const SizedBox(height: 15),
                        OutlinedButton.icon(
                          onPressed: () => _showEditProfileDialog(context, authController, user.work, user.education),
                          icon: const Icon(Icons.edit_note),
                          label: const Text("Edit Bio"),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Info Items with Staggered animations
                  _buildProfileTile(0, Icons.email, 'Email Address', user.email),
                  _buildProfileTile(1, Icons.cake, 'Date of Birth', user.dob),
                  _buildProfileTile(2, Icons.map, 'Your Area', user.area),
                  _buildProfileTile(3, Icons.location_city, 'Voting Ashon (Seat)', user.ashon),
                  if (user.work.isNotEmpty)
                    _buildProfileTile(4, Icons.work, 'Work', user.work),
                  if (user.education.isNotEmpty)
                    _buildProfileTile(5, Icons.school, 'Education', user.education),
                  
                  const SizedBox(height: 30),

                  // Logout Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
                      child: TextButton.icon(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('LOGOUT ACCOUNT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        onPressed: () {
                           authController.logout();
                           CustomToast.showInfo('See you soon!');
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }


  void _showAvatarSelectionDialog(BuildContext context, AuthController controller) {
    Get.defaultDialog(
      title: "Choose Avatar",
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              controller.selectAvatar(true);
              Get.back();
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/male_avatar.png'),
                ),
                const SizedBox(height: 5),
                const Text("Male"),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.selectAvatar(false);
              Get.back();
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/female_avatar.png'),
                ),
                const SizedBox(height: 5),
                const Text("Female"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthController controller, String currentWork, String currentEdu) {
    final workCtrl = TextEditingController(text: currentWork);
    final eduCtrl = TextEditingController(text: currentEdu);

    Get.defaultDialog(
      title: "Update Info",
      content: Column(
        children: [
          TextField(
            controller: workCtrl,
            decoration: const InputDecoration(labelText: "Work / Profession", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: eduCtrl,
            decoration: const InputDecoration(labelText: "Education / School", border: OutlineInputBorder()),
          ),
        ],
      ),
      textConfirm: "Save",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.updateProfileInfo(workCtrl.text.trim(), eduCtrl.text.trim());
        Get.back();
      },
    );
  }

  Widget _buildProfileTile(int index, IconData icon, String title, String value) {
    return FadeInUp(
      delay: Duration(milliseconds: 200 + (index * 150)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.green, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ),
      ),
    );
  }

  Widget _buildGuestProfile(AuthController authController) {
    return Container(
      width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green.shade100, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          const Text('GUEST ACCESS', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 10),
          const Text('Sign in to access your full voter profile', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: authController.logout,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: const Text('LOGIN / SIGNUP', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Simple FadeInUp animation helper
class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  const FadeInUp({super.key, required this.child, this.delay});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay ?? Duration.zero, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.2),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        child: widget.child,
      ),
    );
  }
}
