import 'package:flutter/material.dart';
import 'package:smart_trip_planner/screens/welcome/welcome.dart';
import 'features/trips/presentation/home_screen.dart';


class SmartTripApp extends StatelessWidget {
  const SmartTripApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Trip Planner',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const WelcomeScreen(),
    );
  }
}