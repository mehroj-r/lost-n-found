import '../../core/network/dio_client.dart';
import '../../core/config/api_config.dart';
import '../models/post.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts({int page = 1, int limit = 20});
  Future<Post> getPostById(String id);
  Future<Post> createPost({
    required String title,
    required String description,
    required String type,
    int? photoId,
  });
  Future<Post> updatePost(String id, Map<String, dynamic> data);
  Future<void> deletePost(String id);
  Future<List<Post>> getMyPosts({int page = 1, int limit = 20});
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20});
  Future<void> likePost(int postId);
  Future<void> unlikePost(int postId);
}

class PostRepository implements IPostRepository {
  final DioClient dioClient;

  PostRepository({required this.dioClient});

  @override
  Future<List<Post>> getPosts({int page = 1, int limit = 20}) async {
    final response = await dioClient.get(
      ApiConfig.posts,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map && data['success'] == true && data.containsKey('data')) {
      final List items = data['data'] as List;
      return items.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<Post> getPostById(String id) async {
    final response = await dioClient.get('${ApiConfig.postsDetail}$id');
    final data = response.data;
    if (data is Map && data['success'] == true && data.containsKey('data')) {
      return Post.fromJson(data['data']);
    }
    throw Exception('Failed to load post');
  }

  @override
  Future<Post> createPost({
    required String title,
    required String description,
    required String type,
    int? photoId,
  }) async {
    final response = await dioClient.post(
      ApiConfig.postsCreate,
      data: {
        'title': title,
        'description': description,
        'type': type,
        'is_completed': false,
        if (photoId != null) 'photo': photoId,
      },
    );
    final data = response.data;
    if (data is Map && data['success'] == true && data.containsKey('data')) {
      return Post.fromJson(data['data']);
    }
    throw Exception('Failed to create post');
  }

  @override
  Future<Post> updatePost(String id, Map<String, dynamic> data) async {
    final response = await dioClient.patch(
      '${ApiConfig.postsUpdate}$id/',
      data: data,
    );
    final responseData = response.data;
    if (responseData is Map && responseData['success'] == true && responseData.containsKey('data')) {
      return Post.fromJson(responseData['data']);
    }
    throw Exception('Failed to update post');
  }

  @override
  Future<void> deletePost(String id) async {
    await dioClient.delete('${ApiConfig.postsDelete}$id/');
  }

  @override
  Future<List<Post>> getMyPosts({int page = 1, int limit = 20}) async {
    final response = await dioClient.get(
      '${ApiConfig.posts}my/',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map && data['success'] == true && data.containsKey('data')) {
      final List items = data['data'] as List;
      return items.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20}) async {
    final response = await dioClient.get(
      ApiConfig.posts,
      queryParameters: {
        'query': query,
        'page': page,
        'limit': limit,
      },
    );

    final data = response.data;
    if (data is Map && data['success'] == true && data.containsKey('data')) {
      final List items = data['data'] as List;
      return items.map((json) => Post.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> likePost(int postId) async {
    await dioClient.post('${ApiConfig.postsLike}$postId/likes/');
  }

  @override
  Future<void> unlikePost(int postId) async {
    await dioClient.delete('${ApiConfig.postsLike}$postId/likes/');
  }
}
