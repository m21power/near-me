part of 'internet_bloc.dart';

sealed class InternetEvent {
  const InternetEvent();
}

class NoInternetConnection extends InternetEvent {}

class ConnectedToInternet extends InternetEvent {}
