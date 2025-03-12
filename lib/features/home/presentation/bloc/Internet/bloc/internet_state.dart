part of 'internet_bloc.dart';

sealed class InternetState extends Equatable {
  const InternetState();

  @override
  List<Object> get props => [];
}

final class InternetInitial extends InternetState {}

final class NoInternetConnection extends InternetState {
  final String message;
  NoInternetConnection(this.message);
  @override
  List<Object> get props => [message];
}

final class InternetConnectedSuccessfully extends InternetState {}
