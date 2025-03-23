import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart' as get_it;
import 'package:image_picker/image_picker.dart';
import 'package:near_me/features/Auth/data/repository/auth_repository_impl.dart';
import 'package:near_me/features/Auth/domain/repository/auth_repository.dart';
import 'package:near_me/features/chat/data/repository/chat_repository_impl.dart';
import 'package:near_me/features/chat/domain/repository/chat_repository.dart';
import 'package:near_me/features/chat/domain/usecases/get_chat_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_connected_users_id_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_message_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/get_users_status.dart';
import 'package:near_me/features/chat/domain/usecases/mark_message_usecase.dart';
import 'package:near_me/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:near_me/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:near_me/features/chat/presentation/bloc/conversation/bloc/conversation_bloc.dart';
import 'package:near_me/features/home/data/repository/local/listen_conn_status.dart';
import 'package:near_me/features/home/data/repository/local/local_db.dart';
import 'package:near_me/features/home/data/repository/remote/home_repo_impl.dart';
import 'package:near_me/features/home/domain/repository/home_repository.dart';
import 'package:near_me/features/home/domain/usecases/check_internet_connection.dart';
import 'package:near_me/features/home/domain/usecases/get_my_connection_usecase.dart';
import 'package:near_me/features/home/domain/usecases/seach_user_usecase.dart';
import 'package:near_me/features/home/presentation/bloc/Home/home_bloc.dart';
import 'package:near_me/features/home/presentation/bloc/Internet/bloc/internet_bloc.dart';
import 'package:near_me/features/notification/data/repository/notification_repo_impl.dart';
import 'package:near_me/features/notification/domain/repository/notification_repo.dart';
import 'package:near_me/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:near_me/features/notification/domain/usecases/mark_notification_as_seen.dart';
import 'package:near_me/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:near_me/features/post/data/repository/post_repo_impl.dart';
import 'package:near_me/features/post/domain/repository/post_repository.dart';
import 'package:near_me/features/post/domain/usecases/create_post_usecase.dart';
import 'package:near_me/features/post/domain/usecases/get_my_post_usecase.dart';
import 'package:near_me/features/post/domain/usecases/get_post_i_liked_usecase.dart';
import 'package:near_me/features/post/domain/usecases/get_posts_usecase.dart';
import 'package:near_me/features/post/domain/usecases/get_user_posts.dart';
import 'package:near_me/features/post/domain/usecases/like_post_usecase.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';
import 'package:near_me/features/post/presentation/bloc/post_bloc.dart';
import 'package:near_me/features/profile/data/repository/profile_repo_impl.dart';
import 'package:near_me/features/profile/domain/usecases/accept_conn_request_usecase.dart';
import 'package:near_me/features/profile/domain/usecases/check_connection_request.dart';
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
import 'package:near_me/features/profile/domain/usecases/send_connection_request_usecase.dart';
import 'package:near_me/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';

import 'core/image_picker/image_picker.dart';
import 'core/network/network_info.dart';
import 'features/Auth/domain/usecases/email_validation_for_resetting_password_usecase.dart';
import 'features/Auth/domain/usecases/log_out_usecase.dart';
import 'features/location/domain/usecases/get_nearby_users_usecase.dart';
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
  sl.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);
  sl.registerLazySingleton<ConnectionStatusListener>(
    () => ConnectionStatusListener(
        localDb: sl(), realTimeDb: sl(), firestore: sl()),
  );
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
  sl.registerLazySingleton<FirebaseDatabase>(() => FirebaseDatabase.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  //auth
  //repository
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));
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
      firestore: sl(),
      client: sl(),
      networkInfo: sl()));

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
  sl.registerLazySingleton<GetNearbyUsersUsecase>(
    () => GetNearbyUsersUsecase(locationRepository: sl()),
  );
  //bloc
  sl.registerFactory<LocationBloc>(
    () => LocationBloc(
        getCurrentLocationUsecase: sl(),
        emitCurrentLocationUsecase: sl(),
        locationDisabledUsecase: sl(),
        getNearbyUsersUsecase: sl()),
  );

  //profile
  //repository
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepoImpl(sl(), sl(), sl(), sl(), sl(), sl(), sl(), sl()));

  //usecases
  sl.registerLazySingleton<GetUserByIdUsecase>(
      () => GetUserByIdUsecase(profileRepository: sl()));
  sl.registerLazySingleton<UpdateProfileUsecase>(
      () => UpdateProfileUsecase(profileRepository: sl()));
  sl.registerLazySingleton<CheckConnectionRequestUsecase>(
      () => CheckConnectionRequestUsecase(profileRepository: sl()));
  sl.registerLazySingleton<SendConnectionRequestUsecase>(
      () => SendConnectionRequestUsecase(profileRepository: sl()));
  sl.registerLazySingleton<AcceptConnRequestUsecase>(
      () => AcceptConnRequestUsecase(profileRepository: sl()));
  //bloc
  sl.registerFactory<ProfileBloc>(
    () => ProfileBloc(
        getUserByIdUsecase: sl(),
        updateProfileUsecase: sl(),
        checkConnectionRequestUsecase: sl(),
        acceptConnRequestUsecase: sl(),
        sendConnectionRequestUsecase: sl()),
  );

  // chat
  // repository
  sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(sl(), sl(), sl(), sl(), sl()));

  //usecases
  sl.registerLazySingleton<SendMessageUsecase>(
      () => SendMessageUsecase(chatRepository: sl()));
  sl.registerLazySingleton<GetChatUsecase>(
    () => GetChatUsecase(chatRepository: sl()),
  );
  sl.registerLazySingleton<GetMessageUsecase>(
    () => GetMessageUsecase(chatRepository: sl()),
  );
  sl.registerLazySingleton<MarkMessageUsecase>(
      () => MarkMessageUsecase(chatRepository: sl()));
  sl.registerLazySingleton<GetUsersStatusUsecase>(
      () => GetUsersStatusUsecase(chatRepository: sl()));
  sl.registerLazySingleton<GetConnectedUsersIdUsecase>(
      () => GetConnectedUsersIdUsecase(chatRepository: sl()));
