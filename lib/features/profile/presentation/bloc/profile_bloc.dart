import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/profile/domain/usecases/get_user_byId_usecase.dart';
import 'package:near_me/features/profile/domain/usecases/update_profile_usecase.dart';

import '../../../Auth/domain/entities/user_entities.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserByIdUsecase getUserByIdUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  ProfileBloc({
    required this.getUserByIdUsecase,
    required this.updateProfileUsecase,
  }) : super(ProfileInitial()) {
    on<GetUserByIdEvent>((event, emit) async {
      var result = await getUserByIdUsecase(event.id);
      result.fold((l) => emit(GetUserByidFailedState(l.message)),
          (r) => emit(GetUserByIdSuccessState(r)));
    });
    on<UpdateProfileEvent>(
      (event, emit) async {
        emit(ProfileInitial());
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
  }
}
