import 'package:get/get.dart';
import '../data/repo/user_repo.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final UserRepo userRepo;

  UserController({required this.userRepo});

  final RxList<RecommendedAccountModel> suggestedAccounts =
      <RecommendedAccountModel>[].obs;
  final RxString selectedTypeFilter = ''.obs;
  final RxBool isFetchingSuggestions = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchSuggestions());
  }

  Future<void> fetchSuggestions({int limit = 20, String? type}) async {
    if (isFetchingSuggestions.value) return;

    isFetchingSuggestions.value = true;

    try {
      final cleanType =
      (type == null || type.trim().isEmpty || type == 'null')
          ? null
          : type.trim();

      final response = await userRepo.getRecommendedProfiles(
        limit: limit,
        type: cleanType,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.body['suggestions'] ?? [];

        suggestedAccounts.assignAll(
          data.map((e) => RecommendedAccountModel.fromJson(e)).toList(),
        );
      } else {
        Get.snackbar(
          'Error',
          response.body?['message'] ?? 'Failed to load suggestions',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load suggestions');
    } finally {
      isFetchingSuggestions.value = false;
    }
  }

  Future<void> refreshSuggestions() async {
    await fetchSuggestions(
      type: selectedTypeFilter.value.isEmpty
          ? null
          : selectedTypeFilter.value,
    );
  }

  void setFilter(String value) {
    selectedTypeFilter.value = value;
    fetchSuggestions(type: value.isEmpty ? null : value);
  }

  String resolveImageUrl(String? url) {
    if (url == null) return '';

    final value = url.trim();

    if (value.isEmpty || value == 'null' || value == 'string') {
      return '';
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${userRepo.apiClient.baseUrl}$value';
    }

    return '${userRepo.apiClient.baseUrl}/$value';
  }
}
