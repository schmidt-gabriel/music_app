import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization/app_localizations.dart';
import 'views/album_view.dart';
import 'views/albums_view.dart';
import 'views/artist_view.dart';
import 'views/handle_album.dart';
import 'views/auth_view.dart';
import 'views/totals_view.dart';
import 'settings/settings_controller.dart';
import 'views/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.white,
            hintColor: Colors.black,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.black26,
            hintColor: Colors.white,
          ),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                final arguments = routeSettings.arguments;
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: settingsController);
                  case AlbumsItemDetailsView.routeName:
                    return AlbumsItemDetailsView(
                        artist: arguments!, controller: settingsController);
                  case AlbumItemDetailsView.routeName:
                    return AlbumItemDetailsView(album: arguments!);
                  case HandleAlbumView.routeName:
                    return HandleAlbumView(album: arguments!);
                  case TotalsView.routeName:
                    return const TotalsView();
                  case ArtistListView.routeName:
                    return const ArtistListView();
                  case AuthView.routeName:
                  default:
                    return const ArtistListView();
                  // return settingsController.user == null
                  //     ? AuthView(
                  //         controller: settingsController,
                  //       )
                  //     : const ArtistListView();
                }
              },
            );
          },
        );
      },
    );
  }
}
