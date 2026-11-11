import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/routes.dart';
import '../../viewmodels/auth_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    final auth = context.read<AuthViewModel>();
    // Wait for BOTH: at least 2 seconds of splash, and the login check to finish.
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      auth.ready,
    ]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      auth.isLoggedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bloodtype, size: 96, color: onPrimary),
            const SizedBox(height: AppSizes.padding),
            Text(
              'LifeLink',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: onPrimary),
            ),
            const SizedBox(height: AppSizes.gap),
            Text('Every drop counts', style: TextStyle(fontSize: 14, color: onPrimary)),
          ],
        ),
      ),
    );
  }
}
