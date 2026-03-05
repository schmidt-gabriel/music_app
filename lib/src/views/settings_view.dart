import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  Widget container(BuildContext context, Widget child) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          height: 50,
          child: child,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: 
          // controller.user == null
          // ? const SizedBox(
          //     width: 15,
          //   )
          // : 
          Padding(
              padding: const EdgeInsets.all(16),
              // Glue the SettingsController to the theme selection DropdownButton.
              //
              // When a user selects a theme from the dropdown list, the
              // SettingsController is updated, which rebuilds the MaterialApp.
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  container(
                    context,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Theme',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<ThemeMode>(
                          // Read the selected themeMode from the controller
                          value: controller.themeMode,
                          // Call the updateThemeMode method any time the user selects a theme.
                          onChanged: controller.updateThemeMode,
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System Theme'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light Theme'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark Theme'),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
