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
