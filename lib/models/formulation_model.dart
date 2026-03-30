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
  });

  factory FormulationModel.fromJson(Map<String, dynamic> json) {
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
      desiredTone: json['desiredTone'],
      previousColorTone: json['previousColorTone'],
      targetTone: json['targetTone'],
      mixingRatio: json['mixingRatio'],
      noteToStylist: json['noteToStylist'],
      longDescription: json['longDescription'],

      steps: _listFromJsonLike(json['steps']),
      media: _listFromJsonLike(json['media']),
      inputData: _mapFromJsonLike(json['inputData']),
      resultData: _mapFromJsonLike(json['resultData']),
      logicVersion: json['logicVersion'],
      createdAt: json['createdAt'],
    );
  }

  bool get isPredictionActive =>
      predictionImageStatus == 'queued' ||
      predictionImageStatus == 'in_progress';

  bool get hasPredictionImage =>
      predictionImageUrl != null && predictionImageUrl!.trim().isNotEmpty;

  bool get isCorrection => formulationType == 'color_correction';

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
      confidence: _asDouble(json['confidence']),
      analysisSummary: _asString(json['analysisSummary']),
      cautions: _asStringList(json['cautions']),
    );
  }

  static FormulationAnalysisModel? fromJsonLike(dynamic value) {
    if (value == null) return null;
    if (value is FormulationAnalysisModel) return value;
    if (value is Map<String, dynamic>)
      return FormulationAnalysisModel.fromJson(value);
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
      'confidence': confidence,
      'analysisSummary': analysisSummary,
      'cautions': cautions,
    };
  }

  List<String> get guidanceChips {
    final chips = <String>[];

    if (recommendedShadeType != null &&
        recommendedShadeType!.trim().isNotEmpty) {
      chips.add(_titleCase(recommendedShadeType!));
    }
    if (recommendedTone != null && recommendedTone!.trim().isNotEmpty) {
      chips.add(_titleCase(recommendedTone!));
    }
    for (final tone in recommendedToneFamilies) {
      final normalized = _titleCase(tone);
      if (!chips.contains(normalized)) {
        chips.add(normalized);
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
