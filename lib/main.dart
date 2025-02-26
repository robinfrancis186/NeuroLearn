import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/config/route_config.dart';
import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'features/auth/auth.dart';
import 'features/dashboard/dashboard.dart';
import 'features/learning/learning.dart';
import 'features/collaboration/collaboration.dart';
import 'features/assessment/assessment.dart';
import 'features/dashboard/bloc/statistics_provider.dart';
import 'features/dashboard/bloc/achievement_provider.dart';
import 'shared/interfaces/tts_service_interface.dart';
import 'shared/interfaces/performance_service_interface.dart';
import 'shared/shared.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await configureDependencies();
  
  // Initialize services
  final ttsService = serviceLocator<ITTSService>();
  final performanceService = serviceLocator<IPerformanceService>();
  
  // Initialize and precache assets
  await performanceService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => CollaborativeProvider()),
        ChangeNotifierProvider(create: (_) => SkillAssessmentProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme.copyWith(
          brightness: Brightness.dark,
        ),
        initialRoute: AppConstants.routeAuth,
        onGenerateRoute: RouteConfig.generateRoute,
      ),
    );
  }
}
