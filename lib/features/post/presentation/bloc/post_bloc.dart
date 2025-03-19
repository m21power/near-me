import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/domain/usecases/create_post_usecase.dart';
import 'package:near_me/features/post/domain/usecases/get_my_post_usecase.dart';
import 'package:near_me/features/post/domain/usecases/get_user_posts.dart';

part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final CreatePostUsecase createPostUsecase;
  final GetMyPostUsecase getMyPostUsecase;

  PostBloc({
    required this.createPostUsecase,
    required this.getMyPostUsecase,
  }) : super(PostInitial()) {
    on<CreatePostEvent>(
      (event, emit) async {
        emit(PostingState());
        var result = await createPostUsecase(event.imagePath);
        result.fold((l) => emit(CreatePostFailureState(l.message)),
            (r) => emit(CreatePostSuccessState()));
      },
    );
  }
}
