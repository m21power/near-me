import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/location/domain/entities/user_entity_loc.dart';
import 'package:near_me/features/location/domain/usecases/emit_current_location_usecase.dart';
import 'package:near_me/features/location/domain/usecases/get_current_location_usecase.dart';
import 'package:near_me/features/location/domain/usecases/get_nearby_users_usecase.dart';
import 'package:near_me/features/location/domain/usecases/location_disabled_usecase.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationDisabledUsecase locationDisabledUsecase;
  final GetCurrentLocationUsecase getCurrentLocationUsecase;
  final EmitCurrentLocationUsecase emitCurrentLocationUsecase;
  final GetNearbyUsersUsecase getNearbyUsersUsecase;
  StreamSubscription<Either<Failure, Position>>? _locationStream;
  StreamSubscription<Either<Failure, Unit>>? _locationSt;
  LocationBloc({
    required this.getCurrentLocationUsecase,
    required this.emitCurrentLocationUsecase,
    required this.locationDisabledUsecase,
    required this.getNearbyUsersUsecase,
  }) : super(LocationInitial()) {
    _locationStream = getCurrentLocationUsecase().listen((position) {
      position.fold((l) => add(LocationDisabledEvent(l.message)),
          (result) => add(GetCurrentLocationEvent(result)));
    });
    // _locationSt = locationDisabledUsecase().listen((position) {
    _locationSt = locationDisabledUsecase().listen((event) {
      event.fold((l) => add(LocationDisabledEvent(l.message)),
          (_) => add(LocationOpenedEvent()));
    });
    on<GetCurrentLocationEvent>(
      (event, emit) {
        add(GetNearbyUsersEvent());
        emitCurrentLocationUsecase(event.position);
      },
    );
    on<LocationDisabledEvent>(
      (event, emit) {
        emit(LocationDisabledState(event.message));
      },
    );
    on<LocationOpenedEvent>(
      (event, emit) {
        emit(LocationOpenedState());
      },
    );
    on<GetNearbyUsersEvent>(
      (event, emit) async {
        await getNearbyUsersUsecase().then((value) {
          emit(value.fold(
            (l) => GetNearbyUsersFailureState(l.message),
            (r) => GetNearbyUsersSuccessState(r),
          ));
        });
      },
    );
  }
  @override
  Future<void> close() {
    _locationStream?.cancel();
    _locationSt?.cancel();
    return super.close();
  }
}
