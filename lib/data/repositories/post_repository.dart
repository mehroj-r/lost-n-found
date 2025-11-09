import '../../core/network/dio_client.dart';
import '../models/post.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts({int page = 1, int limit = 20});
  Future<Post> getPostById(String id);
  Future<Post> createPost({
    required String title,
    required String description,
    required String category,
    String? photoPath,
  });
  Future<Post> updatePost(String id, Map<String, dynamic> data);
  Future<void> deletePost(String id);
  Future<List<Post>> getMyPosts({int page = 1, int limit = 20});
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20});
}

class PostRepository implements IPostRepository {
  final DioClient dioClient;

  PostRepository({required this.dioClient});

  @override
  Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    final response = await dioClient.get(
      '/posts',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      final List items = data['data'] as List;
      return items.map((json) => Post.fromJson(json)).toList();
    } else if (data is List) {
      return data.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<Post> getPostById(String id) async {
    final response = await dioClient.get('/posts/$id');
    return Post.fromJson(response.data);
  }

  @override
  Future<Post> createPost({
    required String title,
    required String description,
    required String category,
    String? photoPath,
  }) async {
    if (photoPath != null) {
      // Upload with file
      final response = await dioClient.uploadFile(
        '/posts',
        photoPath,
        fileKey: 'photo',
        data: {
          'title': title,
          'description': description,
          'category': category,
        },
      );
      return Post.fromJson(response.data);
    } else {
      // Regular post without file
      final response = await dioClient.post(
        '/posts',
        data: {
          'title': title,
          'description': description,
          'category': category,
        },
      );
      return Post.fromJson(response.data);
    }
  }

  @override
  Future<Post> updatePost(String id, Map<String, dynamic> data) async {
    final response = await dioClient.patch(
      '/posts/$id',
      data: data,
    );
    return Post.fromJson(response.data);
  }

  @override
  Future<void> deletePost(String id) async {
    await dioClient.delete('/posts/$id');
  }

  @override
  Future<List<Post>> getMyPosts({int page = 1, int limit = 20}) async {
    final response = await dioClient.get(
      '/posts/my',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      final List items = data['data'] as List;
      return items.map((json) => Post.fromJson(json)).toList();
    } else if (data is List) {
      return data.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20}) async {
    final response = await dioClient.get(
      '/posts/search',
      queryParameters: {
        'q': query,
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      final List items = data['data'] as List;
      return items.map((json) => Post.fromJson(json)).toList();
    } else if (data is List) {
      return data.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  }
}
