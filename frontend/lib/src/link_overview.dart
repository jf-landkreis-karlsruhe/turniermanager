import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/views/referee_view.dart';
import 'package:tournament_manager/src/views/results_view.dart';
import 'package:tournament_manager/src/views/schedule_view.dart';
import 'package:watch_it/watch_it.dart';

class LinkOverview extends StatelessWidget {
  const LinkOverview({
    super.key,
    required this.tournamentId,
  });

  final int tournamentId;

  static const routeName = '/tournament';
  static const tournamentIdParam = 'id';

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
      body: const LinkContentView(),
    );
  }
}

class LinkContentView extends StatelessWidget with WatchItMixin {
  const LinkContentView({super.key});

  @override
  Widget build(BuildContext context) {
    var tournament =
        watchPropertyValue((GameManager manager) => manager.tournament);

    if (tournament == null) {
      return const Center(
        child: Text(
          'Turnierdaten nicht geladen!',
          style: TextStyle(
            fontSize: 24,
            color: Colors.red,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Spielplan & Ergebnisse'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var ageGroup = tournament.ageGroups[index];

                        return LinkView(ageGroup: ageGroup);
                      },
                      itemCount: tournament.ageGroups.length,
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    child: Card(
                  child: Placeholder(),
                )),
                Expanded(
                    child: Card(
                  child: Placeholder(),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LinkView extends StatelessWidget {
  const LinkView({
    super.key,
    required this.ageGroup,
  });

  final int ageGroup;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 495,
      child: Card(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                'Altersgruppe $ageGroup',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                  child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Spielübersicht'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Ergebnisse'),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class MainContentView extends StatelessWidget with WatchItMixin {
  MainContentView({super.key});

  final scheduleAgeGroupTextController = TextEditingController(text: '1');
  final resultsAgeGroupTextController = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: scheduleAgeGroupTextController,
                      textAlign: TextAlign.center,
                      decoration:
                          const InputDecoration(label: Text('Altersklasse')),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(
                          ".${Uri(
                            path: ScheduleView.routeName,
                            queryParameters: {
                              ScheduleView.ageGroupQueryParam:
                                  scheduleAgeGroupTextController.text
                            },
                          )}",
                        );
                      },
                      label: const Text("Spielplan"),
                      icon: const Icon(Icons.view_list),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: resultsAgeGroupTextController,
                      textAlign: TextAlign.center,
                      decoration:
                          const InputDecoration(label: Text('Altersklasse')),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go(
                          ".${Uri(
                            path: ResultsView.routeName,
                            queryParameters: {
                              ResultsView.ageGroupQueryParam:
                                  resultsAgeGroupTextController.text
                            },
                          )}",
                        );
                      },
                      label: const Text("Ergebnisse"),
                      icon: const Icon(Icons.view_list),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              context.go(".${Uri(path: RefereeView.routeName)}");
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
