import 'package:finance_engine/finance_engine.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../util/format.dart';
import 'forms.dart';

/// Optional "list my assets and loans one by one" section, shared by
/// onboarding and profile editing. Reports the sheet, or null when switched
/// off (quick mode: the parent shows its single total fields instead).
class BalanceSheetEditor extends StatefulWidget {
  final BalanceSheet? initial;
  final ValueChanged<BalanceSheet?> onChanged;

  /// Called when the user switches detailed mode on with nothing entered yet,
  /// so quick-mode totals can be carried over instead of retyped.
  final BalanceSheet Function()? seed;

  const BalanceSheetEditor({
    super.key,
    this.initial,
    required this.onChanged,
    this.seed,
  });

  @override
  State<BalanceSheetEditor> createState() => _BalanceSheetEditorState();
}

class _AssetRow {
  final String id;
  AssetType type;
  final TextEditingController value;
  final String label;
  _AssetRow(this.id, this.type, double v, this.label)
      : value = TextEditingController(text: v > 0 ? v.round().toString() : '');
}

class _LoanRow {
  final String id;
  LoanType type;
  final TextEditingController outstanding, emi, rate;
  final String label;
  _LoanRow(this.id, this.type, double o, double e, double? r, this.label)
      : outstanding = TextEditingController(text: o > 0 ? o.round().toString() : ''),
        emi = TextEditingController(text: e > 0 ? e.round().toString() : ''),
        rate = TextEditingController(text: r == null ? '' : _fmtRate(r));

  static String _fmtRate(double r) {
    final s = (r * 100).toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class _BalanceSheetEditorState extends State<BalanceSheetEditor> {
  late bool _enabled = widget.initial != null;
  final _assets = <_AssetRow>[];
  final _loans = <_LoanRow>[];
  int _counter = 0;

  String _newId(String prefix) =>
      '$prefix${DateTime.now().microsecondsSinceEpoch}_${_counter++}';

  @override
  void initState() {
    super.initState();
    _load(widget.initial);
  }

  void _load(BalanceSheet? s) {
    for (final a in s?.assets ?? const <Asset>[]) {
      _addAsset(a.type, value: a.value, id: a.id, label: a.label, report: false);
    }
    for (final l in s?.loans ?? const <Loan>[]) {
      _addLoan(l.type,
          outstanding: l.outstanding,
          emi: l.emi,
          rate: l.annualRate,
          id: l.id,
          label: l.label,
          report: false);
    }
  }

  @override
  void dispose() {
    for (final a in _assets) {
      a.value.dispose();
    }
    for (final l in _loans) {
      l.outstanding.dispose();
      l.emi.dispose();
      l.rate.dispose();
    }
    super.dispose();
  }

  /// Percent text ("8.5") -> fraction (0.085). Blank or implausible -> null.
  static double? _parseRate(String text) {
    final v = double.tryParse(text.trim());
    if (v == null || v < 0 || v > 60) return null;
    return v / 100;
  }

  BalanceSheet get _current => BalanceSheet(
        assets: [
          for (final a in _assets)
            if (parseAmount(a.value.text) > 0)
              Asset(id: a.id, type: a.type, label: a.label, value: parseAmount(a.value.text)),
        ],
        loans: [
          for (final l in _loans)
            if (parseAmount(l.outstanding.text) > 0)
              Loan(
                id: l.id,
                type: l.type,
                label: l.label,
                outstanding: parseAmount(l.outstanding.text),
                emi: parseAmount(l.emi.text),
                annualRate: _parseRate(l.rate.text),
              ),
        ],
      );

  void _report() {
    setState(() {});
    widget.onChanged(_enabled ? _current : null);
  }

  void _addAsset(AssetType type,
      {double value = 0, String? id, String label = '', bool report = true}) {
    final row = _AssetRow(id ?? _newId('a'), type, value, label);
    row.value.addListener(_report);
    _assets.add(row);
    if (report) _report();
  }

  void _addLoan(LoanType type,
      {double outstanding = 0,
      double emi = 0,
      double? rate,
      String? id,
      String label = '',
      bool report = true}) {
    final row = _LoanRow(id ?? _newId('l'), type, outstanding, emi, rate, label);
    for (final c in [row.outstanding, row.emi, row.rate]) {
      c.addListener(_report);
    }
    _loans.add(row);
    if (report) _report();
  }

  void _toggle(bool on) {
    _enabled = on;
    if (on && _assets.isEmpty && _loans.isEmpty) {
      final seed = widget.seed?.call();
      if (seed != null) _load(seed);
      if (_assets.isEmpty) _addAsset(AssetType.bank, report: false);
    }
    _report();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final sheet = _current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('List my assets and loans one by one'),
          subtitle: const Text(
              'Optional. Gives you net worth, loan payoff dates and which debt to clear first.'),
          value: _enabled,
          onChanged: _toggle,
        ),
        if (_enabled) ...[
          const SizedBox(height: 8),
          Text('What you own', style: t.titleMedium),
          for (final a in _assets) _assetCard(a),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _addAsset(AssetType.mutualFundsStocks),
              icon: const Icon(Icons.add),
              label: const Text('Add asset'),
            ),
          ),
          const SizedBox(height: 8),
          Text('Total owned: ${inr(sheet.totalAssets)}', style: t.titleSmall),
          const SizedBox(height: 20),
          Text('What you owe', style: t.titleMedium),
          if (_loans.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('No loans or credit card dues? Great, leave this empty.',
                  style: t.bodySmall),
            ),
          for (final l in _loans) _loanCard(l),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => _addLoan(LoanType.personal),
              icon: const Icon(Icons.add),
              label: const Text('Add loan'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total owed: ${inr(sheet.totalLoans)} · EMIs: ${inr(sheet.totalEmi)}/month',
            style: t.titleSmall,
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _removeButton(String tooltip, VoidCallback onPressed) =>
      IconButton(tooltip: tooltip, icon: const Icon(Icons.close), onPressed: onPressed);

  Widget _assetCard(_AssetRow a) => Card(
        margin: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<AssetType>(
                      initialValue: a.type,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: [
                        for (final type in AssetType.values)
                          DropdownMenuItem(
                            value: type,
                            child: Text(assetTypeLabel(type), overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) a.type = v;
                        _report();
                      },
                    ),
                  ),
                  _removeButton('Remove asset', () {
                    _assets.remove(a);
                    a.value.dispose();
                    _report();
                  }),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: NumberField(controller: a.value, label: 'Current value'),
              ),
            ],
          ),
        ),
      );

  Widget _loanCard(_LoanRow l) => Card(
        margin: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<LoanType>(
                      initialValue: l.type,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: [
                        for (final type in LoanType.values)
                          DropdownMenuItem(
                            value: type,
                            child: Text(loanTypeLabel(type), overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) l.type = v;
                        _report();
                      },
                    ),
                  ),
                  _removeButton('Remove loan', () {
                    _loans.remove(l);
                    for (final c in [l.outstanding, l.emi, l.rate]) {
                      c.dispose();
                    }
                    _report();
                  }),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  children: [
                    NumberField(controller: l.outstanding, label: 'Amount still owed'),
                    const SizedBox(height: 10),
                    NumberField(
                      controller: l.emi,
                      label: l.type == LoanType.creditCard
                          ? 'What you pay each month'
                          : 'Monthly EMI',
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: l.rate,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}(\.\d{0,2})?')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Interest rate (optional)',
                        helperText: l.type == LoanType.creditCard
                            ? 'Credit cards usually charge 36–42% a year.'
                            : 'Yearly rate from your loan statement.',
                        helperMaxLines: 2,
                        suffixText: '% a year',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
