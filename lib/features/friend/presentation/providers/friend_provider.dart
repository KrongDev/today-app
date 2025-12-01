import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/friend.dart';
import '../../data/repositories/friend_repository_impl.dart';

part 'friend_provider.g.dart';

@riverpod
class FriendList extends _$FriendList {
  @override
  Future<List<Friend>> build() async {
    final repository = ref.watch(friendRepositoryProvider);
    final result = await repository.getFriends();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (friends) => friends,
    );
  }

  Future<void> addFriend(String email) async {
    state = const AsyncValue.loading();
    final repository = ref.read(friendRepositoryProvider);
    final result = await repository.addFriend(email);
    
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (_) => ref.invalidateSelf(),
    );
  }

  Future<void> removeFriend(String friendId) async {
    final repository = ref.read(friendRepositoryProvider);
    final result = await repository.removeFriend(friendId);
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
  }
}

@riverpod
class FriendRequestList extends _$FriendRequestList {
  @override
  Future<List<FriendRequest>> build() async {
    final repository = ref.watch(friendRepositoryProvider);
    final result = await repository.getFriendRequests();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (requests) => requests,
    );
  }

  Future<void> respondToRequest(String requestId, bool accept) async {
    final repository = ref.read(friendRepositoryProvider);
    final result = await repository.respondToFriendRequest(requestId, accept);
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) => ref.invalidateSelf(),
    );
  }
}

@riverpod
class FriendSearch extends _$FriendSearch {
  @override
  Future<List<Friend>> build(String query) async {
    if (query.isEmpty) return [];
    
    final repository = ref.watch(friendRepositoryProvider);
    final result = await repository.searchFriends(query);
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (friends) => friends,
    );
  }

  Future<void> sendFriendRequest(String email) async {
    final repository = ref.read(friendRepositoryProvider);
    final result = await repository.sendFriendRequest(email);
    
    result.fold(
      (failure) => throw Exception(failure.message),
      (_) {}, // Success
    );
  }
}
