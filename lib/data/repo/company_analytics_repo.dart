import 'package:intl/intl.dart';

import '../../models/company_analytics_model.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class CompanyAnalyticsRepo {
  final ApiClient apiClient;

  CompanyAnalyticsRepo({required this.apiClient});

  Future<CompanyAnalyticsOverviewModel> getOverview({
    String? timeframe,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final params = <String>[];
    final dateFormat = DateFormat('yyyy-MM-dd');

    if (startDate != null && endDate != null) {
      params.add('startDate=${dateFormat.format(startDate)}');
      params.add('endDate=${dateFormat.format(endDate)}');
    } else if (timeframe != null && timeframe.trim().isNotEmpty) {
      params.add('timeframe=$timeframe');
    } else {
      params.add('timeframe=1w');
    }

    final response = await apiClient.getData(
      '${AppConstants.COMPANY_ANALYTICS_OVERVIEW}?${params.join('&')}',
    );

    if (response.statusCode != 200) {
      final message = response.body is Map
          ? response.body['message']?.toString()
          : response.statusText;
      throw Exception(message ?? 'Unable to load company analytics');
    }

    return CompanyAnalyticsOverviewModel.fromJson(
      response.body is Map<String, dynamic>
          ? response.body as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }
}
