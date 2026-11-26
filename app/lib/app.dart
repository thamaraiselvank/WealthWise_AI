import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/goals/goal_detail_screen.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'state/app_state.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      final onboarded = ref.read(appStateProvider).profile != null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !atOnboarding) return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeShell(),
        routes: [
          GoRoute(
            path: 'goal/:id',
            builder: (context, state) =>
                GoalDetailScreen(goalId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});

class WealthWiseApp extends ConsumerWidget {
  const WealthWiseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const seed = Color(0xFF0F766E); // teal: calm, trustworthy
    return MaterialApp.router(
      title: 'WealthWise AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
