import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:stocksync/firebase_options.dart';
import 'package:stocksync/screen/login_screen.dart';



void main() async {
  Gemini.init(
      apiKey: const String.fromEnvironment('AIzaSyAhf64wrUm9YVOmm3XRamAfDrs1ZEIpfLE'), enableDebugging: true);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Labor Management System',
      home: RegisterScreen(),
    );
  }
}
