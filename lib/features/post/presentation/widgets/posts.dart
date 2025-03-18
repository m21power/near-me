import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/presentation/bloc/Post_bloc/bloc/home_post_bloc.dart';

class PostCard extends StatefulWidget {
  final List<PostModel> posts;
  final HashSet<int> likedPostIds;
  const PostCard({Key? key, required this.posts, required this.likedPostIds})
      : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String formatLikeCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M"; // 1.2M
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}k"; // 1.3k
    } else {
      return count.toString(); // Less than 1k
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: widget.posts.isEmpty
          ? const Center(child: Text("No posts yet"))
          : ListView.builder(
              itemCount: widget.posts.length,
              itemBuilder: (context, index) {
                final post = widget.posts[index];
                final bool isLiked = widget.likedPostIds.contains(post.postId);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          backgroundImage: post.gender == "male"
                              ? Image.asset('assets/male.png').image
                              : Image.asset('assets/woman.png').image,
                          foregroundImage: (post.profilePic != '')
                              ? CachedNetworkImageProvider(post.profilePic,
                                  cacheManager: MyCacheManager())
                              : null,
                        ),
                        title: Text(post.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text(DateFormat('hh:mm a').format(post.createdAt)),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          width: double.infinity,
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(post.postUrl,
                              cacheManager: MyCacheManager()),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : null,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (isLiked) {
                                        widget.likedPostIds.remove(post.postId);
                                        post.likeCount -= 1;
                                      } else {
                                        widget.likedPostIds.add(post.postId);
                                        post.likeCount += 1;
                                      }
                                      context
                                          .read<HomePostBloc>()
                                          .add(LikePostEvent(post.postId));
                                    });
                                  },
                                ),
                                Text(post.likeCount > 0
                                    ? formatLikeCount(post.likeCount)
                                    : ""),
                                IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("Coming soon ☺️")));
                                    }),
                                IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text("Coming soon ☺️")));
                                    }),
                              ],
                            ),
                            IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Coming soon ☺️")));
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
