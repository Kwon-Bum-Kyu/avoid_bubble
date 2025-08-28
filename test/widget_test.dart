// Basic Flutter widget test for Avoid Bubble Game.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avoid_bubble/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for a single frame to render
    await tester.pump();

    // Verify that the app launches without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // Since this is a game app with continuous animations, 
    // we just verify it starts without throwing exceptions
  });
}
