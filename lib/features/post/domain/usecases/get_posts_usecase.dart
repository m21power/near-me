import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/domain/repository/post_repository.dart';

class GetPostsUsecase {
  final PostRepository postRepository;
  GetPostsUsecase({required this.postRepository});
  Future<Either<Failure, List<PostModel>>> call(DateTime lastPostTime) {
    return postRepository.getPosts(lastPostTime);
  }
}
