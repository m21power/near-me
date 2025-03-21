import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerScreenPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => ShimmerPost(),
      ),
    );
  }
}

class ShimmerPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10),
                // Username Placeholder
                Container(
                  width: 100,
                  height: 15,
                  color: isDarkMode ? Colors.black : Colors.grey[400],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 300,
            color: isDarkMode ? Colors.black : Colors.grey[400],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Icon(Icons.favorite,
                    size: 30,
                    color: isDarkMode ? Colors.black : Colors.grey[500]),
                SizedBox(width: 15),
                Icon(Icons.comment,
                    size: 30,
                    color: isDarkMode ? Colors.black : Colors.grey[500]),
                SizedBox(width: 15),
                Icon(Icons.share,
                    size: 30,
                    color: isDarkMode ? Colors.black : Colors.grey[500]),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ChatShimmerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 20, // Number of chat rows
        itemBuilder: (context, index) => ChatShimmerRow(),
      ),
    );
  }
}

class ChatShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode
          ? Colors.grey[800]!
          : Colors.grey[300]!, // Dark & Light Mode
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          children: [
            // 🔵 Profile Picture
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black
                    : Colors.grey[400], // Adjusted for Light Mode
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10),

            // 📄 Username & Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Username
                  Container(
                    width: 150,
                    height: 15,
                    color: isDarkMode
                        ? Colors.black
                        : Colors.grey[400], // Adjusted for Light Mode
                  ),
                  SizedBox(height: 5),

                  // Last Message Preview
                  Container(
                    width: 200,
                    height: 12,
                    color: isDarkMode
                        ? Colors.black
                        : Colors.grey[400], // Adjusted for Light Mode
                  ),
                ],
              ),
            ),

            // ⏳ Timestamp Placeholder
            Container(
              width: 40,
              height: 12,
              color: isDarkMode
                  ? Colors.black
                  : Colors.grey[400], // Adjusted for Light Mode
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔶 Cover Photo Placeholder
          Container(
            height: 150,
            width: double.infinity,
            color: isDarkMode ? Colors.black : Colors.grey[400],
          ),

          // 🟠 Profile Info Section
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                // Profile Picture Placeholder
                CircleAvatar(
                  radius: 40,
                  backgroundColor: isDarkMode ? Colors.black : Colors.grey[400],
                ),
                SizedBox(height: 10),

                // Name Placeholder
                Container(
                  width: 120,
                  height: 15,
                  color: isDarkMode ? Colors.black : Colors.grey[400],
                ),
                SizedBox(height: 5),

                // Bio & Details Placeholder
                Container(
                  width: 180,
                  height: 12,
                  color: isDarkMode ? Colors.black : Colors.grey[400],
                ),
                SizedBox(height: 5),
                Container(
                  width: 160,
                  height: 12,
                  color: isDarkMode ? Colors.black : Colors.grey[400],
                ),
                SizedBox(height: 10),

                // "Posts" Text Placeholder
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 10),
                    width: 50,
                    height: 15,
                    color: isDarkMode ? Colors.black : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),

          // 🔽 Posts Section (Shimmer)
          Expanded(
            child: ListView.builder(
              itemCount: 3, // Show 3 shimmer posts
              itemBuilder: (context, index) => ShimmerPost(),
            ),
          ),
        ],
      ),
    );
  }
}
