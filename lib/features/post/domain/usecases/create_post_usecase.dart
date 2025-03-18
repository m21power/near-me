import 'package:dartz/dartz.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/post/domain/repository/post_repository.dart';

class CreatePostUsecase {
  final PostRepository postRepository;
  CreatePostUsecase({required this.postRepository});
  Future<Either<Failure, Unit>> call(String imagePath) {
    return postRepository.createPost(imagePath);
  }
}
