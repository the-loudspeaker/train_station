import 'package:flutter/material.dart';
import 'package:train_station/widgets/start_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Train Station Simulator',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: StartPage(),
    );
  }
}