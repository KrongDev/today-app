import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend.freezed.dart';
part 'friend.g.dart';

@freezed
class Friend with _$Friend {
  const factory Friend({
    required String id,
    required String name,
    required String email,
    String? profileImageUrl,
    required DateTime createdAt,
  }) = _Friend;

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
}

@freezed
class FriendRequest with _$FriendRequest {
  const factory FriendRequest({
    required String id,
    required String senderId,
    required String senderName,
    required String senderEmail,
    required String status, // PENDING, ACCEPTED, REJECTED
    required DateTime createdAt,
  }) = _FriendRequest;

  factory FriendRequest.fromJson(Map<String, dynamic> json) => _$FriendRequestFromJson(json);
}
