import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/traveler/traveler_home.dart';
import 'screens/organizer/organizer_home.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..init(),
      child: MaterialApp(
        title: 'TripMate',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final currentUser = auth.currentUser;

            if (auth.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (currentUser != null) {
              return currentUser.role == 'organizer'
                  ? OrganizerHome(
                      user: currentUser,
                      logoutCallback: () => auth.logout(),
                    )
                  : TravelerHome(
                      user: currentUser,
                      logoutCallback: () => auth.logout(),
                    );
            }

            return const SplashScreen();
          },
        ),
      ),
    );
  }
}