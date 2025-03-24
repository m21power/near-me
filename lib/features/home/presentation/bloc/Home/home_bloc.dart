import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:near_me/features/home/domain/entities/connection_model.dart';
import 'package:near_me/features/home/domain/entities/entity.dart';
import 'package:near_me/features/home/domain/usecases/get_my_connection_usecase.dart';
import 'package:near_me/features/home/domain/usecases/seach_user_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SearchUserUsecase searchUserUsecase;
  final GetMyConnectionUsecase getMyConnectionUsecase;
  HomeBloc({
    required this.searchUserUsecase,
    required this.getMyConnectionUsecase,
  }) : super(HomeInitial()) {
    on<SearchUserEvent>(
      (event, emit) async {
        emit(SearchLoadState());
        var value = await searchUserUsecase(event.name);
        value.fold((l) => emit(SearchUserFailureState(l.message)),
            (r) => emit(SearchUserSuccessState(r)));
      },
    );
    on<GetMyConnectionsEvent>(
      (event, emit) async {
        emit(GetMyConnectionsLoadingState());
        var result = await getMyConnectionUsecase();
        result.fold(
            (l) => emit(GetMyConnectionsFailureState(message: l.message)),
            (r) => emit(GetMyConnectionsSuccessState(users: r)));
      },
    );
  }
}
