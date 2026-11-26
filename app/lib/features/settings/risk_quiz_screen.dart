import 'package:finance_engine/finance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../state/app_state.dart';
import '../../util/format.dart';
import '../../widgets/forms.dart';

class RiskQuizScreen extends ConsumerStatefulWidget {
  const RiskQuizScreen({super.key});

  @override
  ConsumerState<RiskQuizScreen> createState() => _RiskQuizScreenState();
}

class _RiskQuizScreenState extends ConsumerState<RiskQuizScreen> {
  late final Map<String, int> _answers =
      Map.of(ref.read(appStateProvider).riskAnswers);

  bool get _complete => _answers.length >= RiskQuestionnaire.questions.length;

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await ref.read(appStateProvider.notifier).updateRiskAnswers(Map.of(_answers));
    navigator.pop();
    messenger.showSnackBar(SnackBar(
        content: Text('Risk profile: ${riskLabel(RiskQuestionnaire.score(_answers))}')));
  }

  @override
  Widget build(BuildContext context) {
    final preview = RiskQuestionnaire.score(_answers);
    return Scaffold(
      appBar: AppBar(title: const Text('Risk questionnaire')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RiskQuestionList(
            answers: _answers,
            onAnswer: (id, i) => setState(() => _answers[id] = i),
          ),
          if (_complete)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Your profile: ${riskLabel(preview)}',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          FilledButton(
            onPressed: _complete ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
