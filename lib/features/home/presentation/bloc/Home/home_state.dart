part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class SearchUserSuccessState extends HomeState {
  final List<SearchedUser> user;
  const SearchUserSuccessState(this.user);
  @override
  List<Object> get props => [user];
}

final class SearchUserFailureState extends HomeState {
  final String message;
  const SearchUserFailureState(this.message);
  @override
  List<Object> get props => [message];
}

final class SearchLoadState extends HomeState {}

final class GetMyConnectionsLoadingState extends HomeState {}

final class GetMyConnectionsSuccessState extends HomeState {
  final List<ConnectionModel> users;
  const GetMyConnectionsSuccessState({required this.users});
  @override
  List<Object> get props => [users];
}

final class GetMyConnectionsFailureState extends HomeState {
  final String message;
  const GetMyConnectionsFailureState({required this.message});
  @override
  List<Object> get props => [message];
}
