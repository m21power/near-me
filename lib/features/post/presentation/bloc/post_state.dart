part of 'post_bloc.dart';

sealed class PostState extends Equatable {
  const PostState();
  @override
  List<Object> get props => [];
}

final class PostInitial extends PostState {}

final class CreatePostSuccessState extends PostState {}

class CreatePostFailureState extends PostState {
  final String message;
  const CreatePostFailureState(this.message);
  @override
  List<Object> get props => [message];
}

class PostingState extends PostState {}

class GetMyPostSuccessState extends PostState {
  final List<PostModel> posts;
  GetMyPostSuccessState(this.posts);
  @override
  List<Object> get props => [posts];
}

class GetMyPostFailureState extends PostState {
  final String message;
  GetMyPostFailureState(this.message);
  @override
  List<Object> get props => [message];
}

class GetMyPostsInitialState extends PostState {}

class GetUserPostsInitialState extends PostState {}

class GetUserPostsSuccessState extends PostState {
  final List<PostModel> posts;
  GetUserPostsSuccessState(this.posts);
  @override
  List<Object> get props => [posts];
}

class GetUserPostsFailureState extends PostState {
  final String message;
  GetUserPostsFailureState(this.message);
  @override
  List<Object> get props => [message];
}
