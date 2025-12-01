import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/friend.dart';

abstract class IFriendRepository {
  Future<Either<Failure, List<Friend>>> getFriends();
  Future<Either<Failure, Friend>> addFriend(String friendEmail);
  Future<Either<Failure, void>> removeFriend(String friendId);
  Future<Either<Failure, void>> sendFriendRequest(String receiverEmail);
  Future<Either<Failure, List<FriendRequest>>> getFriendRequests();
  Future<Either<Failure, void>> respondToFriendRequest(String requestId, bool accept);
  Future<Either<Failure, List<Friend>>> searchFriends(String query);
}
