import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:test_app/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Get.toNamed('/admin'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: authController.usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
              style: const TextStyle(color: Colors.black),
              autofocus: true,
            ),
            TextField(
              controller: authController.passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              style: const TextStyle(color: Colors.black),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authController.login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/signup'),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
