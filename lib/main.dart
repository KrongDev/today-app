import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/app_router.dart';
import 'core/config/theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Korean locale data for intl package
  await initializeDateFormatting('ko_KR', null);
  runApp(const ProviderScope(child: TodayApp()));
}

class TodayApp extends ConsumerWidget {
  const TodayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'Today',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.toMaterialThemeMode(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
