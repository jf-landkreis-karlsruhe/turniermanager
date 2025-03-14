import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/manager/game_manager.dart';
import 'package:tournament_manager/src/model/age_group.dart';
import 'package:tournament_manager/src/views/referee_view.dart';
import 'package:tournament_manager/src/views/results_view.dart';
import 'package:tournament_manager/src/views/schedule_view.dart';
import 'package:watch_it/watch_it.dart';

class LinkOverview extends StatelessWidget {
  const LinkOverview({super.key});

  static const routeName = '/tournament';

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
    var ageGroups =
        watchPropertyValue((GameManager manager) => manager.ageGroups);

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
                  const Text(
                    'Spielplan & Ergebnisse',
                    style: TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var ageGroup = ageGroups[index];

                        return ScheduleAndResultsLinkView(ageGroup: ageGroup);
                      },
                      itemCount: ageGroups.length,
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
                  child: LinkView(
                    header: 'Spielleiter',
                    onPressed: () {
                      context.go(".${Uri(path: RefereeView.routeName)}");
                    },
                  ),
                ),
                Expanded(
                  child: LinkView(
                    header: 'Admin',
                    onPressed: () {},
                  ),
                ),
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
    required this.header,
    required this.onPressed,
  });

  final String header;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.blue)),
                  onPressed: onPressed,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.double_arrow,
                        color: Colors.white,
                        size: 100,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Link folgen',
                        style: TextStyle(
                          fontSize: 44,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.double_arrow,
                        color: Colors.white,
                        size: 100,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleAndResultsLinkView extends StatelessWidget {
  const ScheduleAndResultsLinkView({
    super.key,
    required this.ageGroup,
  });

  final AgeGroup ageGroup;

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
                ageGroup.name,
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
                      onPressed: () {
                        context.go(
                          ".${Uri(
                            path: ScheduleView.routeName,
                            queryParameters: {
                              ScheduleView.ageGroupQueryParam: ageGroup.name
                            },
                          )}",
                        );
                      },
                      child: const Text('Spielübersicht'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(
                          ".${Uri(
                            path: ResultsView.routeName,
                            queryParameters: {
                              ResultsView.ageGroupQueryParam: ageGroup.name
                            },
                          )}",
                        );
                      },
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
