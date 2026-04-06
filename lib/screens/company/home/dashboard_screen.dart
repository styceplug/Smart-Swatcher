import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
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
    final hasShown =
        sharedPreferences.getBool(AppConstants.COMPANY_DASHBOARD_COACH_SHOWN) ??
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
      initialDateRange:
          existingRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 6)), end: now),
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

  Future<void> _showMetricDetailSheet(
    _AnalyticsCardData card,
    CompanyAnalyticsRangeModel range,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MetricDetailSheet(card: card, range: range),
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
                    onPressed:
                        () => analyticsController.loadOverview(
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
          onRefresh:
              () => analyticsController.loadOverview(
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
                  children:
                      cards.map((card) {
                        return SizedBox(
                          width:
                              (Dimensions.screenWidth -
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
                              _showMetricDetailSheet(card, overview.range);
                            },
                          ),
                        );
                      }).toList(),
                ),
                SizedBox(height: Dimensions.height15),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8F4),
                    borderRadius: BorderRadius.circular(Dimensions.radius20),
                    border: Border.all(color: const Color(0xFFF1DDD2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary5.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: AppColors.primary5,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: Text(
                          'Tap any metric card to open a detailed analytics sheet with charts, breakdowns, and trend insights.',
                          style: TextStyle(
                            fontSize: Dimensions.font12,
                            color: AppColors.grey5,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
      items:
          CompanyAnalyticsTimeframe.values.map((timeframe) {
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
              Icon(icon, color: AppColors.grey5, size: Dimensions.iconSize16),
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
              Icon(icon, color: AppColors.grey5, size: Dimensions.iconSize16),
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
    final trendColor =
        card.metric.change == 0
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
            color:
                isSelected
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

class _MetricDetailSheet extends StatelessWidget {
  const _MetricDetailSheet({required this.card, required this.range});

  final _AnalyticsCardData card;
  final CompanyAnalyticsRangeModel range;

  @override
  Widget build(BuildContext context) {
    final accent = _metricAccent(card.id);
    final breakdown = card.metric.breakdown ?? const <String, dynamic>{};
    final numericEntries = breakdown.entries
        .where((entry) => _toNumeric(entry.value) > 0)
        .toList(growable: false);
    final detailEntries = breakdown.entries
        .where((entry) => entry.value != null)
        .toList(growable: false);

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF7F3EF),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Dimensions.radius30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(height: Dimensions.height12),
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.grey3,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Dimensions.width20,
                    Dimensions.height15,
                    Dimensions.width20,
                    Dimensions.height24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MetricSheetHeader(
                        card: card,
                        range: range,
                        accent: accent,
                      ),
                      SizedBox(height: Dimensions.height18),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricInfoTile(
                              label: 'Current',
                              value: _formatNumber(card.metric.value),
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          Expanded(
                            child: _MetricInfoTile(
                              label: 'Previous',
                              value: _formatNumber(card.metric.previousValue),
                            ),
                          ),
                          SizedBox(width: Dimensions.width10),
                          Expanded(
                            child: _MetricInfoTile(
                              label: 'Net change',
                              value:
                                  '${card.metric.change > 0 ? '+' : ''}${_formatNumber(card.metric.change)}',
                              accent: accent,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Dimensions.height18),
                      _MetricSectionCard(
                        title: 'Trend pulse',
                        subtitle:
                            'A quick comparison of the current period against the previous window.',
                        child: _MetricComparisonChart(
                          metric: card.metric,
                          accent: accent,
                        ),
                      ),
                      if (numericEntries.isNotEmpty) ...[
                        SizedBox(height: Dimensions.height15),
                        _MetricSectionCard(
                          title: 'Breakdown map',
                          subtitle:
                              'See which signals are contributing most to ${card.title.toLowerCase()}.',
                          child: _MetricBreakdownSection(
                            entries: numericEntries,
                            accent: accent,
                          ),
                        ),
                      ],
                      if (detailEntries.isNotEmpty) ...[
                        SizedBox(height: Dimensions.height15),
                        _MetricSectionCard(
                          title: 'Signals',
                          subtitle:
                              'Detailed values feeding this metric in the selected timeframe.',
                          child: Column(
                            children:
                                detailEntries
                                    .map(
                                      (entry) => _MetricBreakdownRow(
                                        label: _labelizeBreakdownKey(entry.key),
                                        value: _formatBreakdownValue(
                                          entry.value,
                                        ),
                                        ratio:
                                            numericEntries.isNotEmpty
                                                ? _safeRatio(
                                                  _toNumeric(entry.value),
                                                  numericEntries
                                                      .map(
                                                        (item) => _toNumeric(
                                                          item.value,
                                                        ),
                                                      )
                                                      .fold<double>(
                                                        0,
                                                        (sum, value) =>
                                                            sum + value,
                                                      ),
                                                )
                                                : null,
                                        accent: accent,
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricSheetHeader extends StatelessWidget {
  const _MetricSheetHeader({
    required this.card,
    required this.range,
    required this.accent,
  });

  final _AnalyticsCardData card;
  final CompanyAnalyticsRangeModel range;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final change = card.metric.change;
    final isPositive = change >= 0;
    final trendColor =
        change == 0
            ? AppColors.grey5
            : isPositive
            ? const Color(0xFF239B56)
            : const Color(0xFFD95040);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.18),
            Colors.white,
            const Color(0xFFFFF5EF),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimensions.radius30),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  card.title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      change == 0
                          ? Icons.remove_rounded
                          : isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: trendColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${card.metric.changePercentage.toStringAsFixed(card.metric.changePercentage.truncateToDouble() == card.metric.changePercentage ? 0 : 1)}%',
                      style: TextStyle(
                        color: trendColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height18),
          Text(
            _formatNumber(card.metric.value),
            style: TextStyle(
              fontSize: Dimensions.font28,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ),
          SizedBox(height: Dimensions.height8),
          Text(
            card.detailHint,
            style: TextStyle(
              fontSize: Dimensions.font13,
              color: AppColors.grey5,
              height: 1.55,
            ),
          ),
          SizedBox(height: Dimensions.height15),
          Row(
            children: [
              _InsightChip(
                icon: Icons.calendar_month_rounded,
                label: _formatRangeLabel(range),
              ),
              SizedBox(width: Dimensions.width8),
              _InsightChip(
                icon: Icons.auto_graph_rounded,
                label: _trendLabel(card.metric.trend),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricInfoTile extends StatelessWidget {
  const _MetricInfoTile({
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width15,
        vertical: Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.grey5,
              fontSize: Dimensions.font12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.height8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: Dimensions.font16,
              color: accent ?? AppColors.black1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSectionCard extends StatelessWidget {
  const _MetricSectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: AppColors.grey2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: Dimensions.height5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: Dimensions.font12,
              color: AppColors.grey5,
              height: 1.5,
            ),
          ),
          SizedBox(height: Dimensions.height18),
          child,
        ],
      ),
    );
  }
}

class _MetricComparisonChart extends StatelessWidget {
  const _MetricComparisonChart({required this.metric, required this.accent});

  final CompanyAnalyticsTrendModel metric;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final maxValue = math.max(
      metric.value.toDouble(),
      metric.previousValue.toDouble(),
    );
    final maxY = maxValue <= 0 ? 10.0 : maxValue * 1.25;

    return SizedBox(
      height: 210,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine:
                (value) => FlLine(color: AppColors.grey2, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                interval: maxY / 4,
                getTitlesWidget:
                    (value, _) => Text(
                      _compactNumber(value),
                      style: TextStyle(
                        fontSize: Dimensions.font10,
                        color: AppColors.grey5,
                      ),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final labels = ['Previous', 'Current'];
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        fontSize: Dimensions.font12,
                        color: AppColors.grey5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            _barGroup(
              x: 0,
              value: metric.previousValue.toDouble(),
              color: const Color(0xFFE0D6CF),
            ),
            _barGroup(x: 1, value: metric.value.toDouble(), color: accent),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup({
    required int x,
    required double value,
    required Color color,
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withValues(alpha: 0.68)],
          ),
        ),
      ],
    );
  }
}

class _MetricBreakdownSection extends StatelessWidget {
  const _MetricBreakdownSection({required this.entries, required this.accent});

  final List<MapEntry<String, dynamic>> entries;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<double>(
      0,
      (sum, entry) => sum + _toNumeric(entry.value),
    );
    final palette = <Color>[
      accent,
      const Color(0xFFFF9A62),
      const Color(0xFF6AC3B8),
      const Color(0xFF8D77FF),
      const Color(0xFFFFCF6A),
      const Color(0xFFEF6A7B),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 42,
              sectionsSpace: 4,
              sections: List.generate(entries.length, (index) {
                final value = _toNumeric(entries[index].value);
                return PieChartSectionData(
                  value: value <= 0 ? 0.01 : value,
                  color: palette[index % palette.length],
                  radius: 18,
                  title: '',
                );
              }),
            ),
          ),
        ),
        SizedBox(width: Dimensions.width15),
        Expanded(
          child: Column(
            children: List.generate(entries.length, (index) {
              final entry = entries[index];
              return _MetricBreakdownRow(
                label: _labelizeBreakdownKey(entry.key),
                value: _formatBreakdownValue(entry.value),
                ratio: _safeRatio(_toNumeric(entry.value), total),
                accent: palette[index % palette.length],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MetricBreakdownRow extends StatelessWidget {
  const _MetricBreakdownRow({
    required this.label,
    required this.value,
    required this.accent,
    this.ratio,
  });

  final String label;
  final String value;
  final Color accent;
  final double? ratio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.height12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: Dimensions.width8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: Dimensions.font12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: Dimensions.font12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey5,
                ),
              ),
            ],
          ),
          if (ratio != null) ...[
            SizedBox(height: Dimensions.height8),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio!.clamp(0, 1),
                minHeight: 8,
                backgroundColor: AppColors.grey1,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.grey5),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font12,
              fontWeight: FontWeight.w600,
              color: AppColors.grey5,
            ),
          ),
        ],
      ),
    );
  }
}

Color _metricAccent(String metricId) {
  switch (metricId) {
    case 'engagement':
      return const Color(0xFFCB6A2E);
    case 'saved':
      return const Color(0xFF3B8F6A);
    case 'downloads':
      return const Color(0xFF5864E8);
    case 'events':
      return const Color(0xFF9A4FD8);
    case 'followers':
      return const Color(0xFFEE7A5F);
    case 'formulasUsage':
      return const Color(0xFFB37431);
    case 'views':
    default:
      return AppColors.primary5;
  }
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

String _formatNumber(num value) {
  return NumberFormat.decimalPattern().format(value);
}

double _toNumeric(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double _safeRatio(double value, double total) {
  if (total <= 0) {
    return 0;
  }
  return value / total;
}

String _trendLabel(String trend) {
  switch (trend.toLowerCase()) {
    case 'up':
      return 'Upward momentum';
    case 'down':
      return 'Cooling down';
    case 'flat':
    default:
      return 'Holding steady';
  }
}

String _compactNumber(double value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(0);
}

String _formatRangeLabel(CompanyAnalyticsRangeModel range) {
  final startAt = range.startAt;
  final endAt = range.endAt;
  if (startAt == null || endAt == null) {
    return 'Current period';
  }
  final formatter = DateFormat('dd MMM');
  return '${formatter.format(startAt.toLocal())} - ${formatter.format(endAt.toLocal())}';
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
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
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
                    color:
                        _currentPage == index
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
