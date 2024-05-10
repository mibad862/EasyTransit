import 'package:demo_project1/firebase_options.dart';
import 'package:demo_project1/home_screen.dart';
import 'package:demo_project1/views/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EasyTransit App',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => const Welcome(),
        '/home': (context) => HomeScreen() // Update to LoginPage
        // '/otp': (context) => const OtpScreen(), // Update to LoginPage

        // Add routes for other pages here
      },
    );
  }
}
