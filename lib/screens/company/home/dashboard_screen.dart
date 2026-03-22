import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/company_analytics_controller.dart';
import 'package:smart_swatcher/models/company_analytics_model.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

import '../../../routes/routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final CompanyAnalyticsController analyticsController =
      Get.find<CompanyAnalyticsController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.getCompanyProfile();
      analyticsController.loadOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        customTitle: Obx(
          () => Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Welcome, ${authController.companyProfile.value?.companyName?.capitalizeFirst ?? 'Company'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        actionIcon: InkWell(
          onTap: () => Get.toNamed(AppRoutes.notificationScreen),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width5,
              vertical: Dimensions.height5,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey3),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.grey5,
            ),
          ),
        ),
      ),
      body: Obx(() {
        final overview = analyticsController.overview.value;
        final isLoading = analyticsController.isLoading.value;
        final errorMessage = analyticsController.errorMessage.value;

        if (isLoading && overview == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary5),
          );
        }

        if (overview == null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: Dimensions.iconSize24 * 2,
                    color: AppColors.grey4,
                  ),
                  SizedBox(height: Dimensions.height15),
                  Text(
                    errorMessage ?? 'Unable to load analytics right now.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      color: AppColors.grey5,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  ElevatedButton(
                    onPressed: () => analyticsController.loadOverview(
                      showErrorSnackBar: true,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary5,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final cards = <_AnalyticsCardData>[
          _AnalyticsCardData(
            title: 'Views',
            metric: overview.views,
            routeName: AppRoutes.viewsScreen,
            highlight: true,
          ),
          _AnalyticsCardData(
            title: 'Engagement',
            metric: overview.engagement,
            routeName: AppRoutes.engagementScreen,
            highlight: true,
          ),
          _AnalyticsCardData(
            title: 'Formulas usage',
            metric: overview.formulasUsage,
          ),
          _AnalyticsCardData(
            title: 'Saved',
            metric: overview.saved,
            routeName: AppRoutes.savesScreen,
          ),
          _AnalyticsCardData(
            title: 'Downloads',
            metric: overview.downloads,
            routeName: AppRoutes.downloadsScreen,
          ),
          _AnalyticsCardData(
            title: 'Events',
            metric: overview.events,
            routeName: AppRoutes.eventsScreen,
          ),
          _AnalyticsCardData(
            title: 'Followers',
            metric: overview.followers,
            routeName: AppRoutes.followersScreen,
          ),
        ];

        return RefreshIndicator(
          color: AppColors.primary5,
          onRefresh: () => analyticsController.loadOverview(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: Dimensions.font18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CompanyAnalyticsTimeframe.values.map((timeframe) {
                      final isSelected =
                          analyticsController.selectedTimeframe.value == timeframe;

                      return Padding(
                        padding: EdgeInsets.only(right: Dimensions.width10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          onTap: () => analyticsController.loadOverview(
                            timeframe: timeframe,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width15,
                              vertical: Dimensions.height10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary5
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius20,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary5
                                    : AppColors.grey3,
                              ),
                            ),
                            child: Text(
                              timeframe.label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.black1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: Dimensions.height15),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    border: Border.all(color: AppColors.grey3),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.grey5,
                        size: Dimensions.iconSize16,
                      ),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: Text(
                          _formatRange(overview.range),
                          style: TextStyle(
                            fontSize: Dimensions.font13,
                            color: AppColors.grey5,
                          ),
                        ),
                      ),
                      if (isLoading)
                        SizedBox(
                          width: Dimensions.iconSize16,
                          height: Dimensions.iconSize16,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary5,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Wrap(
                  spacing: Dimensions.width15,
                  runSpacing: Dimensions.height15,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width: (Dimensions.screenWidth - (Dimensions.width20 * 2) - Dimensions.width15) / 2,
                          child: _DashboardMetricCard(card: card),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: Dimensions.height100 + Dimensions.height20),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _formatRange(CompanyAnalyticsRangeModel range) {
    final startAt = range.startAt;
    final endAt = range.endAt;
    if (startAt == null || endAt == null) {
      return 'Current period';
    }

    final formatter = DateFormat('dd MMM');
    return '${formatter.format(startAt.toLocal())} - ${formatter.format(endAt.toLocal())}';
  }
}

class _AnalyticsCardData {
  final String title;
  final CompanyAnalyticsTrendModel metric;
  final String? routeName;
  final bool highlight;

  const _AnalyticsCardData({
    required this.title,
    required this.metric,
    this.routeName,
    this.highlight = false,
  });
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({required this.card});

  final _AnalyticsCardData card;

  @override
  Widget build(BuildContext context) {
    final isPositive = card.metric.change >= 0;
    final trendColor = card.metric.change == 0
        ? AppColors.grey5
        : isPositive
            ? AppColors.primary5
            : AppColors.error;

    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height20,
      ),
      decoration: BoxDecoration(
        color: card.highlight ? AppColors.primary1 : AppColors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(
          color: card.highlight ? AppColors.primary2 : AppColors.grey3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: TextStyle(
              fontSize: Dimensions.font13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            NumberFormat.compact().format(card.metric.value),
            style: TextStyle(
              fontSize: Dimensions.font25,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Row(
            children: [
              Icon(
                card.metric.change == 0
                    ? CupertinoIcons.minus_circle
                    : isPositive
                        ? CupertinoIcons.arrow_up_circle_fill
                        : CupertinoIcons.arrow_down_circle_fill,
                color: trendColor,
                size: Dimensions.iconSize16,
              ),
              SizedBox(width: Dimensions.width5),
              Text(
                '${card.metric.changePercentage.toStringAsFixed(card.metric.changePercentage.truncateToDouble() == card.metric.changePercentage ? 0 : 1)}%',
                style: TextStyle(
                  color: trendColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (card.routeName == null) {
      return child;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius20),
      onTap: () => Get.toNamed(card.routeName!),
      child: child,
    );
  }
}
