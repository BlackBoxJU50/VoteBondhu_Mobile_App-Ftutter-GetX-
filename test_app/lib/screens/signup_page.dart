import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/utils/bangladesh_data.dart';
import 'dart:ui';

class SignupPage extends StatelessWidget {
  final AuthController authController = Get.find();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.green.shade500, Colors.white],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          
          _buildAnimatedCircle(top: -100, right: -50, size: 250, color: Colors.green.shade700),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 30),

                  // Glass Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: Column(
                          children: [
                            _buildAnimatedInput(index: 1, child: TextField(controller: authController.usernameCtrl, decoration: _buildInputDecoration('Username', Icons.person))),
                            const SizedBox(height: 15),
                            _buildAnimatedInput(index: 2, child: TextField(controller: authController.emailCtrl, decoration: _buildInputDecoration('Email Address', Icons.email))),
                            const SizedBox(height: 15),
                            Obx(() => _buildAnimatedInput(
                              index: 3, 
                              child: TextField(
                                controller: authController.passwordCtrl,
                                decoration: _buildInputDecoration('Password', Icons.lock).copyWith(
                                  suffixIcon: IconButton(
                                    icon: Icon(authController.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off, color: Colors.green),
                                    onPressed: authController.togglePasswordVisibility,
                                  ),
                                ),
                                obscureText: !authController.isPasswordVisible.value,
                              ),
                            )),
                            const SizedBox(height: 15),
                            _buildAnimatedInput(
                              index: 4,
                              child: TextField(
                                controller: authController.dobCtrl,
                                readOnly: true,
                                decoration: _buildInputDecoration('Date of Birth', Icons.calendar_today),
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now()
                                  );
                                  if(pickedDate != null) authController.dobCtrl.text = "${pickedDate.toLocal()}".split(' ')[0];
                                },
                              ),
                            ),
                            const SizedBox(height: 15),
                            
                            // Autocomplete for Area
                            _buildAnimatedInput(index: 5, child: _buildAreaSelection(context)),
                            const SizedBox(height: 15),
                            
                            // Autocomplete for Seat
                            _buildAnimatedInput(index: 6, child: _buildAshonSelection(context)),
                            
                            const SizedBox(height: 30),
                            
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: authController.signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                child: const Text('CREATE ACCOUNT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.green.shade700, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.green, size: 20),
      filled: true,
      fillColor: Colors.white70,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
    );
  }

  Widget _buildAreaSelection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          optionsBuilder: (value) => value.text.isEmpty ? const Iterable<String>.empty() : BangladeshData.areas.where((e) => e.toLowerCase().contains(value.text.toLowerCase())),
          onSelected: (selection) => authController.areaCtrl.text = selection,
          fieldViewBuilder: (context, ctrl, focus, onSubmitted) {
            ctrl.text = authController.areaCtrl.text; // Sync initial value
            return TextField(
              controller: ctrl, focusNode: focus,
              onChanged: (v) => authController.areaCtrl.text = v,
              decoration: _buildInputDecoration('Area / Thana', Icons.map),
            );
          },
        );
      },
    );
  }

  Widget _buildAshonSelection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<String>(
          optionsBuilder: (value) => value.text.isEmpty ? const Iterable<String>.empty() : BangladeshData.ashons.where((e) => e.toLowerCase().contains(value.text.toLowerCase())),
          onSelected: (selection) => authController.ashonCtrl.text = selection,
          fieldViewBuilder: (context, ctrl, focus, onSubmitted) {
            ctrl.text = authController.ashonCtrl.text; // Sync initial value
            return TextField(
              controller: ctrl, focusNode: focus,
              onChanged: (v) => authController.ashonCtrl.text = v,
              decoration: _buildInputDecoration('Ashon (Seat) Name', Icons.location_city),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimatedCircle({double? top, double? left, double? right, double? bottom, required double size, required Color color}) {
    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildAnimatedInput({required int index, required Widget child}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(offset: Offset(30 * (1 - value), 0), child: Opacity(opacity: value, child: child));
      },
      child: child,
    );
  }
}
