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

final class UpdatingState extends ProfileState {}

final class CheckConnectionSuccessState extends ProfileState {
  final ConnectionReqModel connectionReqModel;
  CheckConnectionSuccessState(this.connectionReqModel);
}

final class ProfileFailureState extends ProfileState {
  final String message;
  ProfileFailureState(this.message);
  @override
  List<Object> get props => [message];
}

final class SendConReqSuccessState extends ProfileState {}

final class SendConReqFailuerState extends ProfileState {
  final String message;
  SendConReqFailuerState(this.message);
  @override
  List<Object> get props => [message];
}

final class AcceptConReqSuccessState extends ProfileState {}

final class AcceptConReqFailureState extends ProfileState {
  final String message;
  AcceptConReqFailureState(this.message);
  @override
  List<Object> get props => [message];
}
