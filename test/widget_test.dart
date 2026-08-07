import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triple_t/main.dart';
import 'package:triple_t/screens/splash_screen.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences values before initializing the app providers.
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen is displayed.
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
