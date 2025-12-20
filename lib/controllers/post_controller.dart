import 'package:get/get.dart';
import 'package:smart_swatcher/data/repo/post_repo.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';



class PostController extends GetxController {
  final PostRepo _repository = PostRepo();
  final uuid = Uuid();

  final RxList<PostDraft> drafts = <PostDraft>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedAudience = 'General Color Club'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDrafts();
  }

  Future<void> loadDrafts() async {
    try {
      isLoading.value = true;
      drafts.value = await _repository.getDrafts();
      // Sort by created date, newest first
      drafts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load drafts: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveDraft(String content, {String? draftId, bool showSnackbar = true}) async {
    if (content.trim().isEmpty) return false;

    try {
      final draft = PostDraft(
        id: draftId ?? uuid.v4(),
        content: content,
        createdAt: DateTime.now(),
        audience: selectedAudience.value,
      );

      await _repository.saveDraft(draft);
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
      await _repository.deleteDraft(id);
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
      await _repository.clearAllDrafts();
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

  void setAudience(String audience) {
    selectedAudience.value = audience;
  }
}