import 'package:finance_engine/finance_engine.dart';
import 'package:test/test.dart';

void main() {
  final balanced = ExpenseBreakdown({
    ExpenseCategory.housing: 10000,
    ExpenseCategory.food: 6000,
    ExpenseCategory.transport: 3000,
    ExpenseCategory.utilities: 2000,
    ExpenseCategory.lifestyle: 4000,
  });

  group('ExpenseBreakdown', () {
    test('total and lookup', () {
      expect(balanced.total, 25000);
      expect(balanced[ExpenseCategory.food], 6000);
      expect(balanced[ExpenseCategory.health], 0);
    });

    test('drops zero and negative amounts', () {
      final b = ExpenseBreakdown({ExpenseCategory.food: 0, ExpenseCategory.other: -5});
      expect(b.isEmpty, isTrue);
    });

    test('JSON round-trip, ignoring unknown categories', () {
      final json = balanced.toJson();
      expect(ExpenseBreakdown.fromJson(json), balanced);
      final withUnknown = {...json, 'crypto': 999, 'food': 'oops'};
      final parsed = ExpenseBreakdown.fromJson(withUnknown);
      expect(parsed[ExpenseCategory.food], 0);
      expect(parsed.total, 19000);
    });
  });

  group('ExpenseAnalyzer', () {
    test('sorted lines with shares', () {
      final a = ExpenseAnalyzer.analyze(balanced, 40000);
      expect(a.lines.first.category, ExpenseCategory.housing);
      expect(a.lines.first.shareOfSpending, closeTo(0.4, 1e-9));
      expect(a.lines.first.shareOfIncome, closeTo(0.25, 1e-9));
      expect(a.essentialShareOfIncome, closeTo(21000 / 40000, 1e-9));
      expect(a.discretionaryShareOfIncome, closeTo(0.1, 1e-9));
    });

    test('balanced spending gets a positive note only', () {
      final a = ExpenseAnalyzer.analyze(balanced, 60000);
      expect(a.insights.single.title, 'Your spending looks balanced');
    });

    test('flags high housing, essentials and lifestyle', () {
      final b = ExpenseBreakdown({
        ExpenseCategory.housing: 15000,
        ExpenseCategory.food: 9000,
        ExpenseCategory.lifestyle: 13000,
      });
      final titles = ExpenseAnalyzer.analyze(b, 40000).insights.map((i) => i.title);
      expect(titles, containsAll([
        'Housing is 38% of income',
        'Essentials take 60% of income',
        'Lifestyle spending is 33% of income',
      ]));
    });

    test('zero income does not divide by zero', () {
      final a = ExpenseAnalyzer.analyze(balanced, 0);
      expect(a.essentialShareOfIncome, 0);
      expect(a.lines, hasLength(5));
    });
  });
}
