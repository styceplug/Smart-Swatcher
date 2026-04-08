import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/app_cached_network_image.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/formulation_analysis_card.dart';

import '../../../widgets/snackbars.dart';

class FormulationPreview extends StatefulWidget {
  const FormulationPreview({super.key});

  @override
  State<FormulationPreview> createState() => _FormulationPreviewState();
}

class _FormulationPreviewState extends State<FormulationPreview> {
  final ClientFolderController controller = Get.find<ClientFolderController>();

  Map<String, dynamic> inputs = {};
  Map<String, dynamic> outputs = {};
  String description = '';
  String formulationType = 'color_formulation';
  String? formulationId;
  Timer? _predictionRefreshTimer;
  bool _isRetryingPrediction = false;

  bool get isCorrection => formulationType == 'color_correction';
  bool get isSavedFormulation =>
      formulationId != null && formulationId!.trim().isNotEmpty;
  bool get isPredictionActive =>
      predictionStatus == 'queued' || predictionStatus == 'in_progress';
  bool get canRetryPrediction =>
      isSavedFormulation &&
      (predictionStatus == 'failed' || predictionStatus == 'not_requested') &&
      !_isRetryingPrediction;

  String get predictionStatus =>
      outputs['predictionImageStatus']?.toString() ?? 'not_requested';

  FormulationAnalysisModel? get previewAnalysis =>
      FormulationAnalysisModel.fromJsonLike(outputs['analysis']);

  @override
  void initState() {
    super.initState();
    _hydrateFromArguments();
    if (isSavedFormulation && isPredictionActive) {
      _startPredictionRefresh();
    }
  }

  @override
  void dispose() {
    _predictionRefreshTimer?.cancel();
    super.dispose();
  }

  void _hydrateFromArguments() {
    if (Get.arguments is! Map) {
      return;
    }

    final bundle = Map<String, dynamic>.from(Get.arguments as Map);
    inputs = Map<String, dynamic>.from((bundle['inputs'] as Map?) ?? {});
    outputs = Map<String, dynamic>.from((bundle['outputs'] as Map?) ?? {});
    description =
        inputs['longDescription']?.toString() ??
        bundle['longDescription']?.toString() ??
        '';
    formulationType =
        bundle['formulationType']?.toString() ??
        inputs['formulationType']?.toString() ??
        'color_formulation';
    formulationId =
        bundle['formulationId']?.toString() ??
        inputs['formulationId']?.toString();
  }

  Future<void> _refreshSavedFormulation({
    bool refreshPrediction = false,
  }) async {
    if (!isSavedFormulation) {
      return;
    }

    final formulation = await controller.fetchFormulationById(
      formulationId!,
      refreshPrediction: refreshPrediction,
    );

    if (formulation == null || !mounted) {
      if (!refreshPrediction) {
        _predictionRefreshTimer?.cancel();
      }
      return;
    }

    setState(() {
      _applyFormulation(formulation);
    });

    if (formulation.isPredictionActive) {
      _startPredictionRefresh();
    } else {
      _predictionRefreshTimer?.cancel();
    }
  }

  void _applyFormulation(FormulationModel formulation) {
    final analysisMap = formulation.analysis?.toJson();

    formulationId = formulation.id;
    formulationType = formulation.formulationType;
    description = formulation.longDescription ?? description;
    inputs = {
      ...?formulation.inputData,
      'formulationId': formulation.id,
      'folderId': formulation.folderId,
      'formulationType': formulation.formulationType,
      'imageUrl': formulation.imageUrl ?? formulation.inputData?['imageUrl'],
      'naturalBaseLevel':
          formulation.inputData?['naturalBaseLevel'] ??
          formulation.naturalBaseLevel,
      'greyPercentage':
          formulation.inputData?['greyPercentage'] ??
          formulation.greyPercentage,
      'shadeType': formulation.inputData?['shadeType'] ?? formulation.shadeType,
      'desiredLevel':
          formulation.inputData?['desiredLevel'] ?? formulation.desiredLevel,
      'desiredTone':
          formulation.inputData?['desiredTone'] ?? formulation.desiredTone,
      'previousColorLevel':
          formulation.inputData?['previousColorLevel'] ??
          formulation.previousColorLevel,
      'previousColorTone':
          formulation.inputData?['previousColorTone'] ??
          formulation.previousColorTone,
      'targetLevel':
          formulation.inputData?['targetLevel'] ?? formulation.targetLevel,
      'targetTone':
          formulation.inputData?['targetTone'] ?? formulation.targetTone,
      'longDescription':
          formulation.longDescription ??
          formulation.inputData?['longDescription'],
    };

    outputs = {
      ...?formulation.resultData,
      'steps': formulation.resultData?['steps'] ?? formulation.steps,
      'media': formulation.resultData?['media'] ?? formulation.media,
      'analysis': formulation.resultData?['analysis'] ?? analysisMap,
      'predictionImageUrl':
          formulation.predictionImageUrl ??
          formulation.resultData?['predictionImageUrl'],
      'predictionImageStatus': formulation.predictionImageStatus,
      'predictionImageError': formulation.predictionImageError,
      'developerVolume':
          formulation.resultData?['developerVolume'] ??
          formulation.developerVolume,
      'mixingRatio':
          formulation.resultData?['mixingRatio'] ?? formulation.mixingRatio,
      'noteToStylist':
          formulation.resultData?['noteToStylist'] ?? formulation.noteToStylist,
    };
  }

  void _startPredictionRefresh() {
    if (!isSavedFormulation) {
      return;
    }

    _predictionRefreshTimer?.cancel();
    _predictionRefreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _refreshSavedFormulation(refreshPrediction: true);
    });
  }

  Future<void> _retryPrediction() async {
    if (!canRetryPrediction) {
      return;
    }

    setState(() {
      _isRetryingPrediction = true;
    });

    final formulation = await controller.retryPredictionImage(
      formulationId!,
      notifyOnFailure: true,
    );

    if (mounted) {
      setState(() {
        _isRetryingPrediction = false;
        if (formulation != null) {
          _applyFormulation(formulation);
        }
      });
    }

    if (formulation?.isPredictionActive == true) {
      _startPredictionRefresh();
    }
  }

  void _onSave() {
    if (isSavedFormulation) {
      return;
    }

    String? folderId = inputs['folderId']?.toString();

    if ((folderId == null || folderId.isEmpty) &&
        Get.isRegistered<ClientFolderController>()) {
      folderId = Get.find<ClientFolderController>().currentFolder.value?.id;
    }

    if (folderId == null || folderId.isEmpty) {
      CustomSnackBar.failure(message: 'Folder ID is missing. Cannot save.');
      return;
    }

    final savePayload = {
      'folderId': folderId,
      'status': 'draft',
      'generatePredictionImage': true,
      'imageUrl': inputs['imageUrl'] ?? '',
      'predictionImageUrl': null,
      'finalImageUrl': '',
      'naturalBaseLevel': inputs['naturalBaseLevel'],
      'greyPercentage': inputs['greyPercentage'],
      'shadeType': inputs['shadeType'],
      'desiredLevel': inputs['desiredLevel'],
      'desiredTone': inputs['desiredTone'],
      'previousColorLevel': inputs['previousColorLevel'],
      'previousColorTone': inputs['previousColorTone'],
      'targetLevel': inputs['targetLevel'],
      'targetTone': inputs['targetTone'],
      'developerVolume': outputs['developerVolume'] ?? 0,
      'mixingRatio': outputs['mixingRatio'] ?? '1:1',
      'noteToStylist': outputs['noteToStylist'] ?? '',
      'longDescription': description,
      'steps': outputs['steps'] ?? [],
      'media': outputs['media'] ?? [],
      'inputData': {
        ...inputs,
        'folderId': folderId,
        'formulationType': formulationType,
        'longDescription': description,
      },
      'resultData': outputs,
      'logicVersion': 'vertex-ai-v1',
    };

    if (isCorrection) {
      controller.saveCorrection(savePayload);
    } else {
      controller.saveFormulation(savePayload);
    }
  }

  String _fullUrl(String? path) => MediaUrlHelper.resolve(path) ?? '';

  String _neutralStatusCopy() {
    if (!isSavedFormulation) {
      return 'This preview shows the recommended plan. AI preview image generation starts after you tap Save & Generate.';
    }
    if (isPredictionActive) {
      return 'AI preview image generation is in progress. This screen refreshes automatically while the image is being prepared.';
    }
    if (predictionStatus == 'failed') {
      return 'AI preview image generation did not complete. You can retry the preview image from this screen.';
    }
    if (predictionStatus == 'completed') {
      return 'AI preview image generation completed successfully.';
    }
    return 'AI preview image generation has not started for this saved item yet.';
  }

  String _summaryText() {
    if (isCorrection) {
      final previousLevel = inputs['previousColorLevel'] ?? '?';
      final previousTone = inputs['previousColorTone'] ?? 'Current tone';
      final targetLevel = inputs['targetLevel'] ?? '?';
      final targetTone = inputs['targetTone'] ?? 'Target tone';
      final baseLevel = inputs['naturalBaseLevel'] ?? '?';
      return 'Base $baseLevel • Current Lvl $previousLevel $previousTone → Target Lvl $targetLevel $targetTone';
    }

    final nbl = inputs['naturalBaseLevel'] ?? 0;
    final dl = inputs['desiredLevel'] ?? 0;
    final lift = (dl is num && nbl is num && dl > nbl) ? dl - nbl : 0;
    final grey = inputs['greyPercentage'] ?? 0;
    return 'NBL $nbl - G%$grey - DL $dl = $lift Lvl Lift';
  }

  List<dynamic> _steps() {
    final steps = outputs['steps'];
    return steps is List ? steps : const [];
  }

  @override
  Widget build(BuildContext context) {
    final originalImg = _fullUrl(inputs['imageUrl']?.toString());
    final predictionImg = _fullUrl(outputs['predictionImageUrl']?.toString());
    final predictionError = outputs['predictionImageError']?.toString();
    final steps = _steps();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        actionIcon: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: showShareModal,
              child: const Icon(CupertinoIcons.share),
            ),
            if (!isSavedFormulation) ...[
              SizedBox(width: Dimensions.width15),
              InkWell(
                onTap: _onSave,
                child: Text(
                  'Save & Generate',
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary5,
                  ),
                ),
              ),
            ] else if (canRetryPrediction) ...[
              SizedBox(width: Dimensions.width15),
              InkWell(
                onTap: _retryPrediction,
                child: Text(
                  _isRetryingPrediction ? 'Retrying...' : 'Retry Preview',
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary5,
                  ),
                ),
              ),
            ] else if (isPredictionActive) ...[
              SizedBox(width: Dimensions.width15),
              Text(
                'Refreshing...',
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  color: AppColors.grey4,
                ),
              ),
            ],
            SizedBox(width: Dimensions.width10),
          ],
        ),
      ),
      body: SizedBox(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (originalImg.isNotEmpty || predictionImg.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _PreviewImagePanel(
                          label:
                              isCorrection ? 'Current Hair' : 'Natural Level',
                          imageUrl: originalImg,
                          heroTag:
                              'formulation_original_${formulationId ?? originalImg}',
                        ),
                      ),
                      SizedBox(width: Dimensions.width13),
                      Expanded(
                        child: _PreviewImagePanel(
                          label:
                              isCorrection
                                  ? 'Corrected Result'
                                  : 'Desired Level',
                          imageUrl: predictionImg,
                          heroTag:
                              'formulation_prediction_${formulationId ?? predictionImg}',
                          emptyMessage:
                              predictionStatus == 'failed'
                                  ? 'Preview failed'
                                  : isPredictionActive
                                  ? 'Generating preview'
                                  : 'Preview not ready',
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: Dimensions.height20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isCorrection
                              ? CupertinoIcons.wand_stars
                              : CupertinoIcons.drop,
                          color: AppColors.accent1,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            _summaryText(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Dimensions.font16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Dimensions.width15),
                      decoration: BoxDecoration(
                        color: AppColors.primary1,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15,
                        ),
                      ),
                      child: Text(
                        _neutralStatusCopy(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font13,
                          color: AppColors.grey4,
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (predictionError != null &&
                        predictionError.trim().isNotEmpty) ...[
                      SizedBox(height: Dimensions.height10),
                      Text(
                        predictionError,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font12,
                          color: Colors.red,
                        ),
                      ),
                    ],
                    SizedBox(height: Dimensions.height15),
                    FormulationAnalysisCard(
                      analysis: previewAnalysis,
                      title: 'Preview Analysis',
                      initiallyExpanded: true,
                    ),
                    if (previewAnalysis != null)
                      SizedBox(height: Dimensions.height15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CupertinoIcons.lightbulb,
                          color: AppColors.accent1,
                          size: Dimensions.iconSize20,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            outputs['noteToStylist']
                                        ?.toString()
                                        .trim()
                                        .isNotEmpty ==
                                    true
                                ? outputs['noteToStylist'].toString()
                                : 'Follow the recommended steps carefully and adjust timing based on the client’s porosity and hair history.',
                            style: TextStyle(
                              height: 1.5,
                              fontSize: Dimensions.font14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (steps.isNotEmpty) ...[
                      SizedBox(height: Dimensions.height20),
                      Text(
                        'Recommended Steps',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: Dimensions.height10),
                      ...steps.map((step) => _PreviewStepCard(step: step)),
                    ],
                    SizedBox(height: Dimensions.height20),
                    if (!isSavedFormulation && description.isEmpty)
                      IntrinsicWidth(
                        child: CustomButton(
                          text: 'Add description',
                          onPressed: () async {
                            final result = await Get.toNamed(
                              AppRoutes.addDescription,
                            );
                            if (result != null && result is String) {
                              setState(() {
                                description = result;
                              });
                            }
                          },
                          icon: Icon(
                            CupertinoIcons.pencil,
                            color: AppColors.primary5,
                            size: 16,
                          ),
                          backgroundColor: AppColors.bgColor,
                          borderColor: AppColors.primary5,
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height10,
                          ),
                        ),
                      )
                    else if (description.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: Dimensions.height10),
                          Text(
                            description,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font13,
                              color: AppColors.grey5,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: Dimensions.height10),
                          if (!isSavedFormulation)
                            InkWell(
                              onTap: () async {
                                final result = await Get.toNamed(
                                  AppRoutes.addDescription,
                                  arguments: description,
                                );
                                if (result != null && result is String) {
                                  setState(() {
                                    description = result;
                                  });
                                }
                              },
                              child: Text(
                                'Edit description',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: AppColors.primary5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    SizedBox(height: Dimensions.height40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showShareModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius15),
        ),
      ),
      builder: (context) {
        final icons = <IconData>[
          Icons.add,
          CupertinoIcons.share,
          CupertinoIcons.link,
        ];
        final labels = <String>['Post', 'Share', 'Copy Link'];

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrection ? 'Color Correction' : 'Formulator',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: icons.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height15,
                          ),
                          child: Row(
                            children: [
                              Icon(icons[index]),
                              SizedBox(width: Dimensions.width10),
                              Text(
                                labels[index],
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PreviewImagePanel extends StatelessWidget {
  const _PreviewImagePanel({
    required this.label,
    required this.imageUrl,
    required this.heroTag,
    this.emptyMessage,
  });

  final String label;
  final String imageUrl;
  final String heroTag;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      height: Dimensions.height100 * 2.35,
      decoration: BoxDecoration(
        color: hasImage ? AppColors.grey2 : AppColors.bgColor,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child:
                hasImage
                    ? AppCachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      enableFullscreen: true,
                      heroTag: heroTag,
                    )
                    : Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width15,
                      ),
                      child: Text(
                        emptyMessage ?? 'No image available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font12,
                          color: AppColors.grey4,
                        ),
                      ),
                    ),
          ),
          Positioned(
            top: Dimensions.height10,
            left: Dimensions.width10,
            child: Chip(label: Text(label)),
          ),
        ],
      ),
    );
  }
}

class _PreviewStepCard extends StatelessWidget {
  const _PreviewStepCard({required this.step});

  final dynamic step;

  @override
  Widget build(BuildContext context) {
    final stepMap =
        step is Map<String, dynamic>
            ? step
            : step is Map
            ? step.map((key, value) => MapEntry(key.toString(), value))
            : <String, dynamic>{};

    final order = stepMap['stepOrder'] ?? stepMap['step_order'] ?? 1;
    final title = stepMap['title']?.toString() ?? 'Step';
    final description = stepMap['description']?.toString() ?? '';
    final stepType =
        stepMap['stepType']?.toString() ??
        stepMap['step_type']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: Dimensions.height12),
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: Dimensions.width24,
            height: Dimensions.width24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary5,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$order',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: Dimensions.width13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (stepType.trim().isNotEmpty) ...[
                  SizedBox(height: Dimensions.height5),
                  Text(
                    stepType.replaceAll('_', ' ').capitalizeFirst ?? stepType,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font12,
                      color: AppColors.primary5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (description.trim().isNotEmpty) ...[
                  SizedBox(height: Dimensions.height8),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font12,
                      color: AppColors.grey5,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
