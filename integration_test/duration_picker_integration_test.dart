import 'package:flutter/material.dart';
import 'package:flutter_offline_music/components/duration_picker.dart';
import 'package:flutter_offline_music/i18n/app_localizations.dart';
import 'package:flutter_offline_music/shared/shared_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DurationPicker quick options emit selected duration', (
    tester,
  ) async {
    Duration? changedValue;
    Duration? quickValue;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: GlobalContext.navigatorKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DurationPicker(
            onChanged: (value) => changedValue = value,
            quickOptionPressed: (value) => quickValue = value,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('30m'));
    await tester.pumpAndSettle();

    expect(changedValue, const Duration(minutes: 30));
    expect(quickValue, const Duration(minutes: 30));

    await tester.tap(find.text('2h'));
    await tester.pumpAndSettle();

    expect(changedValue, const Duration(hours: 2));
    expect(quickValue, const Duration(hours: 2));
  });
}
