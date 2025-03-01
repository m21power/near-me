part of 'location_bloc.dart';

sealed class LocationEvent {
  const LocationEvent();
}

final class GetCurrentLocationEvent extends LocationEvent {
  final Position position;
  GetCurrentLocationEvent(this.position);
}

final class GetCurrentLocationFailEvent extends LocationEvent {
  final String message;
  GetCurrentLocationFailEvent(this.message);
}

final class LocationDisabledEvent extends LocationEvent {
  final String message;
  LocationDisabledEvent(this.message);
}

final class LocationOpenedEvent extends LocationEvent {}
