part of 'home_post_bloc.dart';

sealed class HomePostEvent {
  const HomePostEvent();
}

final class GetPostsEvent extends HomePostEvent {
  GetPostsEvent();
}

final class GetLikedPostsEvent extends HomePostEvent {}

final class LikePostEvent extends HomePostEvent {
  final int postId;
  LikePostEvent(this.postId);
}

final class GetUserPostEvent extends HomePostEvent {
  final String userId;
  GetUserPostEvent(this.userId);
}

final class GetPost extends HomePostEvent {}
