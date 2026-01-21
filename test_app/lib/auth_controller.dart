import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_app/db_helper.dart';

class AuthController extends GetxController {
  var usernameCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();

  Future<void> login() async {
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }
    var user = await DBHelper.login(usernameCtrl.text, passwordCtrl.text);
    if (user != null) {
      Get.offAllNamed('/home', arguments: user);
      Get.snackbar('Success', 'Logged in successfully');
    } else {
      Get.snackbar('Error', 'Invalid credentials');
    }
  }

  Future<void> signup() async {
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all fields');
      return;
    }
    await DBHelper.signup(usernameCtrl.text, passwordCtrl.text);
    Get.back(); // Go back to login
    Get.snackbar('Success', 'Account created');
  }
}
