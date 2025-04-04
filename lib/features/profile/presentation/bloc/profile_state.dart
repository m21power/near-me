part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class GetUserByIdSuccessState extends ProfileState {
  final UserModel userModel;
  const GetUserByIdSuccessState(this.userModel);
  @override
  List<Object> get props => [userModel];
}

final class GetUserByidFailedState extends ProfileState {
  final String message;
  const GetUserByidFailedState(this.message);
  @override
  List<Object> get props => [message];
}

final class UpdateProfileSuccessState extends ProfileState {
  final UserModel userModel;
  const UpdateProfileSuccessState(this.userModel);
  @override
  List<Object> get props => [userModel];
}

final class UpdateProfileFailedState extends ProfileState {
  final String message;
  const UpdateProfileFailedState(this.message);
  @override
  List<Object> get props => [message];
}
