import 'package:flutter/material.dart';
import 'package:hyper_app/screens/bp_history_screen.dart';
import 'package:hyper_app/screens/bp_input_screen.dart';
import 'package:hyper_app/screens/home_screen.dart';
import 'package:hyper_app/screens/medication_screen.dart';
import 'package:hyper_app/screens/results_screen.dart';
import 'package:hyper_app/screens/settings_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => HomeScreen(),
    '/bp_input': (context) => BPInputScreen(),
    // '/result': (context) => ResultScreen(),
    // '/medications': (context) => MedicationScreen(),
    '/bp_history': (context) => BPHistoryScreen(),
    '/settings': (context) => SettingsScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/result':
        // Extracting arguments passed during navigation
        final args = settings.arguments as Map<String, dynamic>?;

        if (args != null) {
          final systolic = args['systolic'];
          final diastolic = args['diastolic'];
          return MaterialPageRoute(
            builder: (context) => ResultScreen(
              systolic: systolic,
              diastolic: diastolic,
            ),
          );
        }
        return _errorRoute();

      case '/medications':
        // Extracting arguments passed during navigation
        final args = settings.arguments as Map<String, dynamic>?;

        if (args != null) {
          final classification = args['classification'];
          final classificationColor = args['classificationColor'];

          return MaterialPageRoute(
            builder: (context) => MedicationLifestyleScreen(
              classification: classification,
              classificationColor: classificationColor,
            ),
          );
        }
        return _errorRoute();

      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('Route not found!'),
        ),
      ),
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => const Scaffold(
        body: Center(
          child: Text('Error: Missing or incorrect arguments!'),
        ),
      ),
    );
  }
}
