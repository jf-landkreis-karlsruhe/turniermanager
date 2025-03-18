import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/home_view.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/views/admin_view.dart';
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
    initialLocation: LinkOverview.routeName,
    routes: [
      GoRoute(
        // TODO: Home view is left in for now. Future features to load different tournaments might need this
        path: HomeView.routeName,
        builder: (context, state) => HomeView(),
      ),
      GoRoute(
        path: LinkOverview.routeName,
        builder: (context, state) {
          final GameManager gameManager = di<GameManager>();
          gameManager.getAgeGroupsCommand();

          return const LinkOverview();
        },
        routes: [
          GoRoute(
            path: ScheduleView.routeName,
            builder: (context, state) {
              var ageGroupParam =
                  state.uri.queryParameters[ScheduleView.ageGroupQueryParam] ??
                      "Altersklasse ??";

              final GameManager gameManager = di<GameManager>();
              var ageGroup = gameManager.getAgeGroupByName(ageGroupParam);

              if (ageGroup == null) {
                return Center(
                  child: Text('Altersklasse "$ageGroupParam" nicht vorhanden!'),
                );
              }

              gameManager.getScheduleCommand(ageGroup.id);

              return ScheduleView(ageGroup);
            },
          ),
          GoRoute(
            path: ResultsView.routeName,
            builder: (context, state) {
              var ageGroupParam =
                  state.uri.queryParameters[ResultsView.ageGroupQueryParam] ??
                      "Altersklasse ??";

              final GameManager gameManager = di<GameManager>();
              var ageGroup = gameManager.getAgeGroupByName(ageGroupParam);

              if (ageGroup == null) {
                return Center(
                  child: Text('Altersklasse "$ageGroupParam" nicht vorhanden!'),
                );
              }

              gameManager.getResultsCommand(ageGroup.id);

              return ResultsView(ageGroup);
            },
          ),
          GoRoute(
            path: RefereeView.routeName,
            builder: (context, state) {
              final GameManager gameManager = di<GameManager>();
              gameManager.getCurrentRoundCommand();

              return const RefereeView();
            },
          ),
          GoRoute(
            path: AdminView.routeName,
            builder: (context, state) {
              return const AdminView();
            },
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
