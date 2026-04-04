import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/user_controller.dart';
import 'package:smart_swatcher/data/repo/post_repo.dart';
import 'package:smart_swatcher/helpers/global_loader_controller.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import '../widgets/snackbars.dart';

class PostController extends GetxController {
  final PostRepo postRepo = Get.find<PostRepo>();
  final uuid = Uuid();

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  final RxList<dynamic> drafts = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedAudience = 'General'.obs;
  var postsList = <PostModel>[].obs;
  var ownPostsList = <PostModel>[].obs;
  var isFeedLoading = false.obs;
  var isOwnPostsLoading = false.obs;
  var currentPostComments = <CommentModel>[].obs;
  var isCommentsLoading = false.obs;
  var selectedMediaFiles = <File>[].obs;
  final Map<String, DateTime> _recordedImpressionTimes = <String, DateTime>{};
  final RxSet<String> recordingImpressionIds = <String>{}.obs;
  final RxSet<String> deletingPostIds = <String>{}.obs;
  final RxSet<String> likingPostIds = <String>{}.obs;
  final RxSet<String> savingPostIds = <String>{}.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadDrafts();
    if (_hasSessionContext) {
      refreshAfterAuthChange();
    }
  }

  bool get _hasSessionContext {
    final authController = Get.find<AuthController>();
    return authController.stylistProfile.value != null ||
        authController.companyProfile.value != null;
  }

  Future<void> refreshAfterAuthChange() async {
    if (isFeedLoading.value || isOwnPostsLoading.value) {
      return;
    }

    await fetchFeed();
    if (currentActorId != null && currentActorId!.trim().isNotEmpty) {
      await fetchOwnPosts();
    } else {
      ownPostsList.clear();
    }
  }

  static const Duration _impressionCooldown = Duration(hours: 6);

  bool hasRecordedImpression(String postId) {
    final recordedAt = _recordedImpressionTimes[postId];
    if (recordedAt == null) {
      return false;
    }

    return DateTime.now().difference(recordedAt) < _impressionCooldown;
  }

  bool canRecordImpression(String postId) {
    if (postId.trim().isEmpty) {
      return false;
    }

    if (recordingImpressionIds.contains(postId)) {
      return false;
    }

    return !hasRecordedImpression(postId);
  }

  String? get currentActorId {
    final authController = Get.find<AuthController>();

    switch (authController.currentAccountType.value) {
      case AccountType.stylist:
        return authController.stylistProfile.value?.id;
      case AccountType.company:
        return authController.companyProfile.value?.id;
      case null:
        return authController.companyProfile.value?.id ??
            authController.stylistProfile.value?.id;
    }
  }

  bool isOwnPost(PostModel post) {
    final actorId = currentActorId;
    final authorId = post.author?.id;

    return actorId != null &&
        actorId.trim().isNotEmpty &&
        authorId != null &&
        authorId == actorId;
  }

  Future<bool> recordImpression(String postId) async {
    if (!canRecordImpression(postId)) {
      return false;
    }

    recordingImpressionIds.add(postId);

    try {
      final response = await postRepo.recordPostImpression(postId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _recordedImpressionTimes[postId] = DateTime.now();
        return true;
      }
    } catch (e) {
      print("Impression Error: $e");
    } finally {
      recordingImpressionIds.remove(postId);
    }

    return false;
  }

  Future<void> recordImpressions(List<String> postIds) async {
    final validIds =
        postIds
            .where((id) => id.trim().isNotEmpty)
            .where(canRecordImpression)
            .toSet()
            .toList();

    if (validIds.isEmpty) return;

    recordingImpressionIds.addAll(validIds);

    try {
      final response = await postRepo.recordPostImpressions(validIds);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final timestamp = DateTime.now();
        for (final id in validIds) {
          _recordedImpressionTimes[id] = timestamp;
        }
      }
    } catch (e) {
      print("Batch Impression Error: $e");
    } finally {
      recordingImpressionIds.removeAll(validIds);
    }
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

  Iterable<RxList<PostModel>> _allPostCollections() sync* {
    yield postsList;
    yield ownPostsList;

    if (Get.isRegistered<UserController>()) {
      yield Get.find<UserController>().profilePosts;
    }
  }

  List<PostModel> _matchingPosts(String postId) {
    final matches = <PostModel>[];

    for (final list in _allPostCollections()) {
      matches.addAll(list.where((post) => post.id == postId));
    }

    return matches;
  }

  void _applyToMatchingPosts(
    String postId,
    void Function(PostModel post) updater,
  ) {
    for (final list in _allPostCollections()) {
      var touched = false;

      for (final post in list.where((item) => item.id == postId)) {
        updater(post);
        touched = true;
      }

      if (touched) {
        list.refresh();
      }
    }
  }

  void _applyProfileLikeDelta(String postId, int delta) {
    if (!Get.isRegistered<UserController>()) {
      return;
    }

    final userController = Get.find<UserController>();
    final activeProfile = userController.profile.value;
    if (activeProfile == null) {
      return;
    }

    final hasMatchingPost = _matchingPosts(
      postId,
    ).any((post) => post.author?.id == activeProfile.id);

    if (!hasMatchingPost) {
      return;
    }

    final nextLikes = ((activeProfile.likes ?? 0) + delta).clamp(0, 1 << 31);
    userController.profile.value = activeProfile.copyWith(likes: nextLikes);
  }

  // --- Helper: Extract Tags ---
  List<String> _extractTags(String caption) {
    RegExp exp = RegExp(r"\B#\w\w+");
    Iterable<RegExpMatch> matches = exp.allMatches(caption);
    List<String> tags =
        matches.map((m) => caption.substring(m.start + 1, m.end)).toList();
    return tags;
  }

  Future<void> createPost(String caption) async {
    if (caption.trim().isEmpty && selectedMediaFiles.isEmpty) {
      CustomSnackBar.failure(message: "Please add a caption or photo");
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
          "position": i,
        });
      }

      // 2. Prepare Fields
      Map<String, String> fields = {
        "caption": caption,
        "targetAudience": selectedAudience.value,
        "tags": jsonEncode(_extractTags(caption)), // List -> JSON String
        "media": jsonEncode(mediaMeta), // List -> JSON String
      };

      // 3. Call Repo
      // We pass the fields map AND the list of File objects
      Response response = await postRepo.createPost(fields, selectedMediaFiles);

      if (response.statusCode == 201 || response.statusCode == 200) {
        selectedMediaFiles.clear();
        await fetchFeed();

        final navigator = Get.key.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        }

        CustomSnackBar.success(message: "Post created successfully!");
      } else {
        String msg =
            response.body is Map
                ? (response.body['message']?.toString() ??
                    response.statusText?.toString() ??
                    "Failed to post")
                : (response.statusText?.toString() ?? "Failed to post");
        CustomSnackBar.failure(message: msg);
      }
    } catch (e) {
      print("Create Post Error: $e");
      CustomSnackBar.failure(message: "An unexpected error occurred");
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
            currentPostComments.assignAll(
              commentList.map((e) => CommentModel.fromJson(e)).toList(),
            );
          }

          final updatedPost = PostModel.fromJson(postData);
          _applyToMatchingPosts(postId, (post) {
            post.metrics = updatedPost.metrics;
            post.media = updatedPost.media;
            post.tags = updatedPost.tags;
            post.isLiked = updatedPost.isLiked;
            post.isSaved = updatedPost.isSaved;
            post.formula = updatedPost.formula;
          });
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

  Future<List<PostModel>> fetchPostsForAuthor({
    required String authorId,
    String? authorType,
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await postRepo.getPosts(
      limit: limit,
      offset: offset,
      authorId: authorId,
      authorType: authorType,
    );

    if (response.statusCode != 200) {
      final message =
          response.body is Map
              ? response.body['message']?.toString()
              : response.statusText;
      throw Exception(message ?? 'Failed to load posts');
    }

    final List<dynamic> data = response.body['posts'] ?? <dynamic>[];
    return data.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<void> fetchOwnPosts({
    String? authorId,
    String? authorType,
    int limit = 50,
  }) async {
    final resolvedAuthorId = authorId ?? currentActorId;

    if (resolvedAuthorId == null || resolvedAuthorId.trim().isEmpty) {
      ownPostsList.clear();
      return;
    }

    final resolvedAuthorType =
        authorType ??
        (() {
          final authController = Get.find<AuthController>();
          switch (authController.currentAccountType.value) {
            case AccountType.company:
              return 'company';
            case AccountType.stylist:
              return 'stylist';
            case null:
              return authController.companyProfile.value != null
                  ? 'company'
                  : 'stylist';
          }
        })();

    isOwnPostsLoading.value = true;

    try {
      ownPostsList.assignAll(
        await fetchPostsForAuthor(
          authorId: resolvedAuthorId,
          authorType: resolvedAuthorType,
          limit: limit,
        ),
      );
    } catch (e) {
      print("Own Posts Error: $e");
      ownPostsList.clear();
    } finally {
      isOwnPostsLoading.value = false;
    }
  }

  Future<bool> deletePost(String postId) async {
    if (postId.trim().isEmpty || deletingPostIds.contains(postId)) {
      return false;
    }

    deletingPostIds.add(postId);

    try {
      final response = await postRepo.deletePost(postId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        postsList.removeWhere((post) => post.id == postId);
        postsList.refresh();
        ownPostsList.removeWhere((post) => post.id == postId);
        ownPostsList.refresh();

        if (Get.isRegistered<UserController>()) {
          final profilePosts = Get.find<UserController>().profilePosts;
          profilePosts.removeWhere((post) => post.id == postId);
          profilePosts.refresh();
        }

        CustomSnackBar.success(message: 'Post deleted successfully');

        if (Get.currentRoute == AppRoutes.commentsScreen) {
          final navigator = Get.key.currentState;
          if (navigator != null && navigator.canPop()) {
            navigator.pop();
          }
        }

        return true;
      }

      final message =
          response.body is Map
              ? response.body['message']?.toString()
              : response.statusText;
      CustomSnackBar.failure(message: message ?? 'Failed to delete post');
      return false;
    } catch (e) {
      CustomSnackBar.failure(message: 'Failed to delete post');
      return false;
    } finally {
      deletingPostIds.remove(postId);
    }
  }

  Future<void> toggleLike(String postId) async {
    if (likingPostIds.contains(postId)) {
      return;
    }

    final matchingPosts = _matchingPosts(postId);
    if (matchingPosts.isEmpty) {
      return;
    }

    final originalStatus = matchingPosts.first.isLiked;
    final originalLikes = matchingPosts.first.metrics?.likes ?? 0;
    final optimisticLikes =
        originalStatus ? originalLikes - 1 : originalLikes + 1;
    final optimisticDelta = originalStatus ? -1 : 1;

    likingPostIds.add(postId);

    _applyToMatchingPosts(postId, (post) {
      post.isLiked = !originalStatus;
      post.metrics ??= PostMetrics();
      post.metrics!.likes = optimisticLikes < 0 ? 0 : optimisticLikes;
    });
    _applyProfileLikeDelta(postId, optimisticDelta);

    try {
      Response response = await postRepo.likePost(postId);

      if (response.statusCode == 200) {
        final likedStatus = response.body['liked'] == true;
        final likesCount =
            int.tryParse(response.body['likes'].toString()) ?? optimisticLikes;
        final serverDelta = likesCount - optimisticLikes;

        _applyToMatchingPosts(postId, (post) {
          post.isLiked = likedStatus;
          post.metrics ??= PostMetrics();
          post.metrics!.likes = likesCount < 0 ? 0 : likesCount;
        });
        if (serverDelta != 0) {
          _applyProfileLikeDelta(postId, serverDelta);
        }
      } else {
        _applyToMatchingPosts(postId, (post) {
          post.isLiked = originalStatus;
          post.metrics ??= PostMetrics();
          post.metrics!.likes = originalLikes;
        });
        _applyProfileLikeDelta(postId, -optimisticDelta);
      }
    } catch (e) {
      print("Like Error: $e");
      _applyToMatchingPosts(postId, (post) {
        post.isLiked = originalStatus;
        post.metrics ??= PostMetrics();
        post.metrics!.likes = originalLikes;
      });
      _applyProfileLikeDelta(postId, -optimisticDelta);
    } finally {
      likingPostIds.remove(postId);
    }
  }

  Future<void> toggleSave(String postId) async {
    if (savingPostIds.contains(postId)) {
      return;
    }

    final matchingPosts = _matchingPosts(postId);
    if (matchingPosts.isEmpty) {
      return;
    }

    final originalStatus = matchingPosts.first.isSaved;
    final originalSaves = matchingPosts.first.metrics?.saves ?? 0;
    final optimisticSaves =
        originalStatus ? originalSaves - 1 : originalSaves + 1;

    savingPostIds.add(postId);

    _applyToMatchingPosts(postId, (post) {
      post.isSaved = !originalStatus;
      post.metrics ??= PostMetrics();
      post.metrics!.saves = optimisticSaves < 0 ? 0 : optimisticSaves;
    });

    try {
      Response response = await postRepo.savePost(postId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var body = response.body;
        if (body is Map) {
          final savedStatus = body['saved'] == true;
          final savesCount =
              int.tryParse(body['saves'].toString()) ?? optimisticSaves;

          _applyToMatchingPosts(postId, (post) {
            post.isSaved = savedStatus;
            post.metrics ??= PostMetrics();
            post.metrics!.saves = savesCount < 0 ? 0 : savesCount;
          });
        }
      } else {
        _revertSave(postId, originalStatus, originalSaves);
      }
    } catch (e) {
      print("Save Error: $e");
      _revertSave(postId, originalStatus, originalSaves);
    } finally {
      savingPostIds.remove(postId);
    }
  }

  void _revertSave(String postId, bool originalStatus, int originalSaves) {
    _applyToMatchingPosts(postId, (post) {
      post.isSaved = originalStatus;
      post.metrics ??= PostMetrics();
      post.metrics!.saves = originalSaves;
    });
    CustomSnackBar.failure(message: "Failed to save post");
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
