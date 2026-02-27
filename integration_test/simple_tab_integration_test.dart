import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/simple_tab.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SimpleTab switches tab by swipe and reports active index', (
    tester,
  ) async {
    int? activeIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SimpleTab(
            showTabBar: true,
            onTabChanged: (value) => activeIndex = value,
            tabViews: const [
              Center(child: Text('First tab')),
              Center(child: Text('Second tab')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('First tab'), findsOneWidget);
    expect(find.text('Second tab'), findsNothing);

    await tester.drag(find.byType(TabBarView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Second tab'), findsOneWidget);
    expect(activeIndex, 1);
  });
}
