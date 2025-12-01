import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/dio_client.dart';

part 'friend_remote_data_source.g.dart';

@riverpod
FriendRemoteDataSource friendRemoteDataSource(FriendRemoteDataSourceRef ref) {
  return FriendRemoteDataSource(ref.watch(dioProvider));
}

class FriendRemoteDataSource {
  final Dio _dio;

  FriendRemoteDataSource(this._dio);

  /// GET /api/friends - Get friend list
  Future<List<Map<String, dynamic>>> getFriends() async {
    final response = await _dio.get('/api/friends');
    return List<Map<String, dynamic>>.from(response.data);
  }

  /// POST /api/friends - Add friend
  Future<Map<String, dynamic>> addFriend(String friendEmail) async {
    final response = await _dio.post(
      '/api/friends',
      data: {'friendEmail': friendEmail},
    );
    return response.data;
  }

  /// DELETE /api/friends/{friendId} - Remove friend
  Future<void> removeFriend(String friendId) async {
    await _dio.delete('/api/friends/$friendId');
  }

  /// POST /api/friends/requests - Send friend request
  Future<void> sendFriendRequest(String receiverEmail) async {
    await _dio.post(
      '/api/friends/requests',
      data: {'receiverEmail': receiverEmail},
    );
  }

  /// POST /api/friends/requests/{requestId}/respond - Accept/Reject request
  Future<void> respondToFriendRequest(String requestId, String status) async {
    await _dio.post(
      '/api/friends/requests/$requestId/respond',
      queryParameters: {'status': status},
    );
  }
}
