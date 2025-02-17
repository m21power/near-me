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
  AuthRegisterEvent(this.email, this.password, this.name);
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
