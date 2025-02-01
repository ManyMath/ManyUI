import 'package:flutter_test/flutter_test.dart';
import 'package:manyui/src/widgets/date_field/parse.dart';

void main() {
  group('parseMDate ISO', () {
    test('accepts a canonical YYYY-MM-DD', () {
      final DateTime? d = parseMDate('2026-05-13');
      expect(d, DateTime.utc(2026, 5, 13));
    });

    test('rejects missing zero-padding (2026-5-13)', () {
      expect(parseMDate('2026-5-13'), isNull);
    });

    test('rejects calendar overflow (2026-02-30)', () {
      expect(parseMDate('2026-02-30'), isNull);
    });

    test('rejects malformed (2026/05/13 → too short for ISO)', () {
      // The hyphen-positions check guards against confusion with the slash
      // format. 2026/05/13 isn't a valid slash form (year first), so this
      // returns null, not the slash interpretation.
      expect(parseMDate('2026/05/13'), isNull);
    });
  });

  group('parseMDate US slash', () {
    test('accepts unpadded M/D/YYYY', () {
      expect(parseMDate('5/13/2026'), DateTime.utc(2026, 5, 13));
    });

    test('accepts zero-padded MM/DD/YYYY', () {
      expect(parseMDate('05/13/2026'), DateTime.utc(2026, 5, 13));
    });

    test('rejects 2-digit year', () {
      expect(parseMDate('5/13/26'), isNull);
    });

    test('rejects overflow (2/30/2026)', () {
      expect(parseMDate('2/30/2026'), isNull);
    });
  });

  group('parseMDate English month names', () {
    test('accepts "May 13 2026"', () {
      expect(parseMDate('May 13 2026'), DateTime.utc(2026, 5, 13));
    });

    test('accepts "May 13, 2026"', () {
      expect(parseMDate('May 13, 2026'), DateTime.utc(2026, 5, 13));
    });

    test('accepts "13 May 2026"', () {
      expect(parseMDate('13 May 2026'), DateTime.utc(2026, 5, 13));
    });

    test('accepts "13 May, 2026"', () {
      expect(parseMDate('13 May, 2026'), DateTime.utc(2026, 5, 13));
    });

    test('accepts case variants ("may" and "MAY")', () {
      expect(parseMDate('may 13 2026'), DateTime.utc(2026, 5, 13));
      expect(parseMDate('MAY 13 2026'), DateTime.utc(2026, 5, 13));
    });

    test('accepts three-letter abbreviation ("Sep 7 2026")', () {
      expect(parseMDate('Sep 7 2026'), DateTime.utc(2026, 9, 7));
    });

    test('accepts the full name ("September 7 2026")', () {
      expect(parseMDate('September 7 2026'), DateTime.utc(2026, 9, 7));
    });

    test('rejects two month tokens', () {
      expect(parseMDate('May June 2026'), isNull);
    });
  });

  group('parseMDate empty/whitespace', () {
    test('empty input returns null', () {
      expect(parseMDate(''), isNull);
    });

    test('whitespace-only input returns null', () {
      expect(parseMDate('   '), isNull);
    });

    test('trims surrounding whitespace before parsing', () {
      expect(parseMDate('  2026-05-13  '), DateTime.utc(2026, 5, 13));
    });
  });

  group('formatMDate', () {
    test('emits YYYY-MM-DD with zero-padding', () {
      expect(formatMDate(DateTime.utc(2026, 5, 13)), '2026-05-13');
      expect(formatMDate(DateTime.utc(2026, 1, 1)), '2026-01-01');
      expect(formatMDate(DateTime.utc(2026, 12, 9)), '2026-12-09');
    });

    test('handles four-digit years lower than 1000', () {
      expect(formatMDate(DateTime.utc(101, 5, 13)), '0101-05-13');
    });
  });

  group('round-trip', () {
    test('parse then format yields canonical form', () {
      const List<String> inputs = <String>[
        '2026-05-13',
        '5/13/2026',
        '05/13/2026',
        'May 13 2026',
        'May 13, 2026',
        '13 May 2026',
        'sep 7 2026',
      ];
      for (final String input in inputs) {
        final DateTime? parsed = parseMDate(input);
        expect(parsed, isNotNull, reason: 'parse failed for "$input"');
        if (parsed != null) {
          // Format then re-parse: every input should converge to ISO.
          final String canon = formatMDate(parsed);
          expect(parseMDate(canon), parsed, reason: 'round-trip drift for "$input"');
        }
      }
    });
  });

  group('monthName', () {
    test('returns capitalized long names', () {
      expect(monthName(1), 'January');
      expect(monthName(5), 'May');
      expect(monthName(12), 'December');
    });

    test('out-of-range returns empty', () {
      expect(monthName(0), '');
      expect(monthName(13), '');
    });
  });

  group('shortWeekdayName', () {
    test('returns three-letter names Monday-Sunday', () {
      expect(shortWeekdayName(DateTime.monday), 'Mon');
      expect(shortWeekdayName(DateTime.tuesday), 'Tue');
      expect(shortWeekdayName(DateTime.sunday), 'Sun');
    });
  });
}
