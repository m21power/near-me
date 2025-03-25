part of 'location_bloc.dart';

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object> get props => [];
}

final class LocationInitial extends LocationState {}

final class GetCurrentLocationSuccessState extends LocationState {}

final class GetCurrentLocationFailureState extends LocationState {
  final String message;
  GetCurrentLocationFailureState(this.message);
  @override
  List<Object> get props => [message];
}

final class LocationDisabledState extends LocationState {
  final String message;
  LocationDisabledState(this.message);
  @override
  List<Object> get props => [message];
}

final class LocationOpenedState extends LocationState {
  @override
  List<Object> get props => [];
}

final class GetNearbyUsersSuccessState extends LocationState {
  final List<UserLocEntity> nearbyUsers;
  GetNearbyUsersSuccessState(this.nearbyUsers);
  @override
  List<Object> get props => [nearbyUsers];
}

final class GetNearbyUsersFailureState extends LocationState {
  final String message;
  GetNearbyUsersFailureState(this.message);
  @override
  List<Object> get props => [message];
}

final class NearbyUserFetchingState extends LocationState {
  final String message;
  NearbyUserFetchingState(this.message);
  @override
  List<Object> get props => [message];
}
