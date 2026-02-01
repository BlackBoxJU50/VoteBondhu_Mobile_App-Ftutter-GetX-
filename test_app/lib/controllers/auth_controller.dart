import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:test_app/utils/custom_toast.dart';
import 'package:test_app/models/user_model.dart';

class AuthController extends GetxController {
  final box = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  FirebaseAuth get auth => _auth;
  
  var isGuest = false.obs;
  var isAuthenticated = false.obs;
  var currentUserModel = Rxn<UserModel>();
  StreamSubscription<DocumentSnapshot>? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes to start/stop profile listener
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _startProfileListener(user.uid);
      } else {
        _profileSubscription?.cancel();
        currentUserModel.value = null;
      }
    });
  }

  void _startProfileListener(String uid) {
    _profileSubscription?.cancel();
    _profileSubscription = _firestore.collection('users').doc(uid).snapshots().listen((doc) {
      if (doc.exists) {
        currentUserModel.value = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        print('Profile Listener: Updated for $uid. Points: ${currentUserModel.value?.points}');
      }
    });
  }

  var usernameCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var passwordCtrl = TextEditingController();
  var dobCtrl = TextEditingController();
  var areaCtrl = TextEditingController();
  var ashonCtrl = TextEditingController();
  
  var isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void checkAuth() async {
    // Removed artificial delay
    
    
    User? currentUser = _auth.currentUser;
    bool? guestMode = box.read('is_guest');

    if (currentUser != null) {
       isGuest.value = false;
       isAuthenticated.value = true;
       _startProfileListener(currentUser.uid);
       Get.offAllNamed('/home');
    } else if (guestMode == true) {
       isGuest.value = true;
       isAuthenticated.value = true;
       Get.offAllNamed('/home');
    } else {
       Get.offAllNamed('/login');
    }
  }

  // New Profile Fields
  var workCtrl = TextEditingController();
  var educationCtrl = TextEditingController();

  Future<void> login() async {
    if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      CustomToast.showError('Please fill all fields');
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        box.write('is_guest', false);
        box.write('id', user.uid); // Persist ID
        isGuest.value = false;
        isAuthenticated.value = true;
        _startProfileListener(user.uid);
        Get.offAllNamed('/home');
        CustomToast.showSuccess('Logged in successfully');
      }
    } on FirebaseAuthException catch (e) {
      CustomToast.showError(e.message ?? 'Login failed');
    } catch (e) {
      print('Login general error: $e');
      CustomToast.showError('Login failed: ${e.toString()}');
    }
  }

  Future<void> signup() async {
     if (usernameCtrl.text.isEmpty || emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty || 
         dobCtrl.text.isEmpty || areaCtrl.text.isEmpty || ashonCtrl.text.isEmpty) {
      CustomToast.showError('Please fill all fields');
      return;
    }

    String email = emailCtrl.text.trim();
    if (!email.toLowerCase().endsWith('@gmail.com')) {
      CustomToast.showError('Registration allowed only with @gmail.com');
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: passwordCtrl.text.trim(),
      );
      
      User? user = userCredential.user;
      if (user != null) {
         try {
           await _firestore.collection('users').doc(user.uid).set({
             'username': usernameCtrl.text.trim(),
             'email': user.email,
             'role': 'voter',
             'dob': dobCtrl.text.trim(),
             'area': areaCtrl.text.trim(),
             'ashon': ashonCtrl.text.trim(),
             'createdAt': FieldValue.serverTimestamp(),
             'points': 0,
             'work': '',
             'education': '',
           }).timeout(const Duration(seconds: 5));
         } catch (firestoreError) {
           print('Firestore write failed: $firestoreError');
         }

         usernameCtrl.clear();
         emailCtrl.clear();
         passwordCtrl.clear();
         dobCtrl.clear();
         areaCtrl.clear();
         ashonCtrl.clear();
         // Auto-login or redirect to login
         await _auth.signOut(); 
         Get.offAllNamed('/login');
         
         Future.delayed(const Duration(milliseconds: 500), () {
            CustomToast.showSuccess('Account created! Please login.');
         });
      }
    } on FirebaseAuthException catch (e) {
      CustomToast.showError(e.message ?? 'Signup failed');
    } catch (e) {
      print('Signup error: $e');
      CustomToast.showError('Something went wrong. Please check your connection.');
    }
  }

  void loginAsGuest() {
    box.write('is_guest', true);
    isGuest.value = true;
    isAuthenticated.value = true;
    currentUserModel.value = null; // Clear if any
    Get.offAllNamed('/home');
    CustomToast.showInfo('Welcome Guest!');
  }

  Future<void> logout() async {
    _profileSubscription?.cancel();
    await _auth.signOut();
    box.erase();
    isGuest.value = false;
    isAuthenticated.value = false;
    currentUserModel.value = null;
    Get.offAllNamed('/login');
  }

  void selectAvatar(bool isMale) async {
    if (currentUserModel.value == null) return;
    
    // Using local assets path as string
    String assetPath = isMale 
        ? 'assets/images/male_avatar.png' 
        : 'assets/images/female_avatar.png';

    try {
      await _firestore.collection('users').doc(currentUserModel.value!.uid).update({
        'profileImageUrl': assetPath,
      });
      CustomToast.showSuccess('Avatar updated!');
    } catch (e) {
      CustomToast.showError('Failed to update avatar');
    }
  }

  Future<void> updateProfileInfo(String work, String education) async {
    if (currentUserModel.value == null) return;
    try {
      await _firestore.collection('users').doc(currentUserModel.value!.uid).update({
        'work': work,
        'education': education,
      });
      CustomToast.showSuccess('Profile updated!');
    } catch (e) {
      CustomToast.showError('Failed to update profile');
    }
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }
}
