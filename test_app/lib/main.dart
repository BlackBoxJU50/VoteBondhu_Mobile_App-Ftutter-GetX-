import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'package:test_app/screens/login_page.dart';
import 'package:test_app/screens/signup_page.dart';
import 'package:test_app/screens/home_page.dart';
import 'package:test_app/screens/splash_page.dart';
import 'package:test_app/screens/profile_page.dart';
import 'package:test_app/screens/candidate_list_page.dart';
import 'package:test_app/screens/games_page.dart';
import 'package:test_app/screens/memes_page.dart';
import 'package:test_app/controllers/auth_controller.dart';
import 'package:test_app/controllers/games_controller.dart';
import 'package:test_app/bindings/home_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FFI for desktop database support
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  await GetStorage.init();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'VoteBondhu',
      debugShowCheckedModeBanner: false,
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
        Get.put(GamesController());
      }),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/signup', page: () => SignupPage()),
        GetPage(name: '/home', page: () => HomePage(), binding: HomeBinding()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/candidates', page: () => const CandidateListPage()),
        GetPage(name: '/games', page: () => const GamesPage()),
        GetPage(name: '/memes', page: () => const MemesPage()),
      ],
    );
  }
}
