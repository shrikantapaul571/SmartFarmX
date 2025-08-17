import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'dashboard_screen.dart';
import 'add_farm_screen.dart';
import 'edit_sensor_screen.dart';
import 'farm_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Check if a user is already logged in
  final User? currentUser = FirebaseAuth.instance.currentUser;

  runApp(SmartFarmX(isLoggedIn: currentUser != null));
}

class SmartFarmX extends StatelessWidget {
  final bool isLoggedIn;

  const SmartFarmX({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Monitoring',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/add-farm': (context) => const AddFarmScreen(),
        '/edit-sensors': (context) => const EditSensorScreen(),
        '/farm-details': (context) => const FarmDetailsScreen(),
        '/profile': (context) => const ProfileScreen(), // ✅ new
        '/notifications': (context) => const NotificationScreen(), // ✅ new
      },
    );
  }
}
