import 'dart:math' as math;

import 'package:finance_engine/finance_engine.dart';
import 'package:test/test.dart';

void main() {
  group('futureValue / inflate', () {
    test('compounds annually', () {
      expect(MoneyMath.futureValue(100000, 0.10, 2), closeTo(121000, 0.01));
    });

    test('₹25k at 6% for 20 years ≈ ₹80.2k', () {
      expect(MoneyMath.inflate(25000, 0.06, 20), closeTo(80178.4, 1));
    });

    test('zero years returns the same amount', () {
      expect(MoneyMath.futureValue(5000, 0.12, 0), 5000);
    });
  });

  group('sipFutureValue', () {
    test('matches the annuity-due formula', () {
      const r = 0.12 / 12;
      final expected = 10000 * ((math.pow(1 + r, 120) - 1) / r) * (1 + r);
      expect(MoneyMath.sipFutureValue(10000, 0.12, 10), closeTo(expected, 0.01));
    });

    test('zero rate is a plain sum', () {
      expect(MoneyMath.sipFutureValue(1000, 0, 2), 24000);
    });

    test('step-up of 0 equals flat SIP via simulation path', () {
      final flat = MoneyMath.sipFutureValue(5000, 0.10, 15);
      final tiny = MoneyMath.sipFutureValue(5000, 0.10, 15, annualStepUp: 1e-12);
      expect(tiny, closeTo(flat, 0.01));
    });

    test('step-up produces a larger corpus', () {
      expect(
        MoneyMath.sipFutureValue(5000, 0.10, 15, annualStepUp: 0.10),
        greaterThan(MoneyMath.sipFutureValue(5000, 0.10, 15)),
      );
    });

    test('no months or no SIP returns 0', () {
      expect(MoneyMath.sipFutureValue(5000, 0.1, 0), 0);
      expect(MoneyMath.sipFutureValue(0, 0.1, 10), 0);
    });
  });

  group('requiredSip', () {
    test('round-trips with sipFutureValue', () {
      final sip = MoneyMath.requiredSip(5000000, 0.11, 12);
      expect(MoneyMath.sipFutureValue(sip, 0.11, 12), closeTo(5000000, 1));
    });

    test('round-trips with step-up', () {
      final sip = MoneyMath.requiredSip(5000000, 0.11, 12, annualStepUp: 0.10);
      expect(
        MoneyMath.sipFutureValue(sip, 0.11, 12, annualStepUp: 0.10),
        closeTo(5000000, 1),
      );
    });

    test('step-up start is lower than flat SIP', () {
      expect(
        MoneyMath.requiredSip(5000000, 0.11, 12, annualStepUp: 0.10),
        lessThan(MoneyMath.requiredSip(5000000, 0.11, 12)),
      );
    });

    test('existing corpus reduces the SIP and can cover it fully', () {
      expect(
        MoneyMath.requiredSip(1000000, 0.10, 10, existingCorpus: 100000),
        lessThan(MoneyMath.requiredSip(1000000, 0.10, 10)),
      );
      expect(MoneyMath.requiredSip(100000, 0.10, 10, existingCorpus: 100000), 0);
    });

    test('worked example: ₹2.4 Cr in 20 years at 11% ≈ ₹27.5k/month', () {
      final corpus = MoneyMath.inflate(25000, 0.06, 20) * 12 * 25;
      expect(corpus, closeTo(2.405e7, 1e5));
      expect(MoneyMath.requiredSip(corpus, 0.11, 20), closeTo(27530, 300));
    });
  });
}
