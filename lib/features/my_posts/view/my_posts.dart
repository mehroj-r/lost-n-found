import 'package:flutter/material.dart';
import 'package:lost_n_found/data/models/post.dart';
import 'package:lost_n_found/shared/widgets/postWidget.dart';

class MyPostsScreen extends StatefulWidget {
  final List<Post> posts;

  const MyPostsScreen({super.key, required this.posts});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    // Filter posts based on selectedFilter
    final filteredPosts = selectedFilter == "All"
        ? widget.posts
        : widget.posts
        .where((post) => post.type.toLowerCase() == selectedFilter.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Posts"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ["Lost", "Found", "All"].map((filter) {
                  final isSelected = selectedFilter.toLowerCase() == filter.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedFilter = filter.toLowerCase();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];

                return PostWidget(
                  post: post,
                  onTap: () {
                    // Optional: navigate to post details
                    print('Tapped on post: ${post.title}');
                  },
                  onLikeToggle: (isLiked) {
                    setState(() {
                      final postIndex = widget.posts.indexWhere((p) => p.id == post.id);
                      if (postIndex != -1) {
                        final oldPost = widget.posts[postIndex];
                        widget.posts[postIndex] = Post(
                          id: oldPost.id,
                          title: oldPost.title,
                          description: oldPost.description,
                          photo: oldPost.photo,
                          tags: oldPost.tags,
                          type: oldPost.type,
                          author: oldPost.author,
                          location: oldPost.location,
                          likeCount: isLiked
                              ? oldPost.likeCount + 1
                              : (oldPost.likeCount > 0 ? oldPost.likeCount - 1 : 0),
                          isLiked: isLiked,
                          isCompleted: oldPost.isCompleted,
                          createdAt: oldPost.createdAt,
                        );
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
