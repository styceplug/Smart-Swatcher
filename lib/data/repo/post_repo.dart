import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_swatcher/data/api/api_client.dart';

import '../../models/post_model.dart';
import '../../utils/app_constants.dart';

class PostRepo {
  static const String _draftsKey = 'post_drafts';
  final ApiClient apiClient;

  PostRepo({required this.apiClient});



  Future<Response> getPosts({int limit = 20, int offset = 0}) async {
    return await apiClient.getData('/api/posts?limit=$limit&offset=$offset');
  }

/*
  Future<Response> createPost(Map<String, String> body, List<MultipartBody> files) async {
    final uri = Uri.parse('${AppConstants.BASE_URL}/api/posts');

    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(body);

    for (var multipart in files) {
      var file = await http.MultipartFile.fromPath(
          multipart.key,
          multipart.file.path
      );
      request.files.add(file);
    }

    return await apiClient.postMultipartData('/api/posts', request);
  }
*/

  Future<Response> createPost(Map<String, String> fields, List<File> files) async {
    final uri = Uri.parse('${AppConstants.BASE_URL}/api/posts');
    var request = http.MultipartRequest('POST', uri);

    request.fields.addAll(fields);

    for (var file in files) {
      var multipartFile = await http.MultipartFile.fromPath(
        'mediaFiles', // exact key from Swagger
        file.path,
      );
      request.files.add(multipartFile);
    }

    // 4. Send via ApiClient
    return await apiClient.postMultipartData('/api/posts', request);
  }

  Future<Response> getPostDetails(String postId) async {
    return await apiClient.getData('/api/posts/$postId?includeComments=true');
  }

  Future<Response> likePost(String postId) async {
    return await apiClient.postData('/api/posts/$postId/like', {});
  }

  Future<Response> addComment(String postId, String body) async {
    return await apiClient.postData('/api/posts/$postId/comments', {"body": body});
  }

  Future<List<PostDraft>> getDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final draftsJson = prefs.getString(_draftsKey);

    if (draftsJson == null) return [];

    final List<dynamic> draftsList = json.decode(draftsJson);
    return draftsList.map((draft) => PostDraft.fromJson(draft)).toList();
  }

  Future<void> saveDraft(PostDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();

    final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
    if (existingIndex != -1) {
      drafts[existingIndex] = draft;
    } else {
      drafts.add(draft);
    }

    final draftsJson = json.encode(drafts.map((d) => d.toJson()).toList());
    await prefs.setString(_draftsKey, draftsJson);
  }

  Future<void> deleteDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getDrafts();

    drafts.removeWhere((draft) => draft.id == id);

    final draftsJson = json.encode(drafts.map((d) => d.toJson()).toList());
    await prefs.setString(_draftsKey, draftsJson);
  }

  Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftsKey);
  }
}