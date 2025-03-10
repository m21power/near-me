import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:image_picker/image_picker.dart';
import 'package:near_me/features/Auth/data/repository/auth_repository_impl.dart';
import 'package:near_me/features/Auth/domain/repository/auth_repository.dart';
import 'package:near_me/features/chat/data/repository/chat_repository_impl.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';
import 'package:near_me/features/chat/domain/usecases/get_chat_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_message_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/is_online_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:near_me/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:near_me/features/chat/presentation/bloc/conversation/bloc/conversation_bloc.dart';
import 'package:near_me/features/profile/data/repository/profile_repo_impl.dart';
import 'package:near_me/features/profile/domain/usecases/get_user_byId_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/login_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/register_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/reqeust_otp_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/update_password_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/validation_usecase.dart';
import 'package:near_me/features/Auth/domain/usecases/veryif_otp_usecase.dart';
import 'package:near_me/features/Auth/presentation/bloc/auth_bloc.dart';
import 'package:near_me/features/location/data/repository/location_repo_impl.dart';
import 'package:near_me/features/location/domain/repository/location_repository.dart';
import 'package:near_me/features/location/domain/usecases/emit_current_location_usecase.dart';
import 'package:near_me/features/location/domain/usecases/get_current_location_usecase.dart';
import 'package:near_me/features/location/domain/usecases/location_disabled_usecase.dart';
import 'package:near_me/features/location/presentation/bloc/location_bloc.dart';
import 'package:near_me/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import 'core/image_picker/image_picker.dart';
import 'core/network/network_info.dart';
import 'features/Auth/domain/usecases/email_validation_for_resetting_password_usecase.dart';
import 'features/Auth/domain/usecases/log_out_usecase.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'package:http/http.dart' as http;

final sl = get_it.GetIt.instance;
Future<void> init() async {
  //websocket
  var channel =
      IOWebSocketChannel.connect('ws://near-me-backend-new.onrender.com/ws');
  sl.registerLazySingleton<IOWebSocketChannel>(() => channel);

  //firebase app check

  //core
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton<ImagePicker>(() => ImagePicker());
  sl.registerLazySingleton<ImagePath>(() => ImagePathImpl(imagePicker: sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<FirebaseAppCheck>(() => FirebaseAppCheck.instance);
  await sl<FirebaseAppCheck>().activate(androidProvider: AndroidProvider.debug);
  sl.registerLazySingleton<FlutterSecureStorage>(() => FlutterSecureStorage());
  //auth
  //repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl(), sl(), sl(), sl()));
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
  sl.registerLazySingleton<LogOutUsecase>(() => LogOutUsecase(sl()));
  sl.registerLazySingleton<IsLoggedInUsecase>(() => IsLoggedInUsecase(sl()));

  //bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(
      isLoggedInUsecase: sl(),
      reqeustOtpUsecase: sl(),
      verifyOtpUsecase: sl(),
      registerUsecase: sl(),
      emailValidationUsecase: sl(),
      loginUsecase: sl(),
      emailValForResetPassUsecase: sl(),
      updatePasswordUsecase: sl(),
      logOutUsecase: sl()));

  // Location

  //repository
  sl.registerLazySingleton<LocationRepository>(() => LocationRepoImpl(
        channel: sl(),
        secureStorage: sl(),
      ));

  //usecases
  sl.registerLazySingleton<GetCurrentLocationUsecase>(
    () => GetCurrentLocationUsecase(locationRepository: sl()),
  );
  sl.registerLazySingleton<EmitCurrentLocationUsecase>(
    () => EmitCurrentLocationUsecase(locationRepository: sl()),
  );
  sl.registerLazySingleton<LocationDisabledUsecase>(
    () => LocationDisabledUsecase(locationRepository: sl()),
  );
  //bloc
  sl.registerFactory<LocationBloc>(
    () => LocationBloc(
      getCurrentLocationUsecase: sl(),
      emitCurrentLocationUsecase: sl(),
      locationDisabledUsecase: sl(),
    ),
  );

  //profile
  //repository
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepoImpl(
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
        sl(),
      ));

  //usecases
  sl.registerLazySingleton<GetUserByIdUsecase>(
      () => GetUserByIdUsecase(profileRepository: sl()));
  sl.registerLazySingleton<UpdateProfileUsecase>(
      () => UpdateProfileUsecase(profileRepository: sl()));
  //bloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      getUserByIdUsecase: sl(),
      updateProfileUsecase: sl(),
    ),
  );

  // chat
  // repository
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(
        sl(),
        sl(),
        sl(),
        sl(),
      ));

  //usecases
  sl.registerLazySingleton<SendMessageUsecase>(
      () => SendMessageUsecase(chatRepository: sl()));
  sl.registerLazySingleton<IsOnlineUsecase>(
      () => IsOnlineUsecase(chatRepository: sl()));
  sl.registerLazySingleton<GetChatUsecase>(
    () => GetChatUsecase(chatRepository: sl()),
  );
  sl.registerLazySingleton<GetMessageUsecase>(
    () => GetMessageUsecase(chatRepository: sl()),
  );
//bloc
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      isOnlineUsecase: sl(),
      getChatUsecase: sl(),
    ),
  );

  //converstation
  sl.registerFactory<ConversationBloc>(() => ConversationBloc(
        getMessageUsecase: sl(),
        sendMessageUsecase: sl(),
      ));
}
