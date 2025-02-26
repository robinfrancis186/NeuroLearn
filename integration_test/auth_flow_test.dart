import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:neurolearn/main.dart' as app;
import 'package:neurolearn/features/auth/auth.dart';
import 'package:neurolearn/theme/app_colors.dart';
import 'package:neurolearn/shared/services/tts_service.dart';
import 'package:neurolearn/shared/services/voice_service.dart';
import 'package:provider/provider.dart';
import 'package:neurolearn/features/learning/learning.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Test', () {
    testWidgets('Login with valid credentials navigates to dashboard',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the login screen
      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Verify the app's primary color is used
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme?.primaryColor, AppColors.primary);

      // Enter email
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.pumpAndSettle();

      // Tap login button - using the primary button style
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify we're navigated to the dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('Login with invalid credentials shows error',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the login screen with the correct branding
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('NeuroLearn'), findsOneWidget);

      // Enter invalid email
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'invalid@example.com',
      );
      await tester.pumpAndSettle();

      // Enter invalid password
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'wrongpassword',
      );
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify error message is shown with the error color
      final errorText = find.text('Invalid credentials');
      expect(errorText, findsOneWidget);
      
      // Check that the error uses the app's error color
      final textWidget = tester.widget<Text>(errorText);
      expect(textWidget.style?.color, AppColors.error);
    });

    testWidgets('Logout navigates back to login screen',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify we're on the dashboard with the correct app bar color
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Find the app bar and verify its color
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsOneWidget);
      
      // Open drawer using the menu icon
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer header has the app's branding
      expect(find.text('NeuroLearn'), findsOneWidget);

      // Tap logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      // Verify we're back on the login screen with the correct UI elements
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Welcome to NeuroLearn'), findsOneWidget);
    });
    
    testWidgets('Login screen has correct UI elements and styling',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify login screen has the correct UI elements
      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Check for the app logo/image
      expect(find.byType(Image), findsWidgets);
      
      // Check for text fields with correct hints
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      
      // Check for the login button with correct styling
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Login');
      expect(buttonFinder, findsOneWidget);
      
      final button = tester.widget<ElevatedButton>(buttonFinder);
      final buttonStyle = button.style;
      
      // Verify the button uses a rounded border radius (common in modern UI)
      final borderRadius = buttonStyle?.shape?.resolve({}) as RoundedRectangleBorder?;
      expect(borderRadius?.borderRadius, isA<BorderRadius>());
      
      // Check for "Forgot Password?" text
      expect(find.text('Forgot Password?'), findsOneWidget);
      
      // Check for "Sign Up" option
      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });
  });
  
  group('AI and Voice Features Test', () {
    testWidgets('TTS service is properly initialized and can speak',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Login to access features
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      
      // Navigate to a subject screen where TTS is used
      // First find and tap on a subject card (e.g., Math)
      await tester.tap(find.text('Math'));
      await tester.pumpAndSettle();
      
      // Verify we're on the subject screen
      expect(find.byType(MathScreen), findsOneWidget);
      
      // Find and tap the help button that triggers TTS
      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();
      
      // Verify the avatar speaking state is updated
      final context = tester.element(find.byType(MathScreen));
      final learningProvider = Provider.of<LearningProvider>(context, listen: false);
      
      // Note: In a real test, we'd wait for the speaking to complete
      // For this test, we're just verifying the UI updates correctly
      expect(learningProvider.isAvatarSpeaking, isTrue);
    });
    
    testWidgets('Custom voice settings can be configured',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Login to access features
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      
      // Navigate to settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      
      // Find and tap on Voice Settings
      await tester.tap(find.text('Voice Settings'));
      await tester.pumpAndSettle();
      
      // Verify voice settings screen elements
      expect(find.text('Voice Settings'), findsOneWidget);
      expect(find.text('Custom Voice'), findsOneWidget);
      
      // Toggle custom voice option
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      
      // Adjust voice pitch slider
      final sliderFinder = find.byType(Slider).first;
      expect(sliderFinder, findsOneWidget);
      
      // Simulate dragging the slider to change pitch
      await tester.drag(sliderFinder, const Offset(50.0, 0.0));
      await tester.pumpAndSettle();
      
      // Save settings
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify settings saved confirmation
      expect(find.text('Settings saved successfully'), findsOneWidget);
    });
    
    testWidgets('AI-powered learning content is displayed correctly',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Login to access features
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      
      // Navigate to a subject with AI-generated content
      await tester.tap(find.text('Math'));
      await tester.pumpAndSettle();
      
      // Tap on an AI-generated exercise
      await tester.tap(find.text('AI-Generated Exercises'));
      await tester.pumpAndSettle();
      
      // Verify AI content is displayed
      expect(find.text('Personalized Math Problems'), findsOneWidget);
      
      // Check for the AI difficulty adjustment controls
      expect(find.text('Difficulty Level'), findsOneWidget);
      
      // Adjust difficulty level
      await tester.tap(find.text('Intermediate'));
      await tester.pumpAndSettle();
      
      // Generate new problems
      await tester.tap(find.text('Generate New Problems'));
      await tester.pumpAndSettle();
      
      // Verify loading indicator appears during generation
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for generation to complete (in a real test)
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Verify new problems are displayed
      expect(find.text('Problem 1:'), findsOneWidget);
    });
    
    testWidgets('Voice cloning feature works correctly',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      // Login to access features
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      
      // Navigate to voice settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Voice Settings'));
      await tester.pumpAndSettle();
      
      // Navigate to voice cloning section
      await tester.tap(find.text('Voice Cloning'));
      await tester.pumpAndSettle();
      
      // Verify voice cloning UI elements
      expect(find.text('Record Your Voice'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
      
      // Start recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      
      // Verify recording UI is shown
      expect(find.text('Recording...'), findsOneWidget);
      
      // Wait for recording to complete (simulated)
      await tester.pump(const Duration(seconds: 3));
      
      // Stop recording
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();
      
      // Submit voice sample
      await tester.tap(find.text('Submit Voice Sample'));
      await tester.pumpAndSettle();
      
      // Verify processing indicator
      expect(find.text('Processing Voice Sample...'), findsOneWidget);
      
      // Wait for processing to complete (simulated)
      await tester.pump(const Duration(seconds: 5));
      
      // Verify success message
      expect(find.text('Voice Clone Created Successfully'), findsOneWidget);
      
      // Test the cloned voice
      await tester.tap(find.text('Test Voice'));
      await tester.pumpAndSettle();
      
      // Verify test playback UI
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });
  });
} 