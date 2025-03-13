part of 'home_bloc.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class SearchUserEvent extends HomeEvent {
  final String name;
  SearchUserEvent(this.name);
}
