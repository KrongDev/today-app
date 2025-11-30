import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/schedule/presentation/screens/calendar_screen.dart';
import '../../features/schedule/presentation/screens/schedule_form_screen.dart';
import '../../features/schedule/presentation/screens/schedule_detail_screen.dart';
import '../../features/schedule/domain/entities/schedule_entity.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/friend/presentation/screens/friend_list_screen.dart';
import '../../features/friend/presentation/screens/friend_search_screen.dart';
import '../../features/friend/presentation/screens/friend_request_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // Main Calendar Screen
      GoRoute(
        path: '/',
        builder: (context, state) => const CalendarScreen(),
      ),
      
      // Schedule Routes
      GoRoute(
        path: '/schedule/new',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is ScheduleEntity) {
            return ScheduleFormScreen(schedule: extra);
          } else if (extra is DateTime) {
            return ScheduleFormScreen(initialDate: extra);
          }
          return const ScheduleFormScreen();
        },
      ),
      GoRoute(
        path: '/schedule/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ScheduleDetailScreen(scheduleId: id);
        },
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Settings Route
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Friend Routes
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendListScreen(),
      ),
      GoRoute(
        path: '/friends/search',
        builder: (context, state) => const FriendSearchScreen(),
      ),
      GoRoute(
        path: '/friends/requests',
        builder: (context, state) => const FriendRequestScreen(),
      ),
    ],
  );
}
