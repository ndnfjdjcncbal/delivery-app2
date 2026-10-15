import 'package:equatable/equatable.dart';

class ProfileAction extends Equatable {
  final String message;
  final String? image;

  const ProfileAction({required this.message, this.image});

  @override
  List<Object?> get props => [message, image];
}
