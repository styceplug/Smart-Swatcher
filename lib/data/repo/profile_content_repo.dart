import '../../models/event_model.dart';
import '../../models/profile_content_model.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class ProfileContentRepo {
  final ApiClient apiClient;

  ProfileContentRepo({required this.apiClient});

  Future<List<DisplayMediaModel>> getDisplayMedia({
    required String ownerId,
    required String ownerType,
    int limit = 50,
  }) async {
    final response = await apiClient.getData(
      '${AppConstants.DISPLAY_MEDIA_URI}?ownerId=$ownerId&ownerType=$ownerType&limit=$limit',
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    final rawItems = response.body is Map ? response.body['media'] : null;
    final items = rawItems is List ? rawItems : const <dynamic>[];
    return items
        .map((item) => DisplayMediaModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Future<DisplayMediaModel> createDisplayMedia({
    required String url,
    required String visibility,
    String? title,
  }) async {
    final response = await apiClient.postData(
      AppConstants.DISPLAY_MEDIA_URI,
      <String, dynamic>{
        'url': url,
        'visibility': visibility,
        if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    return DisplayMediaModel.fromJson(
      Map<String, dynamic>.from(response.body['media'] as Map),
    );
  }

  Future<void> deleteDisplayMedia(String mediaId) async {
    final response = await apiClient.deleteData(
      '${AppConstants.DISPLAY_MEDIA_URI}/$mediaId',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }
  }

  Future<List<TipModel>> getTips({
    required String ownerId,
    required String ownerType,
    int limit = 50,
  }) async {
    final response = await apiClient.getData(
      '${AppConstants.TIPS_URI}?ownerId=$ownerId&ownerType=$ownerType&limit=$limit',
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    final rawItems = response.body is Map ? response.body['tips'] : null;
    final items = rawItems is List ? rawItems : const <dynamic>[];
    return items
        .map((item) => TipModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Future<TipModel> createTip({
    required String title,
    required String description,
    required String visibility,
  }) async {
    final response = await apiClient.postData(
      AppConstants.TIPS_URI,
      <String, dynamic>{
        'title': title.trim(),
        'description': description.trim(),
        'visibility': visibility,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    return TipModel.fromJson(
      Map<String, dynamic>.from(response.body['tip'] as Map),
    );
  }

  Future<TipModel> toggleTipSave(String tipId) async {
    final response = await apiClient.postData(
      '${AppConstants.TIPS_URI}/$tipId/save',
      <String, dynamic>{},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    final body = response.body is Map<String, dynamic>
        ? response.body as Map<String, dynamic>
        : <String, dynamic>{};

    final tip = body['tip'];
    if (tip is Map<String, dynamic>) {
      return TipModel.fromJson(tip);
    }

    return TipModel(
      id: tipId,
      ownerId: '',
      ownerType: '',
      title: '',
      description: '',
      saves: int.tryParse(body['saves']?.toString() ?? '0') ?? 0,
      isSaved: body['saved'] == true,
    );
  }

  Future<void> deleteTip(String tipId) async {
    final response = await apiClient.deleteData('${AppConstants.TIPS_URI}/$tipId');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }
  }

  Future<List<ProductModel>> getProducts({
    required String companyId,
    int limit = 50,
  }) async {
    final response = await apiClient.getData(
      '${AppConstants.PRODUCTS_URI}?companyId=$companyId&limit=$limit',
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    final rawItems = response.body is Map ? response.body['products'] : null;
    final items = rawItems is List ? rawItems : const <dynamic>[];
    return items
        .map((item) => ProductModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  Future<List<EventModel>> getEvents({
    required String ownerId,
    required String ownerType,
    int limit = 20,
  }) async {
    final response = await apiClient.getData(
      '${AppConstants.GET_EVENT}?creatorId=$ownerId&creatorType=$ownerType&limit=$limit&status=all',
    );

    if (response.statusCode != 200) {
      throw Exception(
        response.body is Map
            ? response.body['message']?.toString()
            : response.statusText,
      );
    }

    final rawItems = response.body is Map ? response.body['events'] : null;
    final items = rawItems is List ? rawItems : const <dynamic>[];
    return items
        .map((item) => EventModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }
}
