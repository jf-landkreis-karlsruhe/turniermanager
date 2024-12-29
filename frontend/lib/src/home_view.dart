import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
  });

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Turniermanager',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        leadingWidth: 80,
      ),
      body: const MainContentView(),
    );
  }
}

class MainContentView extends StatelessWidget with WatchItMixin {
  const MainContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Turniermanager"),
    );
  }
}
