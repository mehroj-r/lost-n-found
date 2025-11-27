import '../../core/network/dio_client.dart';
import '../../core/config/api_config.dart';
import '../models/post.dart';

abstract class IPostRepository {
  Future<List<Post>> getPosts({int page = 1, int limit = 20, int userId});
  Future<Post> getPostById(String id);
  Future<Post> createPost({
    required String title,
    required String description,
    required String type,
    int? photoId,
    String? location,
  });
  Future<Post> updatePost(String id, Map<String, dynamic> data);
  Future<void> deletePost(String id);
  Future<List<Post>> getMyPosts({int page = 1, int limit = 20, required int userId});
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20, String? type, DateTime? dateStart, DateTime? dateEnd, String? orderBy});
  Future<void> likePost(int postId);
  Future<void> unlikePost(int postId);
  Future<List<Post>> getLikedPosts();
}

class PostRepository implements IPostRepository {
  final DioClient dioClient;

  PostRepository({required this.dioClient});

  @override
  Future<List<Post>> getLikedPosts() async {
    final response = await dioClient.get('/posts/liked/');
    final data = response.data;
    if (data is Map &&
        data['success'] == true &&
        data.containsKey('data')) {
      final List items = data['data'] as List;
      return items
          .map((json) => Post.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }


  @override
  Future<List<Post>> getPosts({int page = 1, int limit = 20, int? userId}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    // Add user_id if provided to get user's posts
    if (userId != null) {
      queryParams['user_id'] = userId;
    }

    final response = await dioClient.get(
      ApiConfig.posts,
      queryParameters: queryParams,
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
    String? location,
  }) async {
    final response = await dioClient.post(
      ApiConfig.postsCreate,
      data: {
        'title': title,
        'description': description,
        'type': type,
        'is_completed': false,
        if (photoId != null) 'photo': photoId,
        if (location != null && location.isNotEmpty) 'location': location,
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
  Future<List<Post>> getMyPosts({int page = 1, int limit = 20, required int userId}) async {
    // Use the getPosts method with user_id query param
    return getPosts(page: page, limit: limit, userId: userId);
  }

  @override
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20, String? type, DateTime? dateStart, DateTime? dateEnd, String? orderBy}) async {
    Map<String, dynamic> queryParameters = {
      'query': query,
      'page': page,
      'limit': limit,
    };

    // Add type filter if provided
    if (type != null && type.isNotEmpty) {
      queryParameters['type'] = type;
    }

    // Add date start filter if provided
    if (dateStart != null) {
      queryParameters['date_start'] = '${dateStart.year}-${dateStart.month.toString().padLeft(2, '0')}-${dateStart.day.toString().padLeft(2, '0')}';
    }

    // Add date end filter if provided
    if (dateEnd != null) {
      queryParameters['date_end'] = '${dateEnd.year}-${dateEnd.month.toString().padLeft(2, '0')}-${dateEnd.day.toString().padLeft(2, '0')}';
    }

    // Add order by filter if provided
    if (orderBy != null && orderBy.isNotEmpty) {
      queryParameters['order_by'] = orderBy;
    }

    final response = await dioClient.get(
      ApiConfig.posts,
      queryParameters: queryParameters,
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
