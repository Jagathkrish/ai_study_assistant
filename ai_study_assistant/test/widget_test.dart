import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Make sure this matches your actual project name!
import 'package:ai_study_assistant/main.dart'; 

void main() {
  testWidgets('Simulate first-time user (Shows Download Screen)', (WidgetTester tester) async {
    // 1. Build our app, passing 'false' for isDownloaded
    await tester.pumpWidget(const AIStudyApp(isDownloaded: false));

    // 2. Verify we see the Download Screen text
    expect(find.text('AI Engine Setup'), findsOneWidget);
    expect(find.text('Download Engine'), findsOneWidget);

    // 3. Verify the old counter '0' is completely gone
    expect(find.text('0'), findsNothing);
  });

  testWidgets('Simulate returning user (Shows Chat Screen)', (WidgetTester tester) async {
    // 1. Build our app, passing 'true' for isDownloaded
    await tester.pumpWidget(const AIStudyApp(isDownloaded: true));

    // 2. Verify we bypassed the download and see the Chat Screen
    expect(find.text('AI Study Assistant'), findsOneWidget);
    expect(find.text('Ask a question or paste text...'), findsOneWidget);
    
    // 3. Verify the download screen text is nowhere to be found
    expect(find.text('AI Engine Setup'), findsNothing);
  });
}