import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repo/company_analytics_repo.dart';
import '../models/company_analytics_model.dart';
import '../widgets/snackbars.dart';

enum CompanyAnalyticsTimeframe {
  oneDay('1d', '1 Day'),
  oneWeek('1w', '1 Week'),
  oneMonth('1m', '1 Month'),
  threeMonths('3m', '3 Months'),
  sixMonths('6m', '6 Months'),
  oneYear('1y', '1 Year'),
  custom('custom', 'Custom');

  const CompanyAnalyticsTimeframe(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class CompanyAnalyticsController extends GetxController {
  final CompanyAnalyticsRepo companyAnalyticsRepo;

  CompanyAnalyticsController({required this.companyAnalyticsRepo});

  final Rx<CompanyAnalyticsTimeframe> selectedTimeframe =
      CompanyAnalyticsTimeframe.oneWeek.obs;
  final Rxn<DateTimeRange> customRange = Rxn<DateTimeRange>();
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final Rxn<CompanyAnalyticsOverviewModel> overview =
      Rxn<CompanyAnalyticsOverviewModel>();

  Future<void> loadOverview({
    CompanyAnalyticsTimeframe? timeframe,
    DateTimeRange? range,
    bool showErrorSnackBar = false,
  }) async {
    final nextTimeframe = timeframe ?? selectedTimeframe.value;
    selectedTimeframe.value = nextTimeframe;
    customRange.value = nextTimeframe == CompanyAnalyticsTimeframe.custom
        ? range ?? customRange.value
        : null;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final data = nextTimeframe == CompanyAnalyticsTimeframe.custom
          ? await companyAnalyticsRepo.getOverview(
              startDate: (range ?? customRange.value)?.start,
              endDate: (range ?? customRange.value)?.end,
            )
          : await companyAnalyticsRepo.getOverview(
              timeframe: nextTimeframe.apiValue,
            );
      overview.value = data;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      if (showErrorSnackBar) {
        CustomSnackBar.failure(message: errorMessage.value!);
      }
    } finally {
      isLoading.value = false;
    }
  }
}
