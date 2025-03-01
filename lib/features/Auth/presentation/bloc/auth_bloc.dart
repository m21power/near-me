import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart';
import 'package:near_me/features/Auth/domain/usecases/email_validation_for_resetting_password_usecase.dart';
import 'package:near_me/features/profile/domain/usecases/get_user_byId_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/log_out_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/login_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/register_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/reqeust_otp_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/update_password_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/validation_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/veryif_otp_usecase.dart';

import '../../domain/entities/user_entities.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ReqeustOtpUsecase reqeustOtpUsecase;
  final VerifyOtpUsecase verifyOtpUsecase;
  final RegisterUsecase registerUsecase;
  final EmailValidationUsecase emailValidationUsecase;
  final LoginUsecase loginUsecase;
  final EmailValForResetPassUsecase emailValForResetPassUsecase;
  final UpdatePasswordUsecase updatePasswordUsecase;
  final LogOutUsecase logOutUsecase;
  final IsLoggedInUsecase isLoggedInUsecase;
  AuthBloc(
      {required this.reqeustOtpUsecase,
      required this.verifyOtpUsecase,
      required this.registerUsecase,
      required this.emailValidationUsecase,
      required this.emailValForResetPassUsecase,
      required this.loginUsecase,
      required this.updatePasswordUsecase,
      required this.logOutUsecase,
      required this.isLoggedInUsecase})
      : super(AuthInitial()) {
    on<AuthRequestOtpEvent>(
      (event, emit) async {
        var result = await reqeustOtpUsecase(event.email);
        result.fold(
          (l) {
            emit(AuthReqeustOtpFailedState(l.message));
          },
          (r) {
            emit(AuthReqeustOtpSuccessState(event.email));
          },
        );
      },
    );
    on<AuthVerifyOtpEvent>(
      (event, emit) async {
        emit(AuthLoading());
        await verifyOtpUsecase(event.email, event.otp).then(
          (result) {
            result.fold(
              (l) {
                emit(AuthVerifyOtpFailedState(l.message));
              },
              (r) {
                emit(AuthVerifyOtpSuccessState(event.email));
              },
            );
          },
        );
      },
    );
    on<EmailValidationEvent>(
      (event, emit) async {
        emit(AuthLoading());
        var result = await emailValidationUsecase(event.email, event.password);
        result.fold(
          (l) {
            emit(EmailValidationFailedState(l.message));
          },
          (r) {
            emit(EmailValidationSuccessState(event.email));
          },
        );
      },
    );
    on<AuthRegisterEvent>(
      (event, emit) async {
        emit(AuthLoading());
        var result = await registerUsecase(
            event.email, event.password, event.name, event.gender);
        result.fold(
          (l) {
            emit(AuthRegisterFailedState(l.message));
          },
          (r) {
            emit(AuthRegisterSuccessState());
          },
        );
      },
    );
    on<LoginEvent>(
      (event, emit) async {
        emit(AuthLoading());
        var result = await loginUsecase(event.email, event.password);
        result.fold(
          (l) {
            emit(AuthLoginFailedState(l.message));
          },
          (r) {
            emit(AuthLoginSuccessState());
          },
        );
      },
    );
    on<EmailValForResetPasswordEvent>(
      (event, emit) async {
        emit(AuthLoading());
        var result = await emailValForResetPassUsecase(event.email);
        result.fold(
          (l) {
            emit(EmailValForResetPasswordFailedState(l.message));
          },
          (r) {
            emit(EmailValForResetPasswordSuccessState(event.email));
          },
        );
      },
    );
    on<UpdatePasswordEvent>(
      (event, emit) async {
        emit(AuthLoading());
        var result = await updatePasswordUsecase(event.email, event.password);
        result.fold(
          (l) {
            emit(UpdatePasswordFailedState(l.message));
          },
          (r) {
            emit(UpdatePasswordSuccessState());
          },
        );
      },
    );
    on<LogOutEvent>(
      (event, emit) async {
        var result = await logOutUsecase();
        result.fold(
          (l) {
            emit(LogOutFailedState(l.message));
          },
          (r) {
            // emit(LogOutSuccessState());
          },
        );
      },
    );
    on<AuthLoggedInEvent>(
      (event, emit) async {
        var value = await isLoggedInUsecase();
        value.fold(
          (l) {
            emit(AuthLoggedInFailedState(l.message));
          },
          (r) {
            emit(AuthLoggedInSuccessState());
          },
        );
      },
    );
  }
}
