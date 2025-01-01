import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/views/schedule.dart';
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
            path: Schedule.routeName,
            builder: (context, state) {
              var ageGroup =
                  state.uri.queryParameters[Schedule.ageGroupQueryParam] ?? "1";
              var league =
                  state.uri.queryParameters[Schedule.leagueQueryParam] ?? "1";

              return Schedule(ageGroup, league);
            },
          ),
        ],
      ),
    );
  }
}
