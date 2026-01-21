import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/auth_controller.dart';

class SignupPage extends StatelessWidget {
  final AuthController authController = Get.find();

  SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: authController.usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
              style: const TextStyle(color: Colors.black),
            ),
            TextField(
              controller: authController.passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              style: const TextStyle(color: Colors.black),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authController.signup,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
