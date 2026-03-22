import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_swatcher/controllers/auth_controller.dart';
import 'package:smart_swatcher/controllers/company_analytics_controller.dart';
import 'package:smart_swatcher/models/company_analytics_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final CompanyAnalyticsController analyticsController =
      Get.find<CompanyAnalyticsController>();
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  String _selectedMetricId = 'views';
  bool _coachChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await authController.getCompanyProfile();
      await analyticsController.loadOverview();
      _maybeShowCoach();
    });
  }

  Future<void> _maybeShowCoach() async {
    if (_coachChecked || !mounted) {
      return;
    }

    _coachChecked = true;
    final hasShown = sharedPreferences.getBool(
          AppConstants.COMPANY_DASHBOARD_COACH_SHOWN,
        ) ??
        false;
    if (hasShown) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _CompanyCoachDialog(),
    );

    await sharedPreferences.setBool(
      AppConstants.COMPANY_DASHBOARD_COACH_SHOWN,
      true,
    );
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final existingRange = analyticsController.customRange.value;
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: existingRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 6)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary5,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.black1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedRange == null) {
      return;
    }

    await analyticsController.loadOverview(
      timeframe: CompanyAnalyticsTimeframe.custom,
      range: pickedRange,
    );
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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font18,
              ),
            ),
          ),
        ),
        actionIcon: InkWell(
          onTap: () => Get.toNamed(AppRoutes.notificationScreen),
          child: Container(
            padding: EdgeInsets.all(Dimensions.width10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.grey3),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: AppColors.grey5,
              size: Dimensions.iconSize20,
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
            id: 'views',
            title: 'Views',
            metric: overview.views,
            highlight: true,
            detailHint:
                'Unique post, profile, product, and event views recorded in the selected window.',
          ),
          _AnalyticsCardData(
            id: 'engagement',
            title: 'Engagement',
            metric: overview.engagement,
            highlight: true,
            detailHint:
                'All meaningful interactions across posts, tips, downloads, subscriptions, joins, and formulation usage.',
          ),
          _AnalyticsCardData(
            id: 'formulasUsage',
            title: 'Formulas usage',
            metric: overview.formulasUsage,
            detailHint:
                'How often users actually used company formulations in the selected period.',
          ),
          _AnalyticsCardData(
            id: 'saved',
            title: 'Saved',
            metric: overview.saved,
            detailHint:
                'Saves now include post saves, tip saves, and event subscriptions.',
          ),
          _AnalyticsCardData(
            id: 'downloads',
            title: 'Downloads',
            metric: overview.downloads,
            detailHint:
                'Tracked product, event, or formulation downloads tied back to company resources.',
          ),
          _AnalyticsCardData(
            id: 'events',
            title: 'Events',
            metric: overview.events,
            detailHint: 'Events created during the selected window.',
          ),
          _AnalyticsCardData(
            id: 'followers',
            title: 'Followers',
            metric: overview.followers,
            detailHint:
                'Accepted connection snapshot at the end of the selected time window.',
          ),
        ];

        final selectedCard = cards.firstWhere(
          (card) => card.id == _selectedMetricId,
          orElse: () => cards.first,
        );

        return RefreshIndicator(
          color: AppColors.primary5,
          onRefresh: () => analyticsController.loadOverview(
            timeframe: analyticsController.selectedTimeframe.value,
            range: analyticsController.customRange.value,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height15,
              Dimensions.width20,
              Dimensions.height100 + Dimensions.height20,
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
                SizedBox(height: Dimensions.height15),
                Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label:
                            analyticsController.selectedTimeframe.value.label,
                        icon: Icons.keyboard_arrow_down_rounded,
                        onTap: _showTimeframeMenu,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Expanded(
                      child: _FilterChip(
                        label: _formatRange(overview.range),
                        icon: Icons.date_range_outlined,
                        alignLeft: true,
                        onTap: _pickCustomRange,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                Wrap(
                  spacing: Dimensions.width10,
                  runSpacing: Dimensions.height12,
                  children: cards.map((card) {
                    return SizedBox(
                      width: (Dimensions.screenWidth -
                              (Dimensions.width20 * 2) -
                              Dimensions.width10) /
                          2,
                      child: _DashboardMetricCard(
                        card: card,
                        isSelected: selectedCard.id == card.id,
                        onTap: () {
                          setState(() {
                            _selectedMetricId = card.id;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: Dimensions.height20),
                _MetricDetailCard(card: selectedCard),
                if (isLoading) ...[
                  SizedBox(height: Dimensions.height15),
                  Row(
                    children: [
                      SizedBox(
                        width: Dimensions.iconSize16,
                        height: Dimensions.iconSize16,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary5,
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      Text(
                        'Refreshing analytics...',
                        style: TextStyle(
                          color: AppColors.grey5,
                          fontSize: Dimensions.font12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _showTimeframeMenu() async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return;
    }

    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) {
      return;
    }

    final selected = await showMenu<CompanyAnalyticsTimeframe>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          renderBox.localToGlobal(
            Offset(Dimensions.width20, Dimensions.height100),
            ancestor: overlay,
          ),
          renderBox.localToGlobal(
            Offset(
              Dimensions.screenWidth / 2,
              Dimensions.height100 + Dimensions.height40,
            ),
            ancestor: overlay,
          ),
        ),
        Offset.zero & overlay.size,
      ),
      color: Colors.white,
      items: CompanyAnalyticsTimeframe.values.map((timeframe) {
        return PopupMenuItem<CompanyAnalyticsTimeframe>(
          value: timeframe,
          child: Text(timeframe.label),
        );
      }).toList(),
    );

    if (selected == null) {
      return;
    }

    if (selected == CompanyAnalyticsTimeframe.custom) {
      await _pickCustomRange();
      return;
    }

    await analyticsController.loadOverview(timeframe: selected);
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
  const _AnalyticsCardData({
    required this.id,
    required this.title,
    required this.metric,
    required this.detailHint,
    this.highlight = false,
  });

  final String id;
  final String title;
  final CompanyAnalyticsTrendModel metric;
  final String detailHint;
  final bool highlight;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.alignLeft = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius20),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(color: AppColors.grey3),
        ),
        child: Row(
          mainAxisAlignment:
              alignLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            if (alignLeft) ...[
              Icon(
                icon,
                color: AppColors.grey5,
                size: Dimensions.iconSize16,
              ),
              SizedBox(width: Dimensions.width10),
            ],
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: Dimensions.font12,
                  color: AppColors.black1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (!alignLeft)
              Icon(
                icon,
                color: AppColors.grey5,
                size: Dimensions.iconSize16,
              ),
          ],
        ),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  final _AnalyticsCardData card;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPositive = card.metric.change >= 0;
    final trendColor = card.metric.change == 0
        ? AppColors.grey5
        : isPositive
            ? const Color(0xFF2E9D50)
            : AppColors.error;

    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height18,
        ),
        decoration: BoxDecoration(
          color: card.highlight ? const Color(0xFFFBEFE9) : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary5
                : card.highlight
                    ? const Color(0xFFF2CDBA)
                    : AppColors.grey3,
            width: isSelected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
              NumberFormat.decimalPattern().format(card.metric.value),
              style: TextStyle(
                fontSize: Dimensions.font22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: Dimensions.height10),
            Row(
              children: [
                Icon(
                  card.metric.change == 0
                      ? Icons.remove_circle_outline_rounded
                      : isPositive
                          ? Icons.arrow_circle_up_rounded
                          : Icons.arrow_circle_down_rounded,
                  color: trendColor,
                  size: Dimensions.iconSize16,
                ),
                SizedBox(width: Dimensions.width5),
                Text(
                  '${card.metric.changePercentage.toStringAsFixed(card.metric.changePercentage.truncateToDouble() == card.metric.changePercentage ? 0 : 1)}%',
                  style: TextStyle(
                    color: trendColor,
                    fontWeight: FontWeight.w600,
                    fontSize: Dimensions.font12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricDetailCard extends StatelessWidget {
  const _MetricDetailCard({required this.card});

  final _AnalyticsCardData card;

  @override
  Widget build(BuildContext context) {
    final breakdown = card.metric.breakdown ?? const <String, dynamic>{};
    final breakdownEntries = breakdown.entries
        .where((entry) => entry.value != null)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: AppColors.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: TextStyle(
              fontSize: Dimensions.font18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            card.detailHint,
            style: TextStyle(
              fontSize: Dimensions.font13,
              color: AppColors.grey5,
              height: 1.5,
            ),
          ),
          SizedBox(height: Dimensions.height18),
          Row(
            children: [
              Expanded(
                child: _MetricStatCell(
                  label: 'Current',
                  value: NumberFormat.decimalPattern().format(card.metric.value),
                ),
              ),
              Expanded(
                child: _MetricStatCell(
                  label: 'Previous',
                  value: NumberFormat.decimalPattern().format(
                    card.metric.previousValue,
                  ),
                ),
              ),
              Expanded(
                child: _MetricStatCell(
                  label: 'Change',
                  value:
                      '${card.metric.change > 0 ? '+' : ''}${NumberFormat.decimalPattern().format(card.metric.change)}',
                ),
              ),
            ],
          ),
          if (breakdownEntries.isNotEmpty) ...[
            SizedBox(height: Dimensions.height20),
            Text(
              'Details',
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.height12),
            ...breakdownEntries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: Dimensions.height10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _labelizeBreakdownKey(entry.key),
                        style: TextStyle(
                          color: AppColors.grey5,
                          fontSize: Dimensions.font13,
                        ),
                      ),
                    ),
                    Text(
                      _formatBreakdownValue(entry.value),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Dimensions.font13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _labelizeBreakdownKey(String key) {
    final withSpaces = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }

  String _formatBreakdownValue(dynamic value) {
    if (value is num) {
      return NumberFormat.decimalPattern().format(value);
    }
    return value.toString();
  }
}

class _MetricStatCell extends StatelessWidget {
  const _MetricStatCell({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey5,
            fontSize: Dimensions.font12,
          ),
        ),
        SizedBox(height: Dimensions.height8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: Dimensions.font16,
          ),
        ),
      ],
    );
  }
}

class _CompanyCoachDialog extends StatefulWidget {
  const _CompanyCoachDialog();

  @override
  State<_CompanyCoachDialog> createState() => _CompanyCoachDialogState();
}

class _CompanyCoachDialogState extends State<_CompanyCoachDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_CoachSlideData> _slides = const [
    _CoachSlideData(
      imageAsset: 'assets/images/sug1.png',
      title: 'Dashboard',
      description:
          'View key stats at a glance and tap any card for detailed insights.',
    ),
    _CoachSlideData(
      imageAsset: 'assets/images/sug2.png',
      title: 'Formulator',
      description:
          'Mix and manage formulas while keeping previews and saved work in one place.',
    ),
    _CoachSlideData(
      imageAsset: 'assets/images/sug3.png',
      title: 'Color club',
      description:
          'Upload, connect, host spaces, and share media with your community.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      child: Container(
        padding: EdgeInsets.all(Dimensions.width15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: Dimensions.height100 * 3.2,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20),
                          child: Image.asset(
                            slide.imageAsset,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.height15),
                      Text(
                        slide.title,
                        style: TextStyle(
                          fontSize: Dimensions.font18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: Dimensions.font13,
                          color: AppColors.grey5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: Dimensions.height15),
            Row(
              children: List.generate(
                _slides.length,
                (index) => Container(
                  width: Dimensions.width8,
                  height: Dimensions.width8,
                  margin: EdgeInsets.only(right: Dimensions.width5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.primary5
                        : AppColors.grey3,
                  ),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  if (_currentPage == _slides.length - 1) {
                    Navigator.of(context).pop();
                    return;
                  }

                  await _pageController.nextPage(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  );
                },
                child: Text(
                  _currentPage == _slides.length - 1 ? 'Done' : 'Next',
                  style: TextStyle(
                    color: AppColors.primary5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachSlideData {
  const _CoachSlideData({
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  final String imageAsset;
  final String title;
  final String description;
}
