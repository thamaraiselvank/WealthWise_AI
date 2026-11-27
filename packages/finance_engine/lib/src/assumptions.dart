/// The editable inputs behind every calculation.
///
/// These are illustrative scenario values, not promises. Every result that
/// depends on them must show them to the user. Users may change them within
/// the safe ranges in [AssumptionSpec]; values outside a range are clamped.
enum AssumptionField {
  inflation,
  equityReturn,
  debtReturn,
  goldReturn,
  cashReturn,
  sipStepUp,
  emergencyFundMonths,
  corpusMultiple,
}

/// Unit used to display and edit an assumption.
enum AssumptionUnit { percent, months, multiple }

/// Label, help text and safe range for one [AssumptionField].
class AssumptionSpec {
  final AssumptionField field;
  final String label;
  final String help;
  final AssumptionUnit unit;
  final double min;
  final double max;

  /// Slider step, in the same unit as [min]/[max] (0.005 = 0.5%).
  final double step;

  /// Values above this still work but are shown with a caution.
  final double? cautionAbove;

  const AssumptionSpec({
    required this.field,
    required this.label,
    required this.help,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    this.cautionAbove,
  });

  int get divisions => ((max - min) / step).round();

  double clamp(double v) => v.isNaN ? min : v.clamp(min, max).toDouble();

  /// "6.0%", "6 months", "25×".
  String format(double v) => switch (unit) {
        AssumptionUnit.percent => '${(v * 100).toStringAsFixed(1)}%',
        AssumptionUnit.months => '${v.round()} months',
        AssumptionUnit.multiple => '${v.round()}×',
      };

  static const all = <AssumptionSpec>[
    AssumptionSpec(
      field: AssumptionField.inflation,
      label: 'Inflation',
      help: 'How fast prices rise each year. India has averaged roughly 5–7% '
          'over the last decade.',
      unit: AssumptionUnit.percent,
      min: 0.03,
      max: 0.10,
      step: 0.005,
    ),
    AssumptionSpec(
      field: AssumptionField.equityReturn,
      label: 'Equity return',
      help: 'Long-run average for diversified equity (index / equity funds). '
          'Real years swing widely and can be negative.',
      unit: AssumptionUnit.percent,
      min: 0.06,
      max: 0.14,
      step: 0.005,
      cautionAbove: 0.12,
    ),
    AssumptionSpec(
      field: AssumptionField.debtReturn,
      label: 'Debt return',
      help: 'FDs, debt funds, PPF-type instruments.',
      unit: AssumptionUnit.percent,
      min: 0.04,
      max: 0.09,
      step: 0.005,
      cautionAbove: 0.08,
    ),
    AssumptionSpec(
      field: AssumptionField.goldReturn,
      label: 'Gold return',
      help: 'Long-run average for gold in rupees.',
      unit: AssumptionUnit.percent,
      min: 0.04,
      max: 0.10,
      step: 0.005,
      cautionAbove: 0.09,
    ),
    AssumptionSpec(
      field: AssumptionField.cashReturn,
      label: 'Cash return',
      help: 'Savings account or liquid fund.',
      unit: AssumptionUnit.percent,
      min: 0.02,
      max: 0.06,
      step: 0.005,
    ),
    AssumptionSpec(
      field: AssumptionField.sipStepUp,
      label: 'Yearly SIP step-up',
      help: 'How much you raise your SIP each year, usually in line with pay rises.',
      unit: AssumptionUnit.percent,
      min: 0,
      max: 0.20,
      step: 0.01,
      cautionAbove: 0.15,
    ),
    AssumptionSpec(
      field: AssumptionField.emergencyFundMonths,
      label: 'Emergency fund',
      help: 'Months of expenses + EMIs to keep in safe, easy-to-access money. '
          'Choose more if your income is irregular or you have dependents.',
      unit: AssumptionUnit.months,
      min: 3,
      max: 12,
      step: 1,
    ),
    AssumptionSpec(
      field: AssumptionField.corpusMultiple,
      label: 'Independence corpus',
      help: 'Corpus as a multiple of yearly expenses. 25× is the common rule; '
          '30–33× is more conservative for India because of higher inflation.',
      unit: AssumptionUnit.multiple,
      min: 20,
      max: 40,
      step: 1,
    ),
  ];

  static AssumptionSpec of(AssumptionField f) =>
      all.firstWhere((s) => s.field == f);
}

class Assumptions {
  /// Annual inflation rate (0.06 = 6%).
  final double inflation;

  /// Emergency fund target, in months of expenses.
  final int emergencyFundMonths;

  /// Retirement / FI corpus as a multiple of annual expenses.
  final double corpusMultiple;

  /// Illustrative annual returns per asset class.
  final double equityReturn;
  final double debtReturn;
  final double goldReturn;
  final double cashReturn;

