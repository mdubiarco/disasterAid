import 'package:flutter/material.dart';
import 'main.dart';

class NearbyHelpPage extends StatelessWidget {
  const NearbyHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Routes')),
      body: const Center(child: Text('Safety Routes Content')),
    );
  }
}