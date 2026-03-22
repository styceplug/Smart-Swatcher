class FormulationModel {
  String id;
  String folderId;
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

  String? shadeType;
  String? desiredTone;
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
    this.shadeType,
    this.desiredTone,
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

      shadeType: json['shadeType'],
      desiredTone: json['desiredTone'],
      mixingRatio: json['mixingRatio'],
      noteToStylist: json['noteToStylist'],
      longDescription: json['longDescription'],

      steps: json['steps'] ?? [],
      media: json['media'] ?? [],
      inputData: json['inputData'],
      resultData: json['resultData'],
      logicVersion: json['logicVersion'],
      createdAt: json['createdAt'],
    );
  }

  bool get isPredictionActive =>
      predictionImageStatus == 'queued' || predictionImageStatus == 'in_progress';

  bool get hasPredictionImage =>
      predictionImageUrl != null && predictionImageUrl!.trim().isNotEmpty;
}
