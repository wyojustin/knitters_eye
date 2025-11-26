import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knitters_eye/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize SharedPreferences with empty values
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const KnittersEyeApp());

    // Verify loading indicator is shown initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the Future to complete and rebuild
    await tester.pumpAndSettle();

    // Verify that we start with no projects
    expect(find.text('No projects yet'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
