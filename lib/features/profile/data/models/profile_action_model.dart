import '../../domain/entities/profile_action.dart';

class ProfileActionModel extends ProfileAction {
  const ProfileActionModel({required super.message, super.image});

  factory ProfileActionModel.fromJson(Object? json) {
    if (json is! Map) {
      throw const FormatException('Unexpected response from server.');
    }

    final payload = json['data'] is Map ? json['data'] as Map : json;
    final status = json['status'] ?? payload['status'];
    final message = json['message'] ?? payload['message'];
    if (status is! String || status.toLowerCase() != 'success') {
      throw FormatException(
        message is String && message.isNotEmpty
            ? message
            : 'The server rejected the request.',
      );
    }
    if (message is! String || message.trim().isEmpty) {
      throw const FormatException('Unexpected response from server.');
    }

    final imagePayload = payload['user'] is Map
        ? payload['user'] as Map
        : payload;
    final image =
        imagePayload['user_image'] ??
        imagePayload['image'] ??
        imagePayload['image_url'] ??
        imagePayload['url'];
    return ProfileActionModel(
      message: message,
      image: image is String && image.trim().isNotEmpty ? image.trim() : null,
    );
  }

  ProfileAction toEntity() => ProfileAction(message: message, image: image);
}
