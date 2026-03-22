import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/repo/auth_repo.dart';
import '../data/repo/profile_content_repo.dart';
import '../data/repo/user_repo.dart';
import '../models/event_model.dart';
import '../models/profile_content_model.dart';
import '../widgets/snackbars.dart';

class ProfileContentController extends GetxController {
  ProfileContentController({
    required this.profileContentRepo,
    required this.userRepo,
    required this.authRepo,
  });

  final ProfileContentRepo profileContentRepo;
  final UserRepo userRepo;
  final AuthRepo authRepo;
  final ImagePicker _picker = ImagePicker();

  final RxList<DisplayMediaModel> displayMedia = <DisplayMediaModel>[].obs;
  final RxList<TipModel> tips = <TipModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<EventModel> events = <EventModel>[].obs;

  final RxBool isLoadingMedia = false.obs;
  final RxBool isLoadingTips = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingEvents = false.obs;
  final RxBool isUploadingMedia = false.obs;
  final RxBool isCreatingTip = false.obs;
  final RxInt acceptedConnectionsCount = 0.obs;

  String? currentOwnerId;
  String? currentOwnerType;

  Future<void> loadForOwner({
    required String ownerId,
    required String ownerType,
    bool includeProducts = true,
    bool includeEvents = true,
  }) async {
    currentOwnerId = ownerId;
    currentOwnerType = ownerType;

    await Future.wait([
      loadDisplayMedia(ownerId: ownerId, ownerType: ownerType),
      loadTips(ownerId: ownerId, ownerType: ownerType),
      if (ownerType == 'company' && includeProducts)
        loadProducts(companyId: ownerId),
      if (includeEvents) loadEvents(ownerId: ownerId, ownerType: ownerType),
    ]);
  }

  Future<void> refreshCurrentOwner() async {
    final ownerId = currentOwnerId;
    final ownerType = currentOwnerType;

    if (ownerId == null || ownerType == null) {
      return;
    }

    await loadForOwner(ownerId: ownerId, ownerType: ownerType);
  }

  Future<void> loadDisplayMedia({
    required String ownerId,
    required String ownerType,
  }) async {
    isLoadingMedia.value = true;
    try {
      displayMedia.assignAll(
        await profileContentRepo.getDisplayMedia(
          ownerId: ownerId,
          ownerType: ownerType,
        ),
      );
    } catch (error) {
      displayMedia.clear();
    } finally {
      isLoadingMedia.value = false;
    }
  }

  Future<void> loadTips({
    required String ownerId,
    required String ownerType,
  }) async {
    isLoadingTips.value = true;
    try {
      tips.assignAll(
        await profileContentRepo.getTips(
          ownerId: ownerId,
          ownerType: ownerType,
        ),
      );
    } catch (error) {
      tips.clear();
    } finally {
      isLoadingTips.value = false;
    }
  }

  Future<void> loadProducts({
    required String companyId,
  }) async {
    isLoadingProducts.value = true;
    try {
      products.assignAll(
        await profileContentRepo.getProducts(companyId: companyId),
      );
    } catch (error) {
      products.clear();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  Future<void> loadEvents({
    required String ownerId,
    required String ownerType,
  }) async {
    isLoadingEvents.value = true;
    try {
      events.assignAll(
        await profileContentRepo.getEvents(
          ownerId: ownerId,
          ownerType: ownerType,
        ),
      );
    } catch (error) {
      events.clear();
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> loadAcceptedConnectionsCount() async {
    try {
      acceptedConnectionsCount.value = await userRepo.getAcceptedConnectionsCount();
    } catch (_) {
      acceptedConnectionsCount.value = 0;
    }
  }

  Future<void> pickAndUploadDisplayMedia({
    required String visibility,
    ImageSource source = ImageSource.gallery,
    String? title,
  }) async {
    if (isUploadingMedia.value) {
      return;
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) {
      return;
    }

    isUploadingMedia.value = true;

    try {
      final uploadResponse = await authRepo.uploadMedia(File(pickedFile.path));
      if (uploadResponse.statusCode != 200 && uploadResponse.statusCode != 201) {
        throw Exception(
          uploadResponse.body is Map
              ? uploadResponse.body['message']?.toString()
              : uploadResponse.statusText,
        );
      }

      final location = uploadResponse.body['location']?.toString();
      if (location == null || location.trim().isEmpty) {
        throw Exception('Media upload did not return a valid location');
      }

      final createdMedia = await profileContentRepo.createDisplayMedia(
        url: location,
        visibility: visibility,
        title: title,
      );
      displayMedia.insert(0, createdMedia);
      displayMedia.refresh();
      CustomSnackBar.success(message: 'Media uploaded successfully');
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isUploadingMedia.value = false;
    }
  }

  Future<void> deleteDisplayMedia(String mediaId) async {
    try {
      await profileContentRepo.deleteDisplayMedia(mediaId);
      displayMedia.removeWhere((item) => item.id == mediaId);
      displayMedia.refresh();
      CustomSnackBar.success(message: 'Media deleted');
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> createTip({
    required String title,
    required String description,
    required String visibility,
  }) async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      CustomSnackBar.failure(message: 'Tip title and description are required');
      return;
    }

    if (isCreatingTip.value) {
      return;
    }

    isCreatingTip.value = true;
    try {
      final createdTip = await profileContentRepo.createTip(
        title: title,
        description: description,
        visibility: visibility,
      );
      tips.insert(0, createdTip);
      tips.refresh();
      CustomSnackBar.success(message: 'Tip published');
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      isCreatingTip.value = false;
    }
  }

  Future<void> toggleTipSave(String tipId) async {
    final index = tips.indexWhere((item) => item.id == tipId);
    if (index == -1) {
      return;
    }

    final current = tips[index];
    final optimisticSaved = !current.isSaved;
    final optimisticCount = optimisticSaved
        ? current.saves + 1
        : (current.saves - 1).clamp(0, 1 << 31);

    tips[index] = current.copyWith(
      isSaved: optimisticSaved,
      saves: optimisticCount,
    );
    tips.refresh();

    try {
      final updated = await profileContentRepo.toggleTipSave(tipId);
      tips[index] = current.copyWith(
        isSaved: updated.isSaved,
        saves: updated.saves,
      );
      tips.refresh();
    } catch (error) {
      tips[index] = current;
      tips.refresh();
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> deleteTip(String tipId) async {
    try {
      await profileContentRepo.deleteTip(tipId);
      tips.removeWhere((item) => item.id == tipId);
      tips.refresh();
      CustomSnackBar.success(message: 'Tip deleted');
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}
