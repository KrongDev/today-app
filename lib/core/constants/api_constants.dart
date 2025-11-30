class ApiConstants {
  static const String baseUrl = 'https://api.today-app.com/api/v1';
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  // Auth
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';

  // Schedule
  static const String schedules = '/schedules';
  static const String syncSchedules = '/schedules/sync';
  static const String availability = '/schedules/availability';

  // Friends
  static const String friends = '/friends';
  static const String friendRequests = '/friends/request';
}

class StorageConstants {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String lastSyncTime = 'last_sync_time';
}
