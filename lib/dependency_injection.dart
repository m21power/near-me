import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:near_me/features/Auth/data/repository/auth_repository_impl.dart';
import 'package:near_me/features/Auth/domain/repository/auth_repository.dart';
import 'package:near_me/features/Auth/domain/usecases/login_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/register_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/reqeust_otp_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/update_password_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/validation_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/veryif_otp_usecase.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/image_picker/image_picker.dart';
import 'core/network/network_info.dart';
import 'features/Auth/domain/usecases/email_validation_for_resetting_password_usecase.dart';

final sl = get_it.GetIt.instance;
Future<void> init() async {
  //firebase app check

  //core
  sl.registerLazySingleton<ImagePath>(() => ImagePathImpl(imagePicker: sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FirebaseAppCheck>(() => FirebaseAppCheck.instance);
  sl<FirebaseAppCheck>().activate(androidProvider: AndroidProvider.debug);
  //auth
  //repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl(), sl(), sl()));
  //usecases
  sl.registerLazySingleton<ReqeustOtpUsecase>(() => ReqeustOtpUsecase(sl()));
  sl.registerLazySingleton<VerifyOtpUsecase>(() => VerifyOtpUsecase(sl()));
  sl.registerLazySingleton<RegisterUsecase>(() => RegisterUsecase(sl()));
  sl.registerLazySingleton<EmailValidationUsecase>(
      () => EmailValidationUsecase(sl()));
  sl.registerLazySingleton<LoginUsecase>(() => LoginUsecase(sl()));
  sl.registerLazySingleton<EmailValForResetPassUsecase>(
      () => EmailValForResetPassUsecase(sl()));
  sl.registerLazySingleton<UpdatePasswordUsecase>(
      () => UpdatePasswordUsecase(sl()));

  //bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(
        reqeustOtpUsecase: sl(),
        verifyOtpUsecase: sl(),
        registerUsecase: sl(),
        emailValidationUsecase: sl(),
        loginUsecase: sl(),
        emailValForResetPassUsecase: sl(),
        updatePasswordUsecase: sl(),
      ));
}
