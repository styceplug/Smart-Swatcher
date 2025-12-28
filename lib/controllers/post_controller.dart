import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/data/repo/post_repo.dart';
import 'package:smart_swatcher/helpers/global_loader_controller.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';

class PostController extends GetxController {
  final PostRepo postRepo = Get.find<PostRepo>();
  final uuid = Uuid();

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  final RxList<dynamic> drafts = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedAudience = 'General'.obs;
  var postsList = <PostModel>[].obs;
  var isFeedLoading = false.obs;
  var currentPostComments = <CommentModel>[].obs;
  var isCommentsLoading = false.obs;
  var selectedMediaFiles = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadDrafts();
    fetchFeed();
  }


  Future<void> pickMedia(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedMediaFiles.add(File(image.path));
      }
    } catch (e) {
      print("Pick error: $e");
    }
  }

  void removeMedia(int index) => selectedMediaFiles.removeAt(index);
  void setAudience(String value) => selectedAudience.value = value;

  // --- Helper: Extract Tags ---
  List<String> _extractTags(String caption) {
    RegExp exp = RegExp(r"\B#\w\w+");
    Iterable<RegExpMatch> matches = exp.allMatches(caption);
    List<String> tags = matches.map((m) => caption.substring(m.start + 1, m.end)).toList();
    return tags;
  }

  Future<void> createPost(String caption) async {
    if (caption.trim().isEmpty && selectedMediaFiles.isEmpty) {
      Get.snackbar("Error", "Please add a caption or photo");
      return;
    }

    isLoading.value = true;
    update();

    try {

      List<Map<String, dynamic>> mediaMeta = [];
      for (int i = 0; i < selectedMediaFiles.length; i++) {
        mediaMeta.add({
          "url": "", // Backend fills this
          "mediaType": "image",
          "position": i
        });
      }

      // 2. Prepare Fields
      Map<String, String> fields = {
        "caption": caption,
        "targetAudience": selectedAudience.value,
        "tags": jsonEncode(_extractTags(caption)), // List -> JSON String
        "media": jsonEncode(mediaMeta),            // List -> JSON String
      };

      // 3. Call Repo
      // We pass the fields map AND the list of File objects
      Response response = await postRepo.createPost(fields, selectedMediaFiles);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.back(); // Close screen
        Get.snackbar("Success", "Post created successfully!");
        selectedMediaFiles.clear();
        fetchFeed(); // Refresh the feed
      } else {
        // Parse error message
        String msg = response.body is Map ? response.body['message'] ?? response.statusText : response.statusText;
        Get.snackbar("Error", msg ?? "Failed to post");
      }
    } catch (e) {
      print("Create Post Error: $e");
      Get.snackbar("Error", "An unexpected error occurred");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> postComment(String postId, String body) async {
    if (body.trim().isEmpty) return;
    try {
      Response response = await postRepo.addComment(postId, body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        loadPostDetails(postId);
        Get.snackbar("Success", "Comment posted");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to post comment");
    }
  }

  Future<void> loadPostDetails(String postId) async {
    isCommentsLoading.value = true;
    currentPostComments.clear();

    try {
      Response response = await postRepo.getPostDetails(postId);

      if (response.statusCode == 200) {
        // FIX 1: Access the nested 'post' object first
        var rootData = response.body;
        var postData = rootData['post']; // <--- This was missing

        if (postData != null) {
          // 1. Update Comments List
          if (postData['comments'] != null) {
            List<dynamic> commentList = postData['comments'];
            currentPostComments.assignAll(commentList.map((e) => CommentModel.fromJson(e)).toList());
          }

          // 2. Update the Post's Comment Count (Metrics) in the Feed
          // We find the post in the main list and update it so the UI counts increase
          int index = postsList.indexWhere((p) => p.id == postId);
          if (index != -1) {
            // Update the specific post with new data (including new metrics)
            postsList[index] = PostModel.fromJson(postData);
            postsList.refresh(); // Trigger UI updates
          }
        }
      }
    } catch (e) {
      print("Comments Error: $e");
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> fetchFeed() async {
    isFeedLoading.value = true;
    try {
      Response response = await postRepo.getPosts();
      if (response.statusCode == 200) {

        // FIX: The API returns { "posts": [...] }, so we must access ['posts']
        List<dynamic> data = response.body['posts'] ?? [];

        postsList.assignAll(data.map((e) => PostModel.fromJson(e)).toList());
      }
    } catch (e) {
      print("Feed Error: $e");
    } finally {
      isFeedLoading.value = false;
    }
  }

  Future<void> toggleLike(String postId) async {
    int index = postsList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    try {
      Response response = await postRepo.likePost(postId);

      if (response.statusCode == 200) {
        // Backend Response: {liked: true, likes: 1}
        bool likedStatus = response.body['liked'];
        int likesCount = response.body['likes'];

        // 1. Update the local model
        var post = postsList[index];
        post.isLiked = likedStatus;
        post.metrics?.likes = likesCount;

        // 2. IMPORTANT: Force the List to notify listeners (The UI)
        postsList.refresh();
      }
    } catch (e) {
      print("Like Error: $e");
    }
  }

  Future<void> toggleSave(String postId) async {
    int index = postsList.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    // 1. Optimistic Update
    var post = postsList[index];
    bool originalStatus = post.isSaved;

    post.isSaved = !post.isSaved;
    if (post.metrics != null) {
      post.metrics!.saves = post.isSaved
          ? post.metrics!.saves + 1
          : post.metrics!.saves - 1;
    }
    postsList.refresh();

    try {
      Response response = await postRepo.savePost(postId);

      // 2. Handle Success (Sync with Server)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // FIX: The API returns { "saved": true, "saves": 1 } directly
        // We read 'saves' directly from body, NOT body['metrics']['saves']

        var body = response.body;
        if (body is Map && body['saves'] != null) {
          post.metrics?.saves = body['saves']; // Sync exact count from server
          postsList.refresh();
        }
      }
      // 3. Handle Failure (Revert)
      else {
        _revertSave(post, originalStatus);
      }
    } catch (e) {
      print("Save Error: $e");
      _revertSave(post, originalStatus);
    }
  }

  void _revertSave(PostModel post, bool originalStatus) {
    post.isSaved = originalStatus;
    if (post.metrics != null) {
      post.metrics!.saves = post.isSaved
          ? post.metrics!.saves + 1
          : post.metrics!.saves - 1;
    }
    postsList.refresh();
    Get.snackbar("Error", "Failed to save post");
  }


  // --- Draft Logic ---
  Future<void> loadDrafts() async {
    isLoading.value = true;
    try {
      drafts.value = await postRepo.getDrafts();
      // drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print("Draft error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveDraft(
    String content, {
    String? draftId,
    bool showSnackbar = true,
  }) async {
    if (content.trim().isEmpty) return false;

    try {
      final draft = PostDraft(
        id: draftId ?? uuid.v4(),
        content: content,
        createdAt: DateTime.now(),
        audience: selectedAudience.value,
      );

      await postRepo.saveDraft(draft);
      await loadDrafts();

      if (showSnackbar) {
        Get.snackbar(
          'Success',
          'Draft saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
      return true;
    } catch (e) {
      if (showSnackbar) {
        Get.snackbar(
          'Error',
          'Failed to save draft: $e',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      }
      return false;
    }
  }

  Future<void> deleteDraft(String id) async {
    try {
      await postRepo.deleteDraft(id);
      await loadDrafts();

      Get.snackbar(
        'Success',
        'Draft deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete draft: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearAllDrafts() async {
    try {
      await postRepo.clearAllDrafts();
      drafts.clear();

      Get.snackbar(
        'Success',
        'All drafts cleared',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear drafts: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }


}
