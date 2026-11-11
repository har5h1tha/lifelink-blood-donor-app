import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'firebase_init.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/home/about_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/requests/post_request_screen.dart';
import 'screens/requests/request_details_screen.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/donor_viewmodel.dart';
import 'viewmodels/request_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()..init()),
        ChangeNotifierProvider(create: (_) => DonorViewModel()..startListening()),
        ChangeNotifierProvider(create: (_) => RequestViewModel()..startListening()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const LifeLinkApp(),
    ),
  );
}

class LifeLinkApp extends StatelessWidget {
  const LifeLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeViewModel>().isDarkMode;
    return MaterialApp(
      title: 'LifeLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.postRequest: (_) => const PostRequestScreen(),
        AppRoutes.requestDetails: (_) => const RequestDetailsScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
      },
    );
  }
}
