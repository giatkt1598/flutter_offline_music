import 'package:flutter_offline_music/utilities/string_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExtension', () {
    test('toNullIfEmpty returns null for empty string', () {
      expect(''.toNullIfEmpty(), isNull);
    });

    test('toNullIfEmpty returns same value for non-empty string', () {
      expect('abc'.toNullIfEmpty(), 'abc');
    });
  });
}
