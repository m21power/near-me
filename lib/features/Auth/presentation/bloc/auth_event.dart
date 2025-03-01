part of 'auth_bloc.dart';

sealed class AuthEvent {
  const AuthEvent();
}

final class AuthRequestOtpEvent extends AuthEvent {
  final String email;
  AuthRequestOtpEvent(this.email);
}

final class AuthVerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  AuthVerifyOtpEvent(this.email, this.otp);
}

final class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String gender;
  AuthRegisterEvent(this.email, this.password, this.name, this.gender);
}

final class EmailValidationEvent extends AuthEvent {
  final String password;
  final String email;
  EmailValidationEvent(this.email, this.password);
}

final class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  LoginEvent(this.email, this.password);
}

final class EmailValForResetPasswordEvent extends AuthEvent {
  final String email;
  EmailValForResetPasswordEvent(this.email);
}

final class UpdatePasswordEvent extends AuthEvent {
  final String email;
  final String password;
  UpdatePasswordEvent(this.email, this.password);
}

final class LogOutEvent extends AuthEvent {
  LogOutEvent();
}

final class AuthLoggedInEvent extends AuthEvent {
  AuthLoggedInEvent();
}
