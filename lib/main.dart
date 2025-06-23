import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:music_room/presentation/HomePage/home_screen.dart';
import 'package:music_room/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

void main() async {
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://wszqcqrmbdvwhrncsqsi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndzenFjcXJtYmR2d2hybmNzcXNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2MjEwOTEsImV4cCI6MjA2NjE5NzA5MX0.DNX6_M-t_h75DqJZnI5V3Z2H7kT4Lpl9uJarb1eUZNw',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashScreen(),
    );
  }
}
