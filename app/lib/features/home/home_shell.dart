import 'package:material_ui/material_ui.dart';

import '../goals/goals_screen.dart';
import '../health/health_screen.dart';
import '../invest/invest_screen.dart';
import 'coming_soon_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Financial health', 'My goals', 'Invest & learn', 'Ask AI', 'Progress'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [
          HealthScreen(),
          GoalsScreen(),
          InvestScreen(),
          ComingSoonScreen(
            icon: Icons.chat_bubble_outline,
            title: 'AI financial assistant',
            description:
                'Ask questions like "Can I retire at 50?" and get answers based on '
                'your own numbers, with the calculations shown.',
            phase: 'Phase 2',
          ),
          ComingSoonScreen(
            icon: Icons.show_chart,
            title: 'Progress tracker',
            description:
                'Monthly check-ins, goal progress charts and net worth over time.',
            phase: 'Phase 3',
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Health'),
          NavigationDestination(icon: Icon(Icons.flag_outlined), selectedIcon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Invest'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Ask AI'),
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Progress'),
        ],
      ),
    );
  }
}
