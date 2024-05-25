import 'package:demo_project1/firebase_options.dart';
import 'package:demo_project1/home_screen.dart';
import 'package:demo_project1/views/authentication/email_login_screen.dart';
import 'package:demo_project1/views/authentication/email_register_screen.dart';
import 'package:demo_project1/views/location/provider/location_provider.dart';
import 'package:demo_project1/views/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: "OpenSans",
            fontSize: 13,
          ),
        ),
      ),
      title: 'EasyTransit App',
      initialRoute: '/',
      routes: {
        // ignore: prefer_const_constructors
        '/': (context) => SplashScreen(),
        '/home': (context) => const HomeScreen(), // Update to LoginPage
        '/welcome': (context) => const Welcome(), // Add the welcome route
        '/email-signup': (context) => const EmailRegisterScreen(),
        '/email-login': (context) => const EmailLoginScreen(),

        // '/otp': (context) => const OtpScreen(), // Update to LoginPage

        // Add routes for other pages here
      },
    );
  }
}
