import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jobhud/screens/auth/login_screen.dart';

void main() {
  testWidgets('Login screen has email and password fields', (WidgetTester tester) async {
    // Build our login screen wrapped in MaterialApp
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Verify that the login screen has the correct title
    expect(find.text('Sign In'), findsOneWidget);
    
    // Verify that email and password fields are present
    expect(find.byType(TextFormField), findsNWidgets(2));
    
    // Verify the email and password labels
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    
    // Verify that the login button exists
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
