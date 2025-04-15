import 'package:flutter/material.dart';
import 'dart:io';
import 'package:hive/hive.dart';

import 'SurvivalGuidePage.dart';
import 'Checklist.dart';
import 'Safety_Routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use a temp directory 
  final directory = Directory.systemTemp.createTempSync();
  Hive.init(directory.path);

  // Open the checklist Hive box
  await Hive.openBox('checklistBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DisasterAid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the entire background color to blue
      backgroundColor: Colors.blue,
      
      appBar: AppBar(
        backgroundColor: Colors.blue.shade500, 
        automaticallyImplyLeading: false, 
      ),
  
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ 
            // "Get Prepared" box 
            _buildGetPreparedBox(),
            SizedBox(height: 30),
            // Buttons for Survival Guide, Emergency Checklist & Saftey Routes
            _buildButton(context, 'Survival Guide', const LocationPage()),
            SizedBox(height: 20), 
            _buildButton(context, 'Emergency Checklist', const ListPage()),
            SizedBox(height: 20), 
            _buildButton(context, 'Safety Routes', const NearbyHelpPage()),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  
  Widget _buildButton(BuildContext context, String label, Widget information_page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => information_page), 
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.blue.shade50, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), 
        ),
        side: BorderSide(color: Colors.blue, width: 2), 
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
   // Widget for the "Get Prepared" box
  Widget _buildGetPreparedBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.medical_services, // First aid kit icon
            size: 40,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 10),
          Text(
            'Get Prepared',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
        ],
      ),
    );
  }
}