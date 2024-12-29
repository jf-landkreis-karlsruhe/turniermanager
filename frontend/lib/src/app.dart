import 'package:flutter/material.dart';
import 'package:tournament_manager/src/views/overview.dart';
import 'home_view.dart';

/// The Widget that configures your application.
class MainWidget extends StatelessWidget {
  const MainWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',
      title: "Turniermanager",
      theme: ThemeData.dark(),
      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute<void>(
          settings: routeSettings,
          builder: (BuildContext context) {
            switch (routeSettings.name) {
              case Overview.routeName:
                return const Overview();
              case HomeView.routeName:
              default:
                return const HomeView();
            }
          },
        );
      },
    );
  }
}
