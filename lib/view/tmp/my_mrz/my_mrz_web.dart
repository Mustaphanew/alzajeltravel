
import 'package:flutter/material.dart';

class MyMrzPage extends StatefulWidget {
  const MyMrzPage({super.key});

  @override
  State<MyMrzPage> createState() => _MyMrzPageState();
}

class _MyMrzPageState extends State<MyMrzPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Mrz'),
      ),
      body: const Center(
        child: Text('My Mrz'),
      ),
    );
  }
}
