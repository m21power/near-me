import 'dart:collection';

import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';

abstract class PostRepository {
  Future<Either<Failure, Unit>> createPost(String imagePath);
  Future<Either<Failure, List<PostModel>>> getMyPosts();
  Future<Either<Failure, List<PostModel>>> getPosts(DateTime lastPostTime);
  Future<Either<Failure, List<PostModel>>> getUserPosts(String userId);
  Future<Either<Failure, HashSet<int>>> getPostILiked();
  Future<Either<Failure, int>> likePost(int postId);
}
