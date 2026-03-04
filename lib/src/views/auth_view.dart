import 'package:flutter/material.dart';

import '../settings/settings_controller.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key, required this.controller});

  final SettingsController controller;

  static const routeName = '/';

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Music',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Collection',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                Icons.person,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            isLoading && !widget.controller.userIssue
                ? const CircularProgressIndicator()
                : OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                    onPressed: () {
                      // widget.controller.updateUser();
                      setState(() {
                        isLoading = true;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(
                            image: AssetImage("assets/images/google_logo.png"),
                            height: 35.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            widget.controller.userIssue
                ? const AlertDialog(
                    title: Text('Falha na autenticação'),
                    content: Text(
                        'Houve um problema ao tentar autenticar o usuário. Tente novamente.'),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