//bloc
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(
      getChatUsecase: sl(),
    ),
  );

  //converstation
  sl.registerFactory<ConversationBloc>(
    () => ConversationBloc(
      getMessageUsecase: sl(),
      sendMessageUsecase: sl(),
      markMessageUsecase: sl(),
      getUsersStatusUsecase: sl(),
      getConnectedUsersIdUsecase: sl(),
    ),
  );

  //Internet bloc
  sl.registerLazySingleton<CheckInternetConnectionUsecase>(
      () => CheckInternetConnectionUsecase(homeRepository: sl()));
  sl.registerFactory<InternetBloc>(
      () => InternetBloc(checkInternetConnectionUsecase: sl()));

  //Homebloc

  //repository
  sl.registerLazySingleton<HomeRepository>(
      () => HomeRepoImpl(firestore: sl(), networkInfo: sl(), localDb: sl()));
  //usecase
  sl.registerLazySingleton<SearchUserUsecase>(
      () => SearchUserUsecase(homeRepository: sl()));
  sl.registerLazySingleton<GetMyConnectionUsecase>(
    () => GetMyConnectionUsecase(homeRepository: sl()),
  );
  //bloc
  sl.registerFactory<HomeBloc>(
    () => HomeBloc(searchUserUsecase: sl(), getMyConnectionUsecase: sl()),
  );

  //NOTIFICATION
  //repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepoImpl(sl(), sl()),
  );
  //usecase
  sl.registerLazySingleton<GetNotificationsUsecase>(
    () => GetNotificationsUsecase(notificationRepository: sl()),
  );
  sl.registerLazySingleton<MarkNotificationAsSeenUsecase>(
    () => MarkNotificationAsSeenUsecase(notificationRepository: sl()),
  );
  //bloc
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
        getNotificationsUsecase: sl(), markNotificationAsSeenUsecase: sl()),
  );

  // POST FEATURE
  //repostiroy
  sl.registerLazySingleton<PostRepository>(
    () => PostRepoImpl(sl()),
  );
  //usecase
  sl.registerLazySingleton<CreatePostUsecase>(
      () => CreatePostUsecase(postRepository: sl()));
  sl.registerLazySingleton<GetMyPostUsecase>(
    () => GetMyPostUsecase(postRepository: sl()),
  );
  sl.registerLazySingleton<GetPostsUsecase>(
    () => GetPostsUsecase(postRepository: sl()),
  );
  sl.registerLazySingleton<GetUserPostsUsecase>(
    () => GetUserPostsUsecase(postRepository: sl()),
  );
  sl.registerLazySingleton<GetPostILikedUsecase>(
    () => GetPostILikedUsecase(postRepository: sl()),
  );
  sl.registerLazySingleton<LikePostUsecase>(
    () => LikePostUsecase(postRepository: sl()),
  );
  // bloc
  sl.registerFactory<PostBloc>(
    () => PostBloc(
      createPostUsecase: sl(),
      getMyPostUsecase: sl(),
    ),
  );
  //HOMEBLOC
  sl.registerFactory<HomePostBloc>(
    () => HomePostBloc(
        getPostsUsecase: sl(),
        getPostILikedUsecase: sl(),
        getUserPostsUsecase: sl(),
        likePostUsecase: sl()),
  );
}
