import 'dart:async';

import 'package:flutter/material.dart';
import 'package:inshorts_v2_0/screens/homescreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'inshorts_v2_0',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "MavenPro",
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Homescreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'in',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(text: 'Shorts v2'),
                  TextSpan(
                    text: '.',
                    style: TextStyle(color: Colors.red),
                  ),
                  TextSpan(text: '0'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Hubballi',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(
                    text: 'F',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  TextSpan(text: 'resh '),
                  TextSpan(
                    text: 'n',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  TextSpan(text: 'ews '),
                  TextSpan(
                    text: 'i',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  TextSpan(text: 'n '),
                  TextSpan(
                    text: 's',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  TextSpan(text: 'hort'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
