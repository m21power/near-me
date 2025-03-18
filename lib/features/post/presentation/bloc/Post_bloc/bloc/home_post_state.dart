part of 'home_post_bloc.dart';

sealed class HomePostState extends Equatable {
  const HomePostState();

  @override
  List<Object> get props => [];
}

final class HomePostInitial extends HomePostState {}

class GetPostsInitialState extends HomePostState {}

class GetPostsSuccessState extends HomePostState {
  final List<PostModel> posts;
  final HashSet<int> likedIds;
  GetPostsSuccessState(this.posts, this.likedIds);
  @override
  List<Object> get props => [posts, likedIds];
}

class GetPostsFailureState extends HomePostState {
  final String message;
  final List<PostModel> posts;
  final HashSet<int> likedIds;
  GetPostsFailureState(this.message, this.posts, this.likedIds);
  @override
  List<Object> get props => [message, posts, likedIds];
}

class LikePostsSuccessState extends HomePostState {
  final List<PostModel> posts;
  final HashSet<int> likedIds;
  LikePostsSuccessState(this.posts, this.likedIds);
  @override
  List<Object> get props => [posts, likedIds];
}

class LikePostsFailureState extends HomePostState {
  final String message;
  final List<PostModel> posts;
  final HashSet<int> likedIds;
  LikePostsFailureState(this.message, this.posts, this.likedIds);
  @override
  List<Object> get props => [message, posts, likedIds];
}
