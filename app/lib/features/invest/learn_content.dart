import 'package:material_ui/material_ui.dart';

/// Educational cards about investment CATEGORIES. Never name specific schemes.
class LearnTopic {
  final IconData icon;
  final String title;
  final String tagline;
  final String body;
  final String risk;
  final String goodFor;

  const LearnTopic({
    required this.icon,
    required this.title,
    required this.tagline,
    required this.body,
    required this.risk,
    required this.goodFor,
  });
}

const learnTopics = <LearnTopic>[
  LearnTopic(
    icon: Icons.savings_outlined,
    title: 'Emergency fund',
    tagline: 'Your financial safety net',
    body: 'Money set aside for job loss, medical bills or urgent repairs, usually '
        '6 months of expenses. It should be safe and quick to withdraw: a savings '
        'account, a sweep-in FD or a liquid mutual fund.',
    risk: 'Very low',
    goodFor: 'Emergencies only, not investing',
  ),
  LearnTopic(
    icon: Icons.account_balance_outlined,
    title: 'Fixed deposits (FDs)',
    tagline: 'Fixed interest from a bank',
    body: 'You lend money to a bank for a fixed period at a fixed interest rate. '
        'Returns are predictable but often only a little above inflation, and the '
        'interest is taxed at your income-tax slab rate.',
    risk: 'Low',
    goodFor: 'Goals 1–3 years away, parking money safely',
  ),
  LearnTopic(
    icon: Icons.stacked_line_chart,
    title: 'Index funds',
    tagline: 'Buy the whole market at low cost',
    body: 'A mutual fund that copies a market index such as the Nifty 50 or Sensex. '
        'No fund manager picks stocks, so costs are low. You get the market\'s '
        'return, including its ups and downs.',
    risk: 'High in the short term, lower over 7+ years',
    goodFor: 'Long-term goals like retirement and wealth creation',
  ),
  LearnTopic(
    icon: Icons.pie_chart_outline,
    title: 'Equity mutual funds',
    tagline: 'Professionally managed stock baskets',
    body: 'Large-cap funds invest in big, established companies; mid- and '
        'small-cap funds in smaller ones (higher growth potential, bigger swings). '
        'Flexi-cap funds mix all sizes. Investing monthly through a SIP smooths '
        'out the market\'s ups and downs.',
    risk: 'High; small-cap is the highest',
    goodFor: 'Goals 7+ years away',
  ),
  LearnTopic(
    icon: Icons.receipt_long_outlined,
    title: 'Debt funds',
    tagline: 'Funds that lend to governments and companies',
    body: 'They invest in bonds and similar instruments. Liquid and short-duration '
        'funds are steadier; long-duration funds move more when interest rates '
        'change. They add stability to a portfolio.',
    risk: 'Low to moderate',
    goodFor: 'Goals 1–5 years away, balancing equity',
  ),
  LearnTopic(
    icon: Icons.workspace_premium_outlined,
    title: 'Gold',
    tagline: 'A diversifier, not a growth engine',
    body: 'Gold often holds up when stock markets fall. Gold ETFs and gold mutual '
        'funds let you own it without storage or making charges. A small share, '
        'around 5–10%, is commonly used for diversification.',
    risk: 'Moderate',
    goodFor: 'Diversification within a long-term portfolio',
  ),
  LearnTopic(
    icon: Icons.shield_outlined,
    title: 'PPF',
    tagline: 'Government-backed long-term savings',
    body: 'The Public Provident Fund has a 15-year lock-in and a government-set '
        'interest rate that is revised quarterly. Interest is tax-free. It is a '
        'safe debt component for long-term goals.',
    risk: 'Very low',
    goodFor: 'Safe portion of retirement or education savings',
  ),
  LearnTopic(
    icon: Icons.elderly_outlined,
    title: 'NPS',
    tagline: 'National Pension System',
    body: 'A government-regulated retirement scheme that invests in a mix of equity '
        'and debt. Money is mostly locked until age 60, and part of the corpus must '
        'buy an annuity (a pension). It has some extra tax benefits.',
    risk: 'Moderate, depending on the equity share you choose',
    goodFor: 'Retirement only',
  ),
];
