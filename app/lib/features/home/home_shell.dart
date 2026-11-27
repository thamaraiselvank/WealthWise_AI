import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../assistant/assistant_screen.dart';
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
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [
          HealthScreen(),
          GoalsScreen(),
          InvestScreen(),
          AssistantScreen(),
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
