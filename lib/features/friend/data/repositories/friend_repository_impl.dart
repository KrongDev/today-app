import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/friend.dart';
import '../../domain/repositories/friend_repository.dart';
import '../datasources/friend_remote_data_source.dart';

part 'friend_repository_impl.g.dart';

@riverpod
IFriendRepository friendRepository(FriendRepositoryRef ref) {
  return FriendRepositoryImpl(ref.watch(friendRemoteDataSourceProvider));
}

class FriendRepositoryImpl implements IFriendRepository {
  final FriendRemoteDataSource _remoteDataSource;

  FriendRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<Friend>>> getFriends() async {
    try {
      final response = await _remoteDataSource.getFriends();
      final friends = response.map((json) => Friend.fromJson(json)).toList();
      return right(friends);
    } on DioException catch (e) {
      return left(ServerFailure(e.message ?? 'Failed to get friends'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Friend>> addFriend(String friendEmail) async {
    try {
      final response = await _remoteDataSource.addFriend(friendEmail);
      final friend = Friend.fromJson(response);
      return right(friend);
    } on DioException catch (e) {
      return left(ServerFailure(e.message ?? 'Failed to add friend'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriend(String friendId) async {
    try {
      await _remoteDataSource.removeFriend(friendId);
      return right(null);
    } on DioException catch (e) {
      return left(ServerFailure(e.message ?? 'Failed to remove friend'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(String receiverEmail) async {
    try {
      await _remoteDataSource.sendFriendRequest(receiverEmail);
      return right(null);
    } on DioException catch (e) {
      return left(ServerFailure(e.message ?? 'Failed to send friend request'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequest>>> getFriendRequests() async {
    try {
      // TODO: Implement when server endpoint is ready
      return right([]);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> respondToFriendRequest(String requestId, bool accept) async {
    try {
      final status = accept ? 'ACCEPTED' : 'REJECTED';
      await _remoteDataSource.respondToFriendRequest(requestId, status);
      return right(null);
    } on DioException catch (e) {
      return left(ServerFailure(e.message ?? 'Failed to respond to request'));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Friend>>> searchFriends(String query) async {
    try {
      // TODO: Implement search endpoint
      return right([]);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
