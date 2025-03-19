import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/post/domain/usecases/get_post_i_liked_usecase.dart';
import 'package:near_me/features/post/domain/usecases/get_user_posts.dart';
import 'package:near_me/features/post/domain/usecases/like_post_usecase.dart';

import '../../../../domain/enitities/post_entities.dart';
import '../../../../domain/usecases/get_posts_usecase.dart';

part 'home_post_event.dart';
part 'home_post_state.dart';

class HomePostBloc extends Bloc<HomePostEvent, HomePostState> {
  final GetPostsUsecase getPostsUsecase;
  final GetPostILikedUsecase getPostILikedUsecase;
  final LikePostUsecase likePostUsecase;
  final GetUserPostsUsecase getUserPostsUsecase;
  List<PostModel> posts = [];
  HashSet<int> likedIds = HashSet<int>();
  List<PostModel> userPosts = [];
  DateTime? lastPostTime;
  HomePostBloc(
      {required this.getPostsUsecase,
      required this.getUserPostsUsecase,
      required this.getPostILikedUsecase,
      required this.likePostUsecase})
      : super(HomePostInitial()) {
    on<GetPostsEvent>(
      (event, emit) async {
        var lastTime;
        if (lastPostTime == null) {
          lastTime = DateTime.now();
        }
        var result = await getPostsUsecase(lastTime);
        result.fold(
            (l) => emit(GetPostsFailureState(l.message, posts, likedIds)), (r) {
          lastPostTime = r.last.createdAt;
          posts.addAll(r);
          emit(GetPostsSuccessState(posts, likedIds));
        });
      },
    );
    on<GetLikedPostsEvent>(
      (event, emit) async {
        var result = await getPostILikedUsecase();
        result.fold((l) {
          emit(GetPostsFailureState(l.message, posts, likedIds));
          emit(GetUserPostsFailureState(l.message, userPosts, likedIds));
        }, (r) {
          likedIds = r;
          emit(GetUserPostsSuccessState(userPosts, likedIds));
          emit(GetPostsSuccessState(posts, likedIds));
        });
      },
    );
    on<LikePostEvent>(
      (event, emit) async {
        var result = await likePostUsecase(event.postId);
        result.fold((l) {
          likedIds.remove(event.postId);
          emit(LikePostsFailureState(l.message, posts, likedIds));
        }, (r) {
          add(GetLikedPostsEvent());
          // emit(LikePostsSuccessState(posts, likedIds));
        });
      },
    );

    on<GetUserPostEvent>(
      (event, emit) async {
        var result = await getUserPostsUsecase(event.userId);
        result.fold(
            (l) =>
                emit(GetUserPostsFailureState(l.message, userPosts, likedIds)),
            (r) {
          userPosts = r;
          emit(GetUserPostsSuccessState(userPosts, likedIds));
        });
      },
    );
  }
}
