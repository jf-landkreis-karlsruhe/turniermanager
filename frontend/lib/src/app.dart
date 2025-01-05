import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/views/schedule_view.dart';
import 'package:watch_it/watch_it.dart';
import 'home_view.dart';

/// The Widget that configures your application.
class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',
      title: "Turniermanager",
      theme: ThemeData.dark(),
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: HomeView.routeName,
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: ScheduleView.routeName,
            builder: (context, state) {
              var ageGroup =
                  state.uri.queryParameters[ScheduleView.ageGroupQueryParam] ??
                      "1";

              final GameManager gameManager = di<GameManager>();
              gameManager.getScheduleCommand(ageGroup);

              return ScheduleView(ageGroup);
            },
          ),
        ],
      ),
    );
  }
}