  /// Yearly increase applied to step-up SIPs (0.10 = +10% a year).
  final double sipStepUp;

  const Assumptions({
    this.inflation = 0.06,
    this.emergencyFundMonths = 6,
    this.corpusMultiple = 25,
    this.equityReturn = 0.11,
    this.debtReturn = 0.065,
    this.goldReturn = 0.075,
    this.cashReturn = 0.035,
    this.sipStepUp = 0.10,
  });

  static const standard = Assumptions();

  double valueOf(AssumptionField f) => switch (f) {
        AssumptionField.inflation => inflation,
        AssumptionField.equityReturn => equityReturn,
        AssumptionField.debtReturn => debtReturn,
        AssumptionField.goldReturn => goldReturn,
        AssumptionField.cashReturn => cashReturn,
        AssumptionField.sipStepUp => sipStepUp,
        AssumptionField.emergencyFundMonths => emergencyFundMonths.toDouble(),
        AssumptionField.corpusMultiple => corpusMultiple,
      };

  /// Returns a copy with [f] set to [v], clamped to its safe range.
  Assumptions withValue(AssumptionField f, double v) {
    final c = AssumptionSpec.of(f).clamp(v);
    return switch (f) {
      AssumptionField.inflation => copyWith(inflation: c),
      AssumptionField.equityReturn => copyWith(equityReturn: c),
      AssumptionField.debtReturn => copyWith(debtReturn: c),
      AssumptionField.goldReturn => copyWith(goldReturn: c),
      AssumptionField.cashReturn => copyWith(cashReturn: c),
      AssumptionField.sipStepUp => copyWith(sipStepUp: c),
      AssumptionField.emergencyFundMonths =>
        copyWith(emergencyFundMonths: c.round()),
      AssumptionField.corpusMultiple => copyWith(corpusMultiple: c.roundToDouble()),
    };
  }

  /// Fields that differ from [base] (the defaults, unless given).
  List<AssumptionField> changedFrom([Assumptions base = standard]) => [
        for (final f in AssumptionField.values)
          if ((valueOf(f) - base.valueOf(f)).abs() > 1e-9) f,
      ];

  bool get isStandard => changedFrom().isEmpty;

  /// "Inflation 7.0% (default 6.0%)" for every changed field.
  List<String> describeChanges([Assumptions base = standard]) => [
        for (final f in changedFrom(base))
          '${AssumptionSpec.of(f).label} ${AssumptionSpec.of(f).format(valueOf(f))} '
              '(default ${AssumptionSpec.of(f).format(base.valueOf(f))})',
      ];

  /// Plain-language cautions for optimistic or unusual settings.
  List<String> get cautions {
    final out = <String>[];
    for (final s in AssumptionSpec.all) {
      final v = valueOf(s.field);
      if (s.cautionAbove != null && v > s.cautionAbove! + 1e-9) {
        out.add('${s.label} of ${s.format(v)} is optimistic. Plans may look '
            'easier than they turn out.');
      }
    }
    if (equityReturn <= inflation) {
      out.add('Equity return is not above inflation, so investments would '
          'barely grow in real terms.');
    }
    return out;
  }

  Map<String, double> toJson() => {
        for (final f in AssumptionField.values) f.name: valueOf(f),
      };

  /// Unknown keys are ignored, missing keys keep defaults, and every value is
  /// clamped to its safe range.
  factory Assumptions.fromJson(Map<String, dynamic> json) {
    var a = standard;
    for (final f in AssumptionField.values) {
      final v = json[f.name];
      if (v is num && v.isFinite) a = a.withValue(f, v.toDouble());
    }
    return a;
  }

  Assumptions copyWith({
    double? inflation,
    int? emergencyFundMonths,
    double? corpusMultiple,
    double? equityReturn,
    double? debtReturn,
    double? goldReturn,
    double? cashReturn,
    double? sipStepUp,
  }) =>
      Assumptions(
        inflation: inflation ?? this.inflation,
        emergencyFundMonths: emergencyFundMonths ?? this.emergencyFundMonths,
        corpusMultiple: corpusMultiple ?? this.corpusMultiple,
        equityReturn: equityReturn ?? this.equityReturn,
        debtReturn: debtReturn ?? this.debtReturn,
        goldReturn: goldReturn ?? this.goldReturn,
        cashReturn: cashReturn ?? this.cashReturn,
        sipStepUp: sipStepUp ?? this.sipStepUp,
      );

  @override
  bool operator ==(Object other) =>
      other is Assumptions &&
      AssumptionField.values.every((f) => valueOf(f) == other.valueOf(f));

  @override
  int get hashCode =>
      Object.hashAll(AssumptionField.values.map(valueOf));
}
