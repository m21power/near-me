part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthLoading extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthRequestOtpLoading extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthReqeustOtpSuccessState extends AuthState {
  final String email;
  const AuthReqeustOtpSuccessState(this.email);
  @override
  List<Object> get props => [email];
}

final class AuthReqeustOtpFailedState extends AuthState {
  final String message;
  const AuthReqeustOtpFailedState(this.message);
  @override
  List<Object> get props => [message];
}

final class AuthVerifyOtpLoading extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthVerifyOtpSuccessState extends AuthState {
  final String email;
  const AuthVerifyOtpSuccessState(this.email);
  @override
  List<Object> get props => [email];
}

final class AuthVerifyOtpFailedState extends AuthState {
  final String message;
  const AuthVerifyOtpFailedState(this.message);
  @override
  List<Object> get props => [message];
}

final class EmailValidationSuccessState extends AuthState {
  final String email;
  const EmailValidationSuccessState(this.email);
  @override
  List<Object> get props => [email];
}

final class EmailValidationFailedState extends AuthState {
  final String message;
  const EmailValidationFailedState(this.message);
  @override
  List<Object> get props => [message];
}

final class AuthRegisterSuccessState extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthRegisterFailedState extends AuthState {
  final String message;
  const AuthRegisterFailedState(this.message);
  @override
  List<Object> get props => [message];
}

final class AuthLoginSuccessState extends AuthState {
  @override
  List<Object> get props => [];
}

final class AuthLoginFailedState extends AuthState {
  final String message;
  const AuthLoginFailedState(this.message);
  @override
  List<Object> get props => [message];
}

final class EmailValForResetPasswordSuccessState extends AuthState {
  final String email;
  const EmailValForResetPasswordSuccessState(this.email);
  @override
  List<Object> get props => [email];
}

final class EmailValForResetPasswordFailedState extends AuthState {
  final String message;
  const EmailValForResetPasswordFailedState(this.message);
  @override
  List<Object> get props => [message];
}

final class UpdatePasswordSuccessState extends AuthState {
  @override
  List<Object> get props => [];
}

final class UpdatePasswordFailedState extends AuthState {
  final String message;
  const UpdatePasswordFailedState(this.message);
  @override
  List<Object> get props => [message];
}
