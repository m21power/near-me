part of 'profile_bloc.dart';

sealed class ProfileEvent {
  const ProfileEvent();
}

final class GetUserByIdEvent extends ProfileEvent {
  final String id;
  GetUserByIdEvent(this.id);
}

final class UpdateProfileEvent extends ProfileEvent {
  final String? fullName;
  final String? bio;
  final String? university;
  final String? major;
  final String? profileImage;
  final String? backgroundImage;
  UpdateProfileEvent(
      {required this.backgroundImage,
      required this.bio,
      required this.fullName,
      required this.major,
      required this.profileImage,
      required this.university});
}
