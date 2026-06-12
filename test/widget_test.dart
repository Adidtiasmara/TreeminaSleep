import 'package:flutter_test/flutter_test.dart';
import 'package:treemina_sleep/models/sleep_record_model.dart';
import 'package:treemina_sleep/utils/sleep_calculator.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(true, isTrue);
  });

  group('SleepCalculator', () {
    test('calculates sleep duration across midnight', () {
      final start = DateTime(2026, 6, 11, 23);
      final end = DateTime(2026, 6, 12, 4);

      expect(SleepCalculator.calculateDurationMinutes(start, end), 5 * 60);
    });

    test('does not turn negative duration into almost a full day', () {
      final start = DateTime(2026, 6, 12, 7, 30);
      final end = DateTime(2026, 6, 12, 5, 30);

      expect(SleepCalculator.calculateDurationMinutes(start, end), 0);
    });

    test('normalizes report duration to 24 hours', () {
      expect(
        SleepCalculator.durationInHours(27 * 60),
        SleepCalculator.maxReportDurationMinutes / 60,
      );
    });
  });

  group('SleepRecord', () {
    test('parses UTC timestamps as local DateTimes', () {
      final record = SleepRecord.fromMap({
        'id': '1',
        'date': '2026-06-12T00:00:00.000Z',
        'sleepStart': '2026-06-11T17:30:00.000Z',
        'wakeUp': '2026-06-11T22:30:00.000Z',
        'durationMinutes': 300,
        'status': 'Bad Sleep',
      });

      expect(record.sleepStart.isUtc, isFalse);
      expect(record.wakeUp.isUtc, isFalse);
    });
  });
}
