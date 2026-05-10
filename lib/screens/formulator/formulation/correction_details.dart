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
  String? previousToneFamily;
  String? targetToneFamily;
  List<String> previousToneIds = <String>[];
  List<String> targetToneIds = <String>[];
  FormulationAnalysisModel? suggestion;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      wizardData = Map<String, dynamic>.from(Get.arguments as Map);
      suggestion = FormulationAnalysisModel.fromJsonLike(
        wizardData['suggestion'],
      );
      final previousProfile = FormulationToneProfile.fromJsonLike(
        wizardData['previousToneProfile'],
      );
      final targetProfile = FormulationToneProfile.fromJsonLike(
        wizardData['targetToneProfile'] ?? suggestion?.recommendedToneProfile,
      );
      previousToneFamily = previousProfile?.family;
      targetToneFamily =
          targetProfile?.family ?? suggestion?.recommendedToneProfile?.family;
      previousToneIds = List<String>.from(previousProfile?.tones ?? const []);
      targetToneIds = List<String>.from(targetProfile?.tones ?? const []);
    }
    controller.loadFormulationConfig();
  }

  List<int> get _levels =>
      controller.baseLevelOptions
              .map((item) => int.tryParse(item['level']?.toString() ?? ''))
              .whereType<int>()
              .toList()
              .isNotEmpty
          ? controller.baseLevelOptions
              .map((item) => int.tryParse(item['level']?.toString() ?? ''))
              .whereType<int>()
              .toList()
          : const <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  List<Map<String, dynamic>> get _toneFamilies => controller.toneFamilyOptions;

  List<Map<String, dynamic>> _tonesFor(int? level, String? family) =>
      controller.toneOptionsForLevel(level ?? 1, family: family);

  bool get _canPreview =>
      previousColorLevel != null &&
      targetLevel != null &&
      (previousToneFamily?.trim().isNotEmpty ?? false) &&
      (targetToneFamily?.trim().isNotEmpty ?? false) &&
      previousToneIds.isNotEmpty &&
      targetToneIds.isNotEmpty;

  void _toggleTone({
    required List<String> current,
    required String toneId,
    required ValueChanged<List<String>> onChanged,
  }) {
    final next = List<String>.from(current);
    if (next.contains(toneId)) {
      next.remove(toneId);
    } else if (next.length < 3) {
      next.add(toneId);
    }
    onChanged(next);
  }

  void _onPreview() {
    if (!_canPreview) {
      return;
    }

    final previousProfile = controller.buildToneProfile(
      family: previousToneFamily!,
      toneIds: previousToneIds,
      level: previousColorLevel,
    );
    final targetProfile = controller.buildToneProfile(
      family: targetToneFamily!,
      toneIds: targetToneIds,
      level: targetLevel,
    );

    wizardData['formulationType'] = 'color_correction';
    wizardData['previousColorLevel'] = previousColorLevel;
    wizardData['previousColorTone'] = controller.composeLegacyTone(
      previousProfile,
    );
    wizardData['previousToneProfile'] = previousProfile.toJson();
    wizardData['targetLevel'] = targetLevel;
    wizardData['targetTone'] = controller.composeLegacyTone(targetProfile);
    wizardData['targetToneProfile'] = targetProfile.toJson();
    wizardData['toneProfile'] = targetProfile.toJson();
    wizardData.remove('desiredLevel');
    wizardData.remove('desiredTone');
    wizardData.remove('desiredToneProfile');
    wizardData.remove('greyPercentage');
    wizardData.remove('shadeType');

    controller.getCorrectionPreview(wizardData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: const BackButton()),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          Dimensions.width20,
          0,
          Dimensions.width20,
          Dimensions.height30,
        ),
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
              title: 'Recommendations',
            ),
            SizedBox(height: Dimensions.height15),
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
            _ToneSelectionCard(
              title: 'Current tone family',
              familyOptions: _toneFamilies,
              selectedFamily: previousToneFamily,
              onFamilyChanged: (value) {
                setState(() {
                  previousToneFamily = value;
                  previousToneIds =
                      previousToneIds
                          .where(
                            (toneId) => _tonesFor(
                              previousColorLevel,
                              previousToneFamily,
                            ).any((tone) => tone['id']?.toString() == toneId),
                          )
                          .toList();
                });
              },
              tones: _tonesFor(previousColorLevel, previousToneFamily),
              selectedToneIds: previousToneIds,
              onToggleTone: (toneId) {
                setState(() {
                  _toggleTone(
                    current: previousToneIds,
                    toneId: toneId,
                    onChanged: (value) => previousToneIds = value,
                  );
                });
              },
            ),
            SizedBox(height: Dimensions.height20),
            _SelectorTile(
              label: 'Target correction level',
              value:
                  targetLevel == null ? 'Select level' : 'Level $targetLevel',
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
            _ToneSelectionCard(
              title: 'Target tone family',
              familyOptions: _toneFamilies,
              selectedFamily: targetToneFamily,
              onFamilyChanged: (value) {
                setState(() {
                  targetToneFamily = value;
                  targetToneIds =
                      targetToneIds
                          .where(
                            (toneId) => _tonesFor(
                              targetLevel,
                              targetToneFamily,
                            ).any((tone) => tone['id']?.toString() == toneId),
                          )
                          .toList();
                });
              },
              tones: _tonesFor(targetLevel, targetToneFamily),
              selectedToneIds: targetToneIds,
              onToggleTone: (toneId) {
                setState(() {
                  _toggleTone(
                    current: targetToneIds,
                    toneId: toneId,
                    onChanged: (value) => targetToneIds = value,
                  );
                });
              },
            ),
            SizedBox(height: Dimensions.height30),
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
                      isDisabled: controller.isLoading.value || !_canPreview,
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
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey4,
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.grey4),
          ],
        ),
      ),
    );
  }
}

