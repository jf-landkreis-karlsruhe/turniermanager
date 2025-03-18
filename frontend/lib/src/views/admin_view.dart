import 'package:flutter/material.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  static const routeName = '/admin';
  final double _headerFontSize = 26;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Center(
          child: Text(
            'Admin',
            style: TextStyle(fontSize: _headerFontSize),
          ),
        ),
        leadingWidth: 100,
      ),
      body: Placeholder(),
    );
  }
}
