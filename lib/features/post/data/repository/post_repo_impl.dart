import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:near_me/core/constants/api_constant.dart';
import 'package:near_me/core/constants/user_constant.dart';
import 'package:near_me/core/error/failure.dart';
import 'package:near_me/features/post/domain/enitities/post_entities.dart';
import 'package:near_me/features/post/domain/repository/post_repository.dart';

class PostRepoImpl implements PostRepository {
  final http.Client client;
  PostRepoImpl(this.client);
  @override
  Future<Either<Failure, Unit>> createPost(String imagePath) async {
    try {
      var userId = UserConstant().getUserId();
      var user = UserConstant().getUser();
      if (userId == null || userId == '') {
        return const Left(ServerFailure(
            message: "Unexpected error occurs, please try again later"));
      }
      var uri = Uri.parse('${ApiConstant.POST_BASE_URL}/post/create')
          .replace(queryParameters: {'userId': userId});
      print(uri);
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('post', imagePath))
        ..fields['name'] = user!.name
        ..fields['gender'] = user.gender
        ..fields['profilePic'] = user.photoUrl ?? "";
      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 202) {
        return const Right(unit);
      } else {
        print(response.statusCode);
        print(response.reasonPhrase);
        print(await response.stream.bytesToString());
        return const Left(ServerFailure(
            message: "Failed to create post, please try again later"));
      }
    } catch (e) {
      return Left(ServerFailure(message: "unable to get post"));
    }
  }

  @override
  Future<Either<Failure, List<PostModel>>> getMyPosts() async {
    try {
      var userId = UserConstant().getUserId();
      var uri = Uri.parse('${ApiConstant.POST_BASE_URL}/post/my-post')
          .replace(queryParameters: {"userId": userId});
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        List<PostModel> result = [];
        var jsonData = jsonDecode(response.body);
        for (var data in jsonData) {
          result.add(PostModel.fromMap(data));
        }
        return Right(result);
      } else {
        return const Left(ServerFailure(message: "unable to access the post"));
      }
    } catch (e) {
      return Left(ServerFailure(message: "unable to get post"));
    }
  }

  @override
  Future<Either<Failure, List<PostModel>>> getPosts(
      DateTime lastPostTime) async {
    try {
      var uri = Uri.parse('${ApiConstant.POST_BASE_URL}/post/get-posts');
      var response = await client.post(uri,
          body: jsonEncode({'lastPostTime': lastPostTime.toIso8601String()}),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        List<PostModel> result = [];
        var jsonData = jsonDecode(response.body);
        for (var data in jsonData) {
          result.add(PostModel.fromMap(data));
        }
        return Right(result);
      } else {
        return const Left(ServerFailure(message: "unable to access the post"));
      }
    } catch (e) {
      return Left(ServerFailure(message: "unable to get post"));
    }
  }

  @override
  Future<Either<Failure, List<PostModel>>> getUserPosts(String userId) async {
    try {
      var uri = Uri.parse('${ApiConstant.POST_BASE_URL}/post/my-post')
          .replace(queryParameters: {"userId": userId});
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        List<PostModel> result = [];
        var jsonData = jsonDecode(response.body);
        for (var data in jsonData) {
          result.add(PostModel.fromMap(data));
        }
        return Right(result);
      } else {
        return const Left(ServerFailure(message: "unable to access the post"));
      }
    } catch (e) {
      return Left(ServerFailure(message: "unable to get post"));
    }
  }

  @override
  Future<Either<Failure, HashSet<int>>> getPostILiked() async {
    try {
      var userId = UserConstant().getUserId();
      var uri = Uri.parse('${ApiConstant.POST_BASE_URL}/post/liked')
          .replace(queryParameters: {"userId": userId});
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var listOfIds = jsonDecode(response.body);
        var hashSetOfIds = HashSet<int>.from(listOfIds);
        return Right(hashSetOfIds);
      } else {
        return Left(ServerFailure(message: "unable to get post i liked"));
      }
    } catch (e) {
      return Left(ServerFailure(message: "unable to get post"));
    }
  }

  @override
  Future<Either<Failure, int>> likePost(int postId) async {
    try {
      var userId = UserConstant().getUserId();
      var uri = Uri.parse('${ApiConstant.POST_BASE_URL}/post/like');
      var response = await client.post(uri,
          body: jsonEncode({'userId': userId, 'postId': postId}));
      if (response.statusCode == 200 || response.statusCode == 202) {
        return Right(postId);
      } else {
        return const Left(ServerFailure(message: "error occurred"));
      }
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
