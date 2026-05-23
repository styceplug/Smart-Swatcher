import 'dart:convert';

class FormulationModel {
  String id;
  String folderId;
  String formulationType;
  String status;
  String? imageUrl;
  String? predictionImageUrl;
  String predictionImageStatus;
  String? predictionImagePrompt;
  String? predictionImageRevisedPrompt;
  String? predictionOpenAiResponseId;
  String? predictionImageError;
  String? predictionErrorCategory;
  String? predictionErrorCode;
  int predictionRetryCount;
  String? predictionRetryNextAt;
  String? predictionRequestedAt;
  String? predictionCompletedAt;
  String? finalImageUrl;

  num naturalBaseLevel;
  num greyPercentage;
  num desiredLevel;
  num developerVolume;
  num? previousColorLevel;
  num? targetLevel;

  String? shadeType;
  String? desiredTone;
  String? previousColorTone;
  String? targetTone;
  String? mixingRatio;
  String? noteToStylist;
  String? longDescription;

  List<dynamic> steps;
  List<dynamic> media;
  Map<String, dynamic>? inputData;
  Map<String, dynamic>? resultData;
  String? logicVersion;
  String? createdAt;
  FormulationToneProfile? toneProfile;
  FormulationToneProfile? desiredToneProfile;
  FormulationToneProfile? previousToneProfile;
  FormulationToneProfile? targetToneProfile;

  FormulationModel({
    this.id = "",
    required this.folderId,
    this.formulationType = 'color_formulation',
    required this.status,
    this.imageUrl,
    this.predictionImageUrl,
    this.predictionImageStatus = 'not_requested',
    this.predictionImagePrompt,
    this.predictionImageRevisedPrompt,
    this.predictionOpenAiResponseId,
    this.predictionImageError,
    this.predictionErrorCategory,
    this.predictionErrorCode,
    this.predictionRetryCount = 0,
    this.predictionRetryNextAt,
    this.predictionRequestedAt,
    this.predictionCompletedAt,
    this.finalImageUrl,
    this.naturalBaseLevel = 0,
    this.greyPercentage = 0,
    this.desiredLevel = 0,
    this.developerVolume = 0,
    this.previousColorLevel,
    this.targetLevel,
    this.shadeType,
    this.desiredTone,
    this.previousColorTone,
    this.targetTone,
    this.mixingRatio,
    this.noteToStylist,
    this.longDescription,
    this.steps = const [],
    this.media = const [],
    this.inputData,
    this.resultData,
    this.logicVersion,
    this.createdAt,
    this.toneProfile,
    this.desiredToneProfile,
    this.previousToneProfile,
    this.targetToneProfile,
  });

  factory FormulationModel.fromJson(Map<String, dynamic> json) {
    final inputData = _mapFromJsonLike(json['inputData']);
    final resultData = _mapFromJsonLike(json['resultData']);
    final toneProfile = FormulationToneProfile.fromJsonLike(
      json['toneProfile'] ??
          inputData?['toneProfile'] ??
          resultData?['toneProfile'],
    );
    final desiredToneProfile = FormulationToneProfile.fromJsonLike(
      json['desiredToneProfile'] ??
          inputData?['desiredToneProfile'] ??
          toneProfile,
    );
    final previousToneProfile = FormulationToneProfile.fromJsonLike(
      json['previousToneProfile'] ?? inputData?['previousToneProfile'],
    );
    final targetToneProfile = FormulationToneProfile.fromJsonLike(
      json['targetToneProfile'] ??
          inputData?['targetToneProfile'] ??
          resultData?['targetToneProfile'] ??
          toneProfile,
    );

    return FormulationModel(
      id: json['id'] ?? "",
      folderId: json['folderId'] ?? "",
      formulationType: json['formulationType'] ?? 'color_formulation',
      status: json['status'] ?? "draft",
      imageUrl: json['imageUrl'],
      predictionImageUrl: json['predictionImageUrl'],
      predictionImageStatus: json['predictionImageStatus'] ?? 'not_requested',
      predictionImagePrompt: json['predictionImagePrompt'],
      predictionImageRevisedPrompt: json['predictionImageRevisedPrompt'],
      predictionOpenAiResponseId: json['predictionOpenAiResponseId'],
      predictionImageError: json['predictionImageError'],
      predictionErrorCategory: json['predictionErrorCategory'],
      predictionErrorCode: json['predictionErrorCode'],
      predictionRetryCount:
          FormulationAnalysisModel._asInt(json['predictionRetryCount']) ?? 0,
      predictionRetryNextAt: json['predictionRetryNextAt'],
      predictionRequestedAt: json['predictionRequestedAt'],
      predictionCompletedAt: json['predictionCompletedAt'],
      finalImageUrl: json['finalImageUrl'],

      naturalBaseLevel: json['naturalBaseLevel'] ?? 0,
      greyPercentage: json['greyPercentage'] ?? 0,
      desiredLevel: json['desiredLevel'] ?? 0,
      developerVolume: json['developerVolume'] ?? 0,
      previousColorLevel: json['previousColorLevel'],
      targetLevel: json['targetLevel'],

      shadeType: json['shadeType'],
      desiredTone:
          json['desiredTone'] ??
          desiredToneProfile?.display ??
          toneProfile?.display,
      previousColorTone:
          json['previousColorTone'] ?? previousToneProfile?.display,
      targetTone:
          json['targetTone'] ??
          targetToneProfile?.display ??
          toneProfile?.display,
      mixingRatio: json['mixingRatio'],
      noteToStylist: json['noteToStylist'],
      longDescription: json['longDescription'],

      steps: _listFromJsonLike(json['steps']),
      media: _listFromJsonLike(json['media']),
      inputData: inputData,
      resultData: resultData,
      logicVersion: json['logicVersion'],
      createdAt: json['createdAt'],
      toneProfile: toneProfile,
      desiredToneProfile: desiredToneProfile,
      previousToneProfile: previousToneProfile,
      targetToneProfile: targetToneProfile,
    );
  }

  bool get isPredictionActive =>
      predictionImageStatus == 'queued' ||
      predictionImageStatus == 'in_progress';

  bool get isPredictionDelayed =>
      predictionImageStatus == 'queued' &&
      (predictionRetryNextAt?.trim().isNotEmpty ?? false);

  bool get hasPredictionImage =>
      predictionImageUrl != null && predictionImageUrl!.trim().isNotEmpty;

  DateTime? get predictionRetryNextDate {
    final raw = predictionRetryNextAt?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  bool get isCorrection => formulationType == 'color_correction';

  FormulationToneProfile? get effectiveToneProfile {
    if (isCorrection) {
      return targetToneProfile ?? toneProfile;
    }
    return desiredToneProfile ?? toneProfile;
  }

  String? get toneDisplay =>
      effectiveToneProfile?.display ??
      targetToneProfile?.display ??
      desiredTone ??
      targetTone;

  FormulationAnalysisModel? get analysis =>
      FormulationAnalysisModel.fromJsonLike(resultData?['analysis']);

  static Map<String, dynamic>? _mapFromJsonLike(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        if (decoded is Map) {
          return decoded.map((key, item) => MapEntry(key.toString(), item));
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static List<dynamic> _listFromJsonLike(dynamic value) {
    if (value is List) return value;
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded;
        }
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }
}

class FormulationAnalysisModel {
  final int? estimatedBaseLevel;
  final String? estimatedBaseLabel;
  final int? estimatedGreyPercentage;
  final String? estimatedUndertone;
  final String? underlyingPigment;
  final String? recommendedShadeType;
  final String? recommendedTone;
  final List<String> recommendedToneFamilies;
  final FormulationToneProfile? recommendedToneProfile;
  final String? serviceType;
  final int? liftLevels;
  final String? neutralizer;
  final String? fillerRecommendation;
  final double? confidence;
  final String? analysisSummary;
  final List<String> cautions;

  const FormulationAnalysisModel({
    this.estimatedBaseLevel,
    this.estimatedBaseLabel,
    this.estimatedGreyPercentage,
    this.estimatedUndertone,
    this.underlyingPigment,
    this.recommendedShadeType,
    this.recommendedTone,
    this.recommendedToneFamilies = const [],
    this.recommendedToneProfile,
    this.serviceType,
    this.liftLevels,
    this.neutralizer,
    this.fillerRecommendation,
    this.confidence,
    this.analysisSummary,
    this.cautions = const [],
  });

  factory FormulationAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FormulationAnalysisModel(
      estimatedBaseLevel: _asInt(json['estimatedBaseLevel']),
      estimatedBaseLabel: _asString(json['estimatedBaseLabel']),
      estimatedGreyPercentage: _asInt(json['estimatedGreyPercentage']),
      estimatedUndertone: _asString(json['estimatedUndertone']),
      underlyingPigment: _asString(json['underlyingPigment']),
      recommendedShadeType: _asString(json['recommendedShadeType']),
      recommendedTone: _asString(json['recommendedTone']),
      recommendedToneFamilies: _asStringList(json['recommendedToneFamilies']),
      recommendedToneProfile: FormulationToneProfile.fromJsonLike(
        json['recommendedToneProfile'],
      ),
      serviceType: _asString(json['serviceType']),
      liftLevels: _asInt(json['liftLevels']),
      neutralizer: _asString(json['neutralizer']),
      fillerRecommendation: _asString(json['fillerRecommendation']),
      confidence: _asDouble(json['confidence']),
      analysisSummary: _asString(json['analysisSummary']),
      cautions: _asStringList(json['cautions']),
    );
  }

  static FormulationAnalysisModel? fromJsonLike(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is FormulationAnalysisModel) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      return FormulationAnalysisModel.fromJson(value);
    }
    if (value is Map) {
      return FormulationAnalysisModel.fromJson(
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        return fromJsonLike(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String? get recommendedToneOrFirstFamily {
    if (recommendedToneProfile?.display?.trim().isNotEmpty == true) {
      return recommendedToneProfile!.display;
    }
    if (recommendedTone != null && recommendedTone!.trim().isNotEmpty) {
      return recommendedTone;
    }
    if (recommendedToneFamilies.isNotEmpty) {
      return recommendedToneFamilies.first;
    }
    return null;
  }

  String? get confidenceLabel {
    if (confidence == null) return null;
    return '${(confidence! * 100).round()}% confidence';
  }

  Map<String, dynamic> toJson() {
    return {
      'estimatedBaseLevel': estimatedBaseLevel,
      'estimatedBaseLabel': estimatedBaseLabel,
      'estimatedGreyPercentage': estimatedGreyPercentage,
      'estimatedUndertone': estimatedUndertone,
      'underlyingPigment': underlyingPigment,
      'recommendedShadeType': recommendedShadeType,
      'recommendedTone': recommendedTone,
      'recommendedToneFamilies': recommendedToneFamilies,
      'recommendedToneProfile': recommendedToneProfile?.toJson(),
      'serviceType': serviceType,
      'liftLevels': liftLevels,
      'neutralizer': neutralizer,
      'fillerRecommendation': fillerRecommendation,
      'confidence': confidence,
      'analysisSummary': analysisSummary,
      'cautions': cautions,
    };
  }

  List<String> get guidanceChips {
    final chips = <String>[];
    final seen = <String>{};

    void addChip(String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }
      final key = normalized.toLowerCase();
      if (seen.contains(key)) {
        return;
      }
      seen.add(key);
      chips.add(normalized);
    }

    if (recommendedShadeType != null &&
        recommendedShadeType!.trim().isNotEmpty) {
      addChip('${_titleCase(recommendedShadeType!)} series');
    }
    if (recommendedToneProfile != null) {
      addChip('${recommendedToneProfile!.familyLabel} family');
      for (final tone in recommendedToneProfile!.toneLabels) {
        addChip(_titleCase(tone));
      }
    } else if (recommendedTone != null && recommendedTone!.trim().isNotEmpty) {
      addChip(_titleCase(recommendedTone!));
    }
    for (final tone in recommendedToneFamilies) {
      final normalized = tone.trim().toLowerCase();
      if (normalized == 'natural' ||
          normalized == 'warm' ||
          normalized == 'cool') {
        addChip('${_titleCase(tone)} family');
      } else {
        addChip(_titleCase(tone));
      }
    }

    return chips;
  }

  static int? _asInt(dynamic value) {
    if (value == null || value == '') return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }

  static double? _asDouble(dynamic value) {
    if (value == null || value == '') return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => _asString(item)).whereType<String>().toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        return _asStringList(decoded);
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }

  static String _titleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed
        .split(RegExp(r'[\s_-]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.length > 1 ? part.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }
}

class FormulationToneProfile {
  final String family;
  final List<String> tones;
  final List<String> toneCodes;
  final List<String> toneLabels;
  final String? display;
  final String? familyLabel;

  const FormulationToneProfile({
    required this.family,
    this.tones = const [],
    this.toneCodes = const [],
    this.toneLabels = const [],
    this.display,
    this.familyLabel,
  });

  factory FormulationToneProfile.fromJson(Map<String, dynamic> json) {
    return FormulationToneProfile(
      family:
          (json['family']?.toString().trim().isNotEmpty ?? false)
              ? json['family'].toString().trim()
              : 'natural',
      tones: FormulationAnalysisModel._asStringList(json['tones']),
      toneCodes: FormulationAnalysisModel._asStringList(json['toneCodes']),
      toneLabels: FormulationAnalysisModel._asStringList(json['toneLabels']),
      display: FormulationAnalysisModel._asString(json['display']),
      familyLabel: FormulationAnalysisModel._asString(json['familyLabel']),
    );
  }

  static FormulationToneProfile? fromJsonLike(dynamic value) {
    if (value == null) return null;
    if (value is FormulationToneProfile) return value;
    if (value is Map<String, dynamic>) {
      return FormulationToneProfile.fromJson(value);
    }
    if (value is Map) {
      return FormulationToneProfile.fromJson(
        value.map((key, item) => MapEntry(key.toString(), item)),
      );
    }
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        return fromJsonLike(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'family': family,
      'tones': tones,
      'toneCodes': toneCodes,
      'toneLabels': toneLabels,
      'display': display,
      'familyLabel': familyLabel,
    };
  }

  String get effectiveDisplay {
    final familyText =
        familyLabel ?? FormulationAnalysisModel._titleCase(family);
    if (toneLabels.isEmpty) {
      return display?.trim().isNotEmpty == true ? display! : familyText;
    }
    return '$familyText: ${toneLabels.join(', ')}';
  }
}
