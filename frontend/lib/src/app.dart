import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/views/admin_view.dart';
import 'package:tournament_manager/src/views/age_group_view.dart';
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
              final GameManager gameManager = di<GameManager>();
              gameManager.getAgeGroupsCommand();

              var ageGroupParam =
                  state.uri.queryParameters[ScheduleView.ageGroupQueryParam] ??
                      "Altersklasse ??";

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
              final GameManager gameManager = di<GameManager>();
              gameManager.getAgeGroupsCommand();

              var ageGroupParam =
                  state.uri.queryParameters[ResultsView.ageGroupQueryParam] ??
                      "Altersklasse ??";

              gameManager.getResultsByAgeGroupNameCommand(ageGroupParam);

              return ResultsView(ageGroupParam);
            },
          ),
          GoRoute(
            path: AgeGroupView.routeName,
            builder: (context, state) {
              final GameManager gameManager = di<GameManager>();
              gameManager.getAgeGroupsCommand();

              var ageGroupParam =
                  state.uri.queryParameters[AgeGroupView.ageGroupQueryParam] ??
                      "Altersklasse ??";

              var ageGroup = gameManager.getAgeGroupByName(ageGroupParam);

              if (ageGroup == null) {
                return Center(
                  child: Text('Altersklasse "$ageGroupParam" nicht vorhanden!'),
                );
              }

              gameManager.getScheduleCommand(ageGroup.id);
              gameManager.getResultsCommand(ageGroup.id);

              return AgeGroupView(ageGroup: ageGroup);
            },
          ),
          GoRoute(
            path: RefereeView.routeName,
            builder: (context, state) {
              final GameManager gameManager = di<GameManager>();
              gameManager.getCurrentRoundCommand();

              return RefereeView();
            },
          ),
          GoRoute(
            path: AdminView.routeName,
            builder: (context, state) {
              final GameManager gameManager = di<GameManager>();
              gameManager.getAllGamesCommand();
              gameManager.getAllPitchesCommand();

              return const AdminView();
            },
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: di.allReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

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
      },
    );
  }
}
