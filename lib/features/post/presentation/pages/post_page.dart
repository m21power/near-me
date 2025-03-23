import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:near_me/features/home/presentation/bloc/Internet/bloc/internet_bloc.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';
import 'package:near_me/features/post/presentation/widgets/posts.dart';

class PostPage extends StatefulWidget {
  PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<PostModel> posts = [];
  HashSet<int> likedPostIds = HashSet<int>();
  bool isLoading = false;
  Future<void> _onRefresh() async {
    print("heeeeeeeeeeeeeeeeeeeeeeeere");
    context.read<HomePostBloc>().add(GetPostsEvent());
    context.read<HomePostBloc>().add(GetLikedPostsEvent());
  }

  @override
  void initState() {
    context.read<HomePostBloc>().add(GetPost());
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        body: BlocConsumer<HomePostBloc, HomePostState>(
          listener: (context, postState) {
            if (postState is GetPostLoadingState ||
                postState is HomePostInitial) {
              isLoading = true;
            } else {
              isLoading = false;
            }
            if (postState is GetPostsFailureState) {
              showError(postState.message);
            }
            if (postState is LikePostsFailureState) {
              showError(postState.message);
            }
            print("this post");
            print(posts);
          },
          builder: (context, postState) {
            print("*************************");
            print(postState);
            print(isLoading);
            if (postState is GetPostsSuccessState) {
              posts = postState.posts;
              if (postState.likedIds.isNotEmpty) {
                likedPostIds = postState.likedIds;
              }
            }
            if (postState is GetPostsFailureState) {
              if (postState.posts.isNotEmpty) {
                posts = postState.posts;
              }
              if (postState.likedIds.isNotEmpty) {
                likedPostIds = postState.likedIds;
              }
            }
            if (postState is LikePostsSuccessState) {
              posts = postState.posts;
              likedPostIds = postState.likedIds;
            }
            if (postState is LikePostsFailureState) {
              posts = postState.posts;
              likedPostIds = postState.likedIds;
            }
            return Column(
              children: [
                PostCard(
                  posts: posts,
                  likedPostIds: likedPostIds,
                  isLoading: isLoading,
                ),
                BlocBuilder<InternetBloc, InternetState>(
                  builder: (context, intState) {
                    if (intState is NoInternetConnectionState) {
                      return const Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 10),
                              Text('Connecting...'),
                            ],
                          ),
                        ),
                      );
                    }
                    return SizedBox();
                  },
                )
              ],
            );
          },
        ),
      ),
    );
  }

  showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
}
