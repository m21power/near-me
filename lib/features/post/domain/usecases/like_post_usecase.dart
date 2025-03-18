import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/post/domain/repository/post_repository.dart';

class LikePostUsecase {
  final PostRepository postRepository;
  LikePostUsecase({required this.postRepository});
  Future<Either<Failure, int>> call(int postId) {
    return postRepository.likePost(postId);
  }
}
