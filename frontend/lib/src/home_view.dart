import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/views/schedule_view.dart';
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
              final GameManager gameManager = di<GameManager>();
              gameManager.getGameDataCommand(("1", "1"));

              context.go(
                Uri(
                  path: ScheduleView.routeName,
                  queryParameters: {
                    ScheduleView.ageGroupQueryParam: '1',
                    ScheduleView.leagueQueryParam: '1',
                  },
                ).toString(),
              );
            },
            label: const Text("Spielplan"),
            icon: const Icon(Icons.view_list),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              // context.go("");
            },
            label: const Text("Spielleiter"),
            icon: const Icon(Icons.sports_esports),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              // context.go("");
            },
            label: const Text("Admin"),
            icon: const Icon(Icons.admin_panel_settings),
          ),
        ],
      ),
    );
  }
}
