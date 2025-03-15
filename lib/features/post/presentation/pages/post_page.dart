import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

import 'package:near_me/features/home/presentation/bloc/Internet/bloc/internet_bloc.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      'assets/image.png',
      'assets/image8.jpg',
      'assets/image9.jpg',
      'assets/image10.jpg',
      'assets/image1.jpg',
      'assets/image2.jpg',
      'assets/image3.jpg',
      'assets/image4.jpg',
      'assets/image5.jpg',
      'assets/image6.jpg',
      'assets/image7.jpg',
    ];

    final List<String> users = [
      'Alice',
      'Bob',
      'Charlie',
      'David',
      'Eve',
      'Frank',
      'Grace',
      'Hannah',
      'Isaac',
      'Jack'
    ];
    final backImage = ['assets/male.png', 'assets/woman.png'];
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final random = Random();
                final image = images[index];
                final user = users[random.nextInt(users.length)];

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
                          child: Image.asset(backImage[random.nextInt(2)]),
                        ),
                        title: Text(user,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Just now'),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          image,
                          fit: BoxFit.cover,
                          width: double.infinity,
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
            ),
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
      ),
    );
  }
}
