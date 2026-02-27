import 'package:flutter_offline_music/utilities/time_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('fDurationHHMMSS', () {
    test('formats with hours', () {
      final value = fDurationHHMMSS(Duration(hours: 1, minutes: 2, seconds: 3));
      expect(value, '01:02:03');
    });

    test('formats short without hours when zero', () {
      final value = fDurationHHMMSS(
        Duration(minutes: 2, seconds: 3),
        short: true,
      );
      expect(value, '02:03');
    });
  });
}
