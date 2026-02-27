import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_offline_music/providers/tab_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TabProvider', () {
    testWidgets('initializes controllers and changes tab index', (tester) async {
      final provider = TabProvider();
      provider.initTabController(vsync: const TestVSync());
      await tester.pumpWidget(
        MaterialApp(
          home: PageView(
            controller: provider.pageController,
            children: const [SizedBox(), SizedBox(), SizedBox(), SizedBox()],
          ),
        ),
      );

      expect(provider.tabController.length, provider.tabDataList.length);
      expect(provider.tabIndex, 0);

      provider.animateToTab(2);
      expect(provider.tabIndex, 2);

      provider.animateToPage(1);
      await tester.pumpAndSettle();
      expect(provider.tabIndex, 1);

      provider.dispose();
    });

    test('finds tab index by widget type', () {
      final provider = TabProvider();
      final index = provider.indexOf<dynamic>();

      expect(index, -1);
    });
  });
}
