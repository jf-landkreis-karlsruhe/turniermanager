import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/home_view.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/views/referee_view.dart';
import 'package:tournament_manager/src/views/results_view.dart';
import 'package:tournament_manager/src/views/schedule_view.dart';
import 'package:watch_it/watch_it.dart';
import 'link_overview.dart';

/// The Widget that configures your application.
class MainWidget extends StatelessWidget {
  MainWidget({
    super.key,
  });

  final _router = GoRouter(
    routes: [
      GoRoute(
        path: HomeView.routeName,
        builder: (context, state) => HomeView(),
      ),
      GoRoute(
        path: "${LinkOverview.routeName}:${LinkOverview.tournamentIdParam}",
        builder: (context, state) {
          var tournamentIdParam =
              state.pathParameters[LinkOverview.tournamentIdParam] ?? "1";

          var tournamentId = int.tryParse(tournamentIdParam) ?? 1;

          return LinkOverview(tournamentId: tournamentId);
        },
        routes: [
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
          GoRoute(
            path: ResultsView.routeName,
            builder: (context, state) {
              var ageGroup =
                  state.uri.queryParameters[ResultsView.ageGroupQueryParam] ??
                      "1";

              final GameManager gameManager = di<GameManager>();
              gameManager.getResultsCommand(ageGroup);

              return ResultsView(ageGroup);
            },
          ),
          GoRoute(
            path: RefereeView.routeName,
            builder: (context, state) => const RefereeView(),
          ),
        ],
      ),
    ],
  );

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
      routerConfig: _router,
    );
  }
}
