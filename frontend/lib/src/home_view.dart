import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tournament_manager/src/link_overview.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  static const routeName = '/';

  final tournamentIdController = TextEditingController(text: '1');

  void navigateToLinkOverview(BuildContext context) {
    context.go(
      Uri(
        path: LinkOverview.routeName,
        queryParameters: {
          LinkOverview.tournamentIdParam: tournamentIdController.text
        },
      ).toString(),
    );
  }

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
      body: Center(
        child: KeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKeyEvent: (value) {
            if (value.logicalKey != LogicalKeyboardKey.enter) {
              return;
            }

            navigateToLinkOverview(context);
          },
          child: Card(
            margin: const EdgeInsets.all(10),
            child: SizedBox(
              height: 140,
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Turnier laden',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tournamentIdController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              label: Text('Turnier ID'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            navigateToLinkOverview(context);
                          },
                          icon: const Icon(Icons.double_arrow),
                          iconSize: 40,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         ElevatedButton(
        //           onPressed: () {
        //             context.go(LinkOverview.routeName);
        //           },
        //           child: const Text('Turnier laden'),
        //         ),
        //         const SizedBox(width: 10),
        //         SizedBox(
        //           width: 200,
        //           child: TextField(
        //             controller: tournamentIdController,
        //             textAlign: TextAlign.center,
        //             decoration: const InputDecoration(
        //               label: Text('Turnier ID'),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
