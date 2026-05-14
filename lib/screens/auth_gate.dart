import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'landing_screen.dart';
import 'tablero_caa_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.blue)));
        }
        if (!userProvider.isLoggedIn) {
          return const LandingScreen();
        }
        return const TableroCAAScreen();
      },
    );
  }
}