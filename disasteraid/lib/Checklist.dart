import 'package:flutter/material.dart';
import 'main.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Checklist')),
      body: const Center(child: Text('Emergency Checklist Content')),
    );
  }
}