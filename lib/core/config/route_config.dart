import 'package:flutter/material.dart';
import '../../features/auth/auth.dart';
import '../../features/dashboard/dashboard.dart';
import '../../features/learning/learning.dart';
import '../../features/collaboration/collaboration.dart';
import '../../features/assessment/assessment.dart';
import '../constants/app_constants.dart';

class RouteConfig {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeHome:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
        
      case AppConstants.routeAuth:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
        
      case AppConstants.routeDashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
        
      case AppConstants.routeCollaboration:
        return MaterialPageRoute(
          builder: (_) => const CollaborativeSessionsScreen(),
        );
        
      case AppConstants.routeAssessment:
        return MaterialPageRoute(
          builder: (_) => const SkillAssessmentScreen(),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
  
  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }
  
  static void navigateAndClear(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
  
  static Future<T?> navigateForResult<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }
} 