part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class SearchUserSuccessState extends HomeState {
  final List<SearchedUser> user;
  SearchUserSuccessState(this.user);
  @override
  List<Object> get props => [user];
}

final class SearchUserFailureState extends HomeState {
  final String message;
  SearchUserFailureState(this.message);
  @override
  List<Object> get props => [message];
}

final class SearchLoadState extends HomeState {}
