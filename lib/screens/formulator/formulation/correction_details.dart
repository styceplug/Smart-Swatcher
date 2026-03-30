import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/formulation_analysis_card.dart';

class CorrectionDetailsScreen extends StatefulWidget {
  const CorrectionDetailsScreen({super.key});

  @override
  State<CorrectionDetailsScreen> createState() =>
      _CorrectionDetailsScreenState();
}

class _CorrectionDetailsScreenState extends State<CorrectionDetailsScreen> {
  final ClientFolderController controller = Get.find<ClientFolderController>();

  Map<String, dynamic> wizardData = {};
  int? previousColorLevel;
  int? targetLevel;
  String? previousColorTone;
  String? targetTone;
  FormulationAnalysisModel? suggestion;

  static const List<int> _levels = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  static const List<String> _tones = <String>[
    'Natural',
    'Neutral',
    'Warm',
    'Cool',
    'Gold',
    'Ash',
    'Copper',
    'Beige',
    'Pearl',
    'Violet',
    'Red',
  ];

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      wizardData = Map<String, dynamic>.from(Get.arguments as Map);
      suggestion = FormulationAnalysisModel.fromJsonLike(
        wizardData['suggestion'],
      );
    }
  }

  void _onPreview() {
    if (previousColorLevel == null ||
        targetLevel == null ||
        previousColorTone == null ||
        targetTone == null) {
      return;
    }

    wizardData['formulationType'] = 'color_correction';
    wizardData['previousColorLevel'] = previousColorLevel;
    wizardData['previousColorTone'] = previousColorTone;
    wizardData['targetLevel'] = targetLevel;
    wizardData['targetTone'] = targetTone;
    wizardData.remove('desiredLevel');
    wizardData.remove('desiredTone');
    wizardData.remove('greyPercentage');
    wizardData.remove('shadeType');

    controller.getCorrectionPreview(wizardData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: const BackButton()),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Dimensions.screenWidth,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Plan Color Correction',
              style: TextStyle(
                fontSize: Dimensions.font20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Select the current artificial color history and the target correction result.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height15),
            FormulationAnalysisCard(
              analysis: suggestion,
              title: 'AI Upload Reading',
            ),
            SizedBox(height: Dimensions.height20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SelectorTile(
                      label: 'Current color level',
                      value:
                          previousColorLevel == null
                              ? 'Select level'
                              : 'Level $previousColorLevel',
                      onTap:
                          () => _showLevelSheet(
                            title: 'Current color level',
                            selectedLevel: previousColorLevel,
                            onSelected: (value) {
                              setState(() => previousColorLevel = value);
                            },
                          ),
                    ),
                    SizedBox(height: Dimensions.height15),
                    Text(
                      'Current color tone',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey5,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    _ToneWrap(
                      tones: _tones,
                      selectedTone: previousColorTone,
                      onSelected: (tone) {
                        setState(() => previousColorTone = tone);
                      },
                    ),
                    SizedBox(height: Dimensions.height20),
                    _SelectorTile(
                      label: 'Target correction level',
                      value:
                          targetLevel == null
                              ? 'Select level'
                              : 'Level $targetLevel',
                      onTap:
                          () => _showLevelSheet(
                            title: 'Target correction level',
                            selectedLevel: targetLevel,
                            onSelected: (value) {
                              setState(() => targetLevel = value);
                            },
                          ),
                    ),
                    SizedBox(height: Dimensions.height15),
                    Text(
                      'Target tone',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey5,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),
                    _ToneWrap(
                      tones: _mergedTargetTones(),
                      selectedTone: targetTone,
                      onSelected: (tone) {
                        setState(() => targetTone = tone);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Prev',
                    onPressed: () => Get.back(),
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: Obx(
                    () => CustomButton(
                      text:
                          controller.isLoading.value
                              ? 'Generating...'
                              : 'Preview',
                      isDisabled:
                          controller.isLoading.value ||
                          previousColorLevel == null ||
                          previousColorTone == null ||
                          targetLevel == null ||
                          targetTone == null,
                      onPressed: _onPreview,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height30),
          ],
        ),
      ),
    );
  }

  List<String> _mergedTargetTones() {
    final tones = <String>[...?suggestion?.recommendedToneFamilies, ..._tones];

    final unique = <String>[];
    for (final tone in tones) {
      final trimmed = tone.trim();
      if (trimmed.isEmpty) continue;
      final normalized = _normalizeTone(trimmed);
      if (!unique.any((item) => _normalizeTone(item) == normalized)) {
        unique.add(_displayTone(trimmed));
      }
    }
    return unique;
  }

  void _showLevelSheet({
    required String title,
    required int? selectedLevel,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius15),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _levels.length,
                    separatorBuilder:
                        (_, __) => SizedBox(height: Dimensions.height10),
                    itemBuilder: (context, index) {
                      final level = _levels[index];
                      final isSelected = selectedLevel == level;
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius12,
                          ),
                        ),
                        tileColor:
                            isSelected ? AppColors.primary1 : Colors.white,
                        title: Text(
                          'Level $level',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color:
                              isSelected ? AppColors.primary5 : AppColors.grey4,
                        ),
                        onTap: () {
                          onSelected(level);
                          Get.back();
                        },
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

  String _normalizeTone(String value) => value.trim().toLowerCase();

  String _displayTone(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return normalized;
    return normalized[0].toUpperCase() +
        (normalized.length > 1 ? normalized.substring(1).toLowerCase() : '');
  }
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Dimensions.font13,
            fontWeight: FontWeight.w600,
            color: AppColors.grey5,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width15,
              vertical: Dimensions.height15,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(color: AppColors.grey3),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font14,
                      color: AppColors.black1,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down_outlined,
                  color: AppColors.grey4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ToneWrap extends StatelessWidget {
  const _ToneWrap({
    required this.tones,
    required this.selectedTone,
    required this.onSelected,
  });

  final List<String> tones;
  final String? selectedTone;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Dimensions.width10,
      runSpacing: Dimensions.height10,
      children:
          tones
              .map(
                (tone) => ChoiceChip(
                  label: Text(tone),
                  selected:
                      selectedTone?.trim().toLowerCase() ==
                      tone.trim().toLowerCase(),
                  onSelected: (_) => onSelected(tone),
                  selectedColor: AppColors.primary1,
                  side: BorderSide(
                    color:
                        selectedTone?.trim().toLowerCase() ==
                                tone.trim().toLowerCase()
                            ? AppColors.primary5
                            : AppColors.grey3,
                  ),
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color:
                        selectedTone?.trim().toLowerCase() ==
                                tone.trim().toLowerCase()
                            ? AppColors.primary5
                            : AppColors.grey5,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                ),
              )
              .toList(),
    );
  }
}
