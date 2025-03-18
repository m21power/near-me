import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:near_me/core/util/cache_manager.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';

Expanded myPosts(List<PostModel> posts) {
  return Expanded(
      flex: 3,
      child: posts.isEmpty
          ? const Center(
              child: Text("no posts yet"),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                print(posts[index].postUrl);
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
                            backgroundImage: posts[index].gender == "male"
                                ? Image.asset('assets/male.png').image
                                : Image.asset('assets/woman.png').image,
                            foregroundImage: (posts[index].profilePic != '')
                                ? CachedNetworkImageProvider(
                                    posts[index].profilePic,
                                    cacheManager: MyCacheManager())
                                : null),
                        title: Text(posts[index].name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('hh:mm a')
                            .format(posts[index].createdAt)),
                      ),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          // child: Image.network(
                          //   posts[index].postUrl,
                          //   fit: BoxFit.cover,
                          //   width: double.infinity,
                          // ),
                          child: Image(
                            width: double.infinity,
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                                posts[index].postUrl,
                                cacheManager: MyCacheManager()),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.favorite_border),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("Coming soon ☺️")));
                                    }),
                                IconButton(
                                    icon: const Icon(Icons.comment),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("Coming soon ☺️")));
                                    }),
                                IconButton(
                                    icon: const Icon(Icons.share),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text("Coming soon ☺️")));
                                    }),
                              ],
                            ),
                            IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text("Coming soon ☺️")));
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ));
}
