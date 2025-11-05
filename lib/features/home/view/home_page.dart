import 'package:flutter/material.dart';

import '../../../data/models/post.dart';
import '../../../shared/widgets/postWidget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final posts = [
      Post(
        id: '1',
        title: 'Found money',
        description: 'I found some money in the lecture hall.',
        location: 'MATH 206',
        photo: 'https://picsum.photos/id/237/200/300',
        type: 'lost',
        tags: ['Money', 'Lecture', 'Paper'],
        author: 'John Doe',
        likeCount: 12,
        isLiked: false,
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: '2',
        title: 'Found Airpods',
        description: 'I found some money in the lecture hall.',
        location: 'MATH 305',
        photo: 'https://picsum.photos/id/238/200/300',
        type: 'lost',
        tags: ['Money', 'Lecture', 'Paper'],
        author: 'John Doe',
        likeCount: 34,
        isLiked: true,
        isCompleted: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Post(
        id: '1',
        title: 'Found handbag',
        description: 'I found some money in the lecture hall.',
        location: 'MATH 206',
        photo: 'https://picsum.photos/id/239/200/300',
        type: 'lost',
        tags: ['Money', 'Lecture', 'Paper'],
        author: 'John Doe',
        likeCount: 18,
        isLiked: false,
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Post(
        id: '1',
        title: 'Found passport',
        description: 'I found some money in the lecture hall.',
        location: 'MATH 206',
        photo: 'https://picsum.photos/id/240/200/300',
        type: 'lost',
        tags: ['Money', 'Lecture', 'Paper'],
        author: 'John Doe',
        likeCount: 2,
        isLiked: false,
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      Post(
        id: '1',
        title: 'Found a hat',
        description: 'I found some money in the lecture hall.',
        location: 'MATH 206',
        photo: 'https://picsum.photos/id/241/200/300',
        type: 'lost',
        tags: ['Money', 'Lecture', 'Paper'],
        author: 'John Doe',
        likeCount: 9,
        isLiked: true,
        isCompleted: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    return Scaffold(
      appBar: AppBar (
        title: const Text('Lost & Found'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostWidget(
            post: posts[index],
            onTap: () {
              // Navigate to detail page
              print('Tapped on post: ${posts[index].title}');
            },
            onLikeToggle: (isLiked) {
              // Handle like toggle
              print('Post liked: $isLiked');
            },
          );
        },
      ),
    );
  }
}