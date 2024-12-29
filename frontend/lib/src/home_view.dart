import 'package:flutter/material.dart';
import 'package:tournament_manager/src/views/overview.dart';
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed(Overview.routeName);
            },
            label: const Text("Spielübersicht"),
            icon: const Icon(Icons.view_list),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed("");
            },
            label: const Text("Spielleiter"),
            icon: const Icon(Icons.sports_esports),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed("");
            },
            label: const Text("Admin"),
            icon: const Icon(Icons.admin_panel_settings),
          ),
        ],
      ),
    );
  }
}
