import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/models/formulation_model.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/formulation_analysis_card.dart';

class GreyExceeds extends StatefulWidget {
  const GreyExceeds({super.key});

  @override
  State<GreyExceeds> createState() => _GreyExceedsState();
}

class _GreyExceedsState extends State<GreyExceeds> {
  final ClientFolderController controller = Get.find<ClientFolderController>();

  Map<String, dynamic> wizardData = {};

  String? selectedShadeType;
  String? selectedToneFamily;
  List<String> selectedToneIds = <String>[];
  String? selectedMixingRatio;
  FormulationAnalysisModel? suggestion;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      wizardData = Map<String, dynamic>.from(Get.arguments as Map);
      suggestion = FormulationAnalysisModel.fromJsonLike(
        wizardData['suggestion'],
      );
      selectedShadeType = suggestion?.recommendedShadeType;
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

  int? get _selectedBaseLevel =>
      int.tryParse(wizardData['naturalBaseLevel']?.toString() ?? '');

  List<Map<String, dynamic>> get _toneFamilyOptions =>
      controller.toneFamilyOptions;

  List<Map<String, dynamic>> get _toneOptions => controller.toneOptionsForLevel(
    _selectedBaseLevel ?? 1,
    family: selectedToneFamily,
  );

  bool get _canContinue =>
      selectedShadeType != null &&
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
    final desiredLevel = int.tryParse(
      wizardData['desiredLevel']?.toString() ?? '',
    );
    final toneProfile = controller.buildToneProfile(
      family: selectedToneFamily!,
      toneIds: selectedToneIds,
      level: desiredLevel ?? _selectedBaseLevel,
    );

    wizardData['shadeType'] = selectedShadeType;
    wizardData['toneProfile'] = toneProfile.toJson();
    wizardData['desiredToneProfile'] = toneProfile.toJson();
    wizardData['desiredTone'] = controller.composeLegacyTone(toneProfile);

    Get.toNamed(AppRoutes.chooseCdl, arguments: wizardData);
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
              'Grey Hair Coverage Exceeds 10%',
              style: TextStyle(
                fontSize: Dimensions.font20,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Select the series and tonal blend that should still cover resistant grey cleanly.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            FormulationAnalysisCard(
              analysis: suggestion,
              title: 'Recommendations',
            ),
            if (suggestion != null) SizedBox(height: Dimensions.height15),
            Text(
              'Available Shades',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            _radioOption(
              label: 'Fashion Shade',
              value: 'fashion',
              groupValue: selectedShadeType,
              onChanged: (val) => setState(() => selectedShadeType = val),
            ),
            SizedBox(height: Dimensions.height20),
            _radioOption(
              label: 'Natural Shade',
              value: 'natural',
              groupValue: selectedShadeType,
              onChanged: (val) => setState(() => selectedShadeType = val),
            ),
            SizedBox(height: Dimensions.height30),
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
            SizedBox(height: Dimensions.height20),
            IntrinsicWidth(
              child: CustomButton(
                text: selectedMixingRatio ?? 'Mixing Ratios',
                icon: Icon(
                  Icons.calculate_outlined,
                  size: Dimensions.iconSize20,
                  color: AppColors.primary5,
                ),
                backgroundColor: Colors.white,
                borderColor: AppColors.primary5,
                onPressed: _showRatioModal,
              ),
            ),
            SizedBox(height: Dimensions.height40),
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
                    isDisabled: !_canContinue,
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

  Widget _radioOption({
    required String label,
    required String value,
    required String? groupValue,
    required ValueChanged<String> onChanged,
  }) {
    final selected = groupValue == value;
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary5 : AppColors.grey4,
          ),
          SizedBox(width: Dimensions.width10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              fontSize: Dimensions.font14,
              color: AppColors.grey5,
            ),
          ),
        ],
      ),
    );
  }

  void _showRatioModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius15),
        ),
      ),
      builder: (context) {
        final rules = controller.formulationConfig.value?['greyMixingRules'];
        final items =
            rules is List
                ? rules
                    .map(
                      (item) =>
                          item is Map ? Map<String, dynamic>.from(item) : null,
                    )
                    .whereType<Map<String, dynamic>>()
                    .toList()
                : <Map<String, dynamic>>[];
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grey Mixing Ratios',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Dimensions.height10),
                ...items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: Dimensions.height12),
                    child: Text(
                      item['label']?.toString() ?? '',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font13,
                        color: AppColors.grey5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
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
