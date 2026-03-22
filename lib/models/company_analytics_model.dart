class CompanyAnalyticsRangeModel {
  final String timeframe;
  final bool isCustom;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime? previousStartAt;
  final DateTime? previousEndAt;

  const CompanyAnalyticsRangeModel({
    required this.timeframe,
    required this.isCustom,
    this.startAt,
    this.endAt,
    this.previousStartAt,
    this.previousEndAt,
  });

  factory CompanyAnalyticsRangeModel.fromJson(Map<String, dynamic>? json) {
    return CompanyAnalyticsRangeModel(
      timeframe: json?['timeframe']?.toString() ?? '1w',
      isCustom: json?['isCustom'] == true,
      startAt: json?['startAt'] != null
          ? DateTime.tryParse(json!['startAt'].toString())
          : null,
      endAt: json?['endAt'] != null
          ? DateTime.tryParse(json!['endAt'].toString())
          : null,
      previousStartAt: json?['previousStartAt'] != null
          ? DateTime.tryParse(json!['previousStartAt'].toString())
          : null,
      previousEndAt: json?['previousEndAt'] != null
          ? DateTime.tryParse(json!['previousEndAt'].toString())
          : null,
    );
  }
}

class CompanyAnalyticsTrendModel {
  final int value;
  final int previousValue;
  final int change;
  final double changePercentage;
  final String trend;
  final Map<String, dynamic>? breakdown;

  const CompanyAnalyticsTrendModel({
    this.value = 0,
    this.previousValue = 0,
    this.change = 0,
    this.changePercentage = 0,
    this.trend = 'flat',
    this.breakdown,
  });

  factory CompanyAnalyticsTrendModel.fromJson(Map<String, dynamic>? json) {
    return CompanyAnalyticsTrendModel(
      value: int.tryParse(json?['value']?.toString() ?? '0') ?? 0,
      previousValue:
          int.tryParse(json?['previousValue']?.toString() ?? '0') ?? 0,
      change: int.tryParse(json?['change']?.toString() ?? '0') ?? 0,
      changePercentage:
          double.tryParse(json?['changePercentage']?.toString() ?? '0') ?? 0,
      trend: json?['trend']?.toString() ?? 'flat',
      breakdown: json?['breakdown'] is Map<String, dynamic>
          ? json!['breakdown'] as Map<String, dynamic>
          : null,
    );
  }
}

class CompanyAnalyticsOverviewModel {
  final CompanyAnalyticsRangeModel range;
  final CompanyAnalyticsTrendModel views;
  final CompanyAnalyticsTrendModel engagement;
  final CompanyAnalyticsTrendModel formulasUsage;
  final CompanyAnalyticsTrendModel saved;
  final CompanyAnalyticsTrendModel downloads;
  final CompanyAnalyticsTrendModel events;
  final CompanyAnalyticsTrendModel followers;

  const CompanyAnalyticsOverviewModel({
    required this.range,
    required this.views,
    required this.engagement,
    required this.formulasUsage,
    required this.saved,
    required this.downloads,
    required this.events,
    required this.followers,
  });

  factory CompanyAnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    final metrics = json['metrics'] is Map<String, dynamic>
        ? json['metrics'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CompanyAnalyticsOverviewModel(
      range: CompanyAnalyticsRangeModel.fromJson(
        json['range'] is Map<String, dynamic>
            ? json['range'] as Map<String, dynamic>
            : null,
      ),
      views: CompanyAnalyticsTrendModel.fromJson(
        metrics['views'] is Map<String, dynamic>
            ? metrics['views'] as Map<String, dynamic>
            : null,
      ),
      engagement: CompanyAnalyticsTrendModel.fromJson(
        metrics['engagement'] is Map<String, dynamic>
            ? metrics['engagement'] as Map<String, dynamic>
            : null,
      ),
      formulasUsage: CompanyAnalyticsTrendModel.fromJson(
        metrics['formulasUsage'] is Map<String, dynamic>
            ? metrics['formulasUsage'] as Map<String, dynamic>
            : null,
      ),
      saved: CompanyAnalyticsTrendModel.fromJson(
        metrics['saved'] is Map<String, dynamic>
            ? metrics['saved'] as Map<String, dynamic>
            : null,
      ),
      downloads: CompanyAnalyticsTrendModel.fromJson(
        metrics['downloads'] is Map<String, dynamic>
            ? metrics['downloads'] as Map<String, dynamic>
            : null,
      ),
      events: CompanyAnalyticsTrendModel.fromJson(
        metrics['events'] is Map<String, dynamic>
            ? metrics['events'] as Map<String, dynamic>
            : null,
      ),
      followers: CompanyAnalyticsTrendModel.fromJson(
        metrics['followers'] is Map<String, dynamic>
            ? metrics['followers'] as Map<String, dynamic>
            : null,
      ),
    );
  }
}
