import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:smart_swatcher/widgets/formulation_analysis_card.dart';

class ChooseCdl extends StatefulWidget {
  const ChooseCdl({super.key});

  @override
  State<ChooseCdl> createState() => _ChooseCdlState();
}

class _ChooseCdlState extends State<ChooseCdl> {
  final ClientFolderController controller = Get.find<ClientFolderController>();

  Map<String, dynamic> wizardData = {};
  FormulationAnalysisModel? suggestion;

  int selectedLevel = 0;
  String? selectedToneFamily;
  List<String> selectedToneIds = <String>[];

  final Map<int, String> _baseAssets = const {
    1: 'black',
    2: 'dark-brown',
    3: 'medium-brown',
    4: 'light-brown',
    5: 'dark-blonde',
    6: 'blonde',
    7: 'light-blonde',
    8: 'very-light-blonde',
    9: 'plat-blonde',
    10: 'extra-light-blonde',
    11: 'lightest-blonde',
    12: 'extrem-light-blonde',
  };

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      wizardData = Map<String, dynamic>.from(Get.arguments as Map);
      suggestion = FormulationAnalysisModel.fromJsonLike(
        wizardData['suggestion'],
      );
      final toneProfile = FormulationToneProfile.fromJsonLike(
        wizardData['desiredToneProfile'] ??
            wizardData['toneProfile'] ??
            suggestion?.recommendedToneProfile,
      );
      selectedToneFamily =
          toneProfile?.family ?? suggestion?.recommendedToneProfile?.family;
      selectedToneIds = List<String>.from(
        toneProfile?.tones ?? const <String>[],
      );
    }
    controller.loadFormulationConfig();
  }

  List<Map<String, dynamic>> get _levelOptions {
    final configItems = controller.baseLevelOptions;
    if (configItems.isNotEmpty) {
      return configItems;
    }
    return List.generate(
      12,
      (index) => {
        'level': index + 1,
        'label': 'Level ${index + 1}',
        'undertone': '',
      },
    );
  }

  List<Map<String, dynamic>> get _toneFamilyOptions =>
      controller.toneFamilyOptions;

  List<Map<String, dynamic>> get _toneOptions => controller.toneOptionsForLevel(
    selectedLevel == 0 ? 1 : selectedLevel,
    family: selectedToneFamily,
  );

  bool get _canPreview =>
      selectedLevel > 0 &&
      (selectedToneFamily?.trim().isNotEmpty ?? false) &&
      selectedToneIds.isNotEmpty;

  void _toggleTone(String toneId) {
    setState(() {
      if (selectedToneIds.contains(toneId)) {
        selectedToneIds.remove(toneId);
        return;
      }
      if (selectedToneIds.length >= 3) {
        return;
      }
      selectedToneIds.add(toneId);
    });
  }

  void _onNext() {
    if (!_canPreview) return;

    final toneProfile = controller.buildToneProfile(
      family: selectedToneFamily!,
      toneIds: selectedToneIds,
      level: selectedLevel,
    );

    wizardData['desiredLevel'] = selectedLevel;
    wizardData['toneProfile'] = toneProfile.toJson();
    wizardData['desiredToneProfile'] = toneProfile.toJson();
    wizardData['desiredTone'] = controller.composeLegacyTone(toneProfile);
    wizardData['formulationType'] =
        wizardData['formulationType'] ?? 'color_formulation';

    controller.getPreview(wizardData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        actionIcon: Text(
          'Preview',
          style: TextStyle(
            fontSize: Dimensions.font15,
            color: AppColors.primary5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
              'Choose your client\'s Desired Level',
              style: TextStyle(
                fontSize: Dimensions.font20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Client\'s desired color outcome',
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
            if (suggestion != null) SizedBox(height: Dimensions.height15),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _levelOptions.length,
              itemBuilder: (context, index) {
                final option = _levelOptions[index];
                final level =
                    int.tryParse(option['level']?.toString() ?? '') ?? 0;
                return _cdlCard(
                  title: option['label']?.toString() ?? 'Level $level',
                  subtitle:
                      'Underlying pigment: ${option['underlyingPigment'] ?? option['undertone'] ?? 'Review visually'}',
                  imageAsset: _baseAssets[level] ?? 'blonde',
                  level: level,
                );
              },
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Choose Tone Family',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height12),
            Wrap(
              spacing: Dimensions.width15,
              runSpacing: Dimensions.height12,
              children:
                  _toneFamilyOptions.map((family) {
                    final familyId = family['id']?.toString() ?? 'natural';
                    final label = family['label']?.toString() ?? familyId;
                    final isSelected = selectedToneFamily == familyId;
                    return _ChoiceChipButton(
                      label: label,
                      selected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedToneFamily = familyId;
                          selectedToneIds =
                              selectedToneIds
                                  .where(
                                    (toneId) => _toneOptions.any(
                                      (tone) =>
                                          tone['id']?.toString() == toneId,
                                    ),
                                  )
                                  .toList();
                        });
                      },
                    );
                  }).toList(),
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Choose up to 3 ordered tones',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height8),
            Text(
              'Tap tones in the order you want them read, for example Red Copper vs Copper Red.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font12,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height12),
            Wrap(
              spacing: Dimensions.width15,
              runSpacing: Dimensions.height15,
              children:
                  _toneOptions.map((tone) {
                    final toneId = tone['id']?.toString() ?? '';
                    final label = tone['label']?.toString() ?? toneId;
                    final selectionIndex = selectedToneIds.indexOf(toneId);
                    final isSelected = selectionIndex >= 0;
                    return InkWell(
                      onTap: () => _toggleTone(toneId),
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
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
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius20,
                          ),
                          border: Border.all(
                            color:
                                isSelected
                                    ? AppColors.primary5
                                    : AppColors.grey3,
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
            if (selectedToneIds.isNotEmpty) ...[
              SizedBox(height: Dimensions.height15),
              Text(
                'Selected order: ${selectedToneIds.asMap().entries.map((entry) {
                  final tone = _toneOptions.firstWhere((item) => item['id']?.toString() == entry.value, orElse: () => {'label': entry.value});
                  return '${entry.key + 1}. ${tone['label']}';
                }).join('  •  ')}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: Dimensions.font12,
                  color: AppColors.grey4,
                ),
              ),
            ],
            SizedBox(height: Dimensions.height20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  child: CustomButton(
                    text: 'Next',
                    isDisabled: !_canPreview,
                    onPressed: _onNext,
                    backgroundColor: AppColors.primary4,
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

  Widget _cdlCard({
    required String title,
    required String subtitle,
    required String imageAsset,
    required int level,
  }) {
    final isSelected = selectedLevel == level;
    return InkWell(
      onTap: () {
        setState(() {
          selectedLevel = level;
          selectedToneIds =
              selectedToneIds
                  .where(
                    (toneId) => controller
                        .toneOptionsForLevel(level, family: selectedToneFamily)
                        .any((tone) => tone['id']?.toString() == toneId),
                  )
                  .toList();
        });
      },
      child: Container(
        height: Dimensions.height100,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          border: const Border(
            bottom: BorderSide(color: Colors.white, width: 2),
          ),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(AppConstants.getBaseAsset(imageAsset)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: Dimensions.font16,
                    ),
                  ),
                  SizedBox(height: Dimensions.height5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: Dimensions.font12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radius20),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height10,
        ),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.primary5.withValues(alpha: 0.08)
                  : Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          border: Border.all(
            color: selected ? AppColors.primary5 : AppColors.grey3,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.font13,
            color: selected ? AppColors.primary5 : AppColors.grey5,
          ),
        ),
      ),
    );
  }
}
