import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neurolearn/shared/widgets/subject_card.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/services.dart';

// Generate mocks
@GenerateMocks([NavigatorObserver])
import 'subject_card_test.mocks.dart';

void main() {
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  // Mock the asset bundle to avoid asset loading issues
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('SubjectCard Widget Tests', () {
    testWidgets('renders correctly with provided data', (WidgetTester tester) async {
      // Arrange
      const subject = 'Math';
      const icon = Icons.calculate;
      const color = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubjectCard(
              subject: subject,
              icon: icon,
              color: color,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(subject), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
      
      // Verify the card has the correct color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      final gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors.last, equals(color));
    });

    testWidgets('navigates to correct screen when tapped', (WidgetTester tester) async {
      // Arrange
      const subject = 'Math';
      const icon = Icons.calculate;
      const color = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          navigatorObservers: [mockObserver],
          home: Scaffold(
            body: SubjectCard(
              subject: subject,
              icon: icon,
              color: color,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Assert
      verify(mockObserver.didPush(any, any));
    });
    
    testWidgets('applies correct styling', (WidgetTester tester) async {
      // Arrange
      const subject = 'Math';
      const icon = Icons.calculate;
      const color = Colors.blue;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubjectCard(
              subject: subject,
              icon: icon,
              color: color,
            ),
          ),
        ),
      );

      // Assert
      // Check for rounded corners
      final card = tester.widget<Card>(find.byType(Card));
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(20)));
      
      // Check for icon styling
      final iconContainer = tester.widget<Container>(
        find.ancestor(
          of: find.byIcon(icon),
          matching: find.byType(Container),
        ),
      );
      
      expect(iconContainer.padding, equals(const EdgeInsets.all(12)));
      
      // Check text styling
      final text = tester.widget<Text>(find.text(subject));
      expect(text.style?.color, equals(Colors.white));
      expect(text.style?.fontSize, equals(18));
      expect(text.style?.fontWeight, equals(FontWeight.bold));
      expect(text.style?.fontFamily, equals('Urbanist'));
    });
  });
} 