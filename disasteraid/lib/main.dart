import 'package:flutter/material.dart';
import 'dart:io';
import 'package:hive/hive.dart';

import 'SurvivalGuidePage.dart';
import 'Checklist.dart';
import 'Safety_Routes.dart';
import 'Resources.dart';

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
      
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'data/download.jpg',  
              fit: BoxFit.cover,     
            ),
          ),
          // Main body content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                
                Padding(
                  padding: const EdgeInsets.only(top: 40), 
                  child: _buildGetPreparedBox(),
                ),
                const SizedBox(height: 30), 
                
                
                const SizedBox(height: 30), 
                
                
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.0,
                    children: <Widget>[
                      _buildButton(context, 'Survival Guide', const LocationPage()),
                      _buildButton(context, 'Emergency Checklist', const ListPage()),
                      _buildButton(context, 'Safety Routes', const NearbyHelpPage()),
                      _buildButton(context, 'Resources', const ResourcesPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  
  Widget _buildButton(BuildContext context, String label, Widget information_page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => information_page), 
        );
      },
      child: Container(
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
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