class _ToneSelectionCard extends StatelessWidget {
  const _ToneSelectionCard({
    required this.title,
    required this.familyOptions,
    required this.selectedFamily,
    required this.onFamilyChanged,
    required this.tones,
    required this.selectedToneIds,
    required this.onToggleTone,
  });

  final String title;
  final List<Map<String, dynamic>> familyOptions;
  final String? selectedFamily;
  final ValueChanged<String> onFamilyChanged;
  final List<Map<String, dynamic>> tones;
  final List<String> selectedToneIds;
  final ValueChanged<String> onToggleTone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: Dimensions.font13,
            fontWeight: FontWeight.w600,
            color: AppColors.grey5,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        Wrap(
          spacing: Dimensions.width15,
          runSpacing: Dimensions.height12,
          children:
              familyOptions.map((family) {
                final familyId = family['id']?.toString() ?? 'natural';
                final label = family['label']?.toString() ?? familyId;
                final isSelected = selectedFamily == familyId;
                return InkWell(
                  onTap: () => onFamilyChanged(familyId),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary5.withValues(alpha: 0.08)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary5 : AppColors.grey3,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: Dimensions.font13,
                        color:
                            isSelected ? AppColors.primary5 : AppColors.grey5,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        SizedBox(height: Dimensions.height12),
        Wrap(
          spacing: Dimensions.width15,
          runSpacing: Dimensions.height15,
          children:
              tones.map((tone) {
                final toneId = tone['id']?.toString() ?? '';
                final label = tone['label']?.toString() ?? toneId;
                final selectionIndex = selectedToneIds.indexOf(toneId);
                final isSelected = selectionIndex >= 0;
                return InkWell(
                  onTap: () => onToggleTone(toneId),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width15,
                      vertical: Dimensions.height10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary5.withValues(alpha: 0.08)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary5 : AppColors.grey3,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          Container(
                            width: 18,
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.primary5,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${selectionIndex + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Dimensions.font12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: Dimensions.width8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: Dimensions.font13,
                            color:
                                isSelected
                                    ? AppColors.primary5
                                    : AppColors.grey5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
