import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/profile/domain/entities/profile_entity.dart';
import 'package:near_me/features/profile/domain/usecases/accept_conn_request_usecase.dart';
import 'package:near_me/features/profile/domain/usecases/check_connection_request.dart';
import 'package:near_me/features/profile/domain/usecases/get_user_byId_usecase.dart';
import 'package:near_me/features/profile/domain/usecases/send_connection_request_usecase.dart';
import 'package:near_me/features/profile/domain/usecases/update_profile_usecase.dart';

import '../../../Auth/domain/entities/user_entities.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserByIdUsecase getUserByIdUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  final CheckConnectionRequestUsecase checkConnectionRequestUsecase;
  final SendConnectionRequestUsecase sendConnectionRequestUsecase;
  final AcceptConnRequestUsecase acceptConnRequestUsecase;
  ProfileBloc(
      {required this.getUserByIdUsecase,
      required this.updateProfileUsecase,
      required this.acceptConnRequestUsecase,
      required this.sendConnectionRequestUsecase,
      required this.checkConnectionRequestUsecase})
      : super(ProfileInitial()) {
    on<GetUserByIdEvent>((event, emit) async {
      emit(ProfileInitial());
      var result = await getUserByIdUsecase(event.id);
      result.fold((l) => emit(GetUserByidFailedState(l.message)),
          (r) => emit(GetUserByIdSuccessState(r)));
    });
    on<UpdateProfileEvent>(
      (event, emit) async {
        emit(UpdatingState());
        var user = await updateProfileUsecase(
            event.profileImage,
            event.backgroundImage,
            event.fullName,
            event.bio,
            event.university,
            event.major);
        user.fold(
          (l) => emit(UpdateProfileFailedState(l.message)),
          (r) => emit(UpdateProfileSuccessState(r)),
        );
      },
    );
    on<CheckConnectionEvent>(
      (event, emit) async {
        emit(UpdatingState());
        var result = await checkConnectionRequestUsecase(event.userId);
        result.fold((l) => emit(ProfileFailureState(l.message)),
            (r) => emit(CheckConnectionSuccessState(r)));
      },
    );
    on<SendConnectionRequest>(
      (event, emit) async {
        var result = await sendConnectionRequestUsecase(event.userId);
        result.fold(
            (l) => emit(SendConReqFailuerState(
                'Failed to send connection request. Please try again.')),
            (r) => emit(SendConReqSuccessState()));
      },
    );
    on<AcceptConReqEvent>(
      (event, emit) async {
        var result = await acceptConnRequestUsecase(event.userId);
        result.fold((l) => emit(AcceptConReqFailureState(l.message)),
            (r) => emit(AcceptConReqSuccessState()));
      },
    );
  }
}
