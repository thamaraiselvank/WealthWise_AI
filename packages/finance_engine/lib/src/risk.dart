enum RiskProfile { conservative, moderate, aggressive }

class RiskOption {
  final String label;
  final int points;
  const RiskOption(this.label, this.points);
}

class RiskQuestion {
  final String id;
  final String text;
  final List<RiskOption> options;
  const RiskQuestion(this.id, this.text, this.options);
}

/// Simple 6-question risk questionnaire. Each answer scores 1–3 points.
class RiskQuestionnaire {
  RiskQuestionnaire._();

  static const questions = <RiskQuestion>[
    RiskQuestion('drop', 'If your investments fell 20% in a month, you would…', [
      RiskOption('Sell everything to stop the loss', 1),
      RiskOption('Wait and do nothing', 2),
      RiskOption('Invest more while prices are low', 3),
    ]),
    RiskQuestion('goal', 'What matters most to you?', [
      RiskOption('Protecting my money', 1),
      RiskOption('A balance of safety and growth', 2),
      RiskOption('Maximum long-term growth', 3),
    ]),
    RiskQuestion('experience', 'Your investing experience:', [
      RiskOption('None, only savings account / FD', 1),
      RiskOption('Some mutual funds or SIPs', 2),
      RiskOption('Several years in equity markets', 3),
    ]),
    RiskQuestion('income', 'How stable is your income?', [
      RiskOption('Uncertain or irregular', 1),
      RiskOption('Fairly stable', 2),
      RiskOption('Very stable with growth', 3),
    ]),
    RiskQuestion('horizon', 'When will you need most of this money?', [
      RiskOption('Within 3 years', 1),
      RiskOption('In 3–7 years', 2),
      RiskOption('After 7+ years', 3),
    ]),
    RiskQuestion('swing', 'Which yearly outcome range would you accept?', [
      RiskOption('-2% to +8%', 1),
      RiskOption('-10% to +18%', 2),
      RiskOption('-25% to +35%', 3),
    ]),
  ];

  /// [answers] maps question id → chosen option index.
  /// Unanswered questions count as the middle option.
  static RiskProfile score(Map<String, int> answers) {
    var total = 0;
    for (final q in questions) {
      final i = answers[q.id] ?? 1;
      total += q.options[i.clamp(0, q.options.length - 1)].points;
    }
    // Range 6–18.
    if (total <= 10) return RiskProfile.conservative;
    if (total <= 14) return RiskProfile.moderate;
    return RiskProfile.aggressive;
  }
}
