part of 'internet_bloc.dart';

sealed class InternetEvent {
  const InternetEvent();
}

class CheckInternetConnectionEvent extends InternetEvent {}
