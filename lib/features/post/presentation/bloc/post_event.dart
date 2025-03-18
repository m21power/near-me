part of 'post_bloc.dart';

sealed class PostEvent {
  const PostEvent();
}

final class CreatePostEvent extends PostEvent {
  String imagePath;
  CreatePostEvent(this.imagePath);
}

final class GetMyPostEvent extends PostEvent {}

final class GetUserPostEvent extends PostEvent {
  final String userId;
  GetUserPostEvent(this.userId);
}
