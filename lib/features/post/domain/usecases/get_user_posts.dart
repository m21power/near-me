import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/domain/repository/post_repository.dart';

class GetUserPostsUsecase {
  final PostRepository postRepository;
  GetUserPostsUsecase({required this.postRepository});
  Future<Either<Failure, List<PostModel>>> call(String userId) {
    return postRepository.getUserPosts(userId);
  }
}
