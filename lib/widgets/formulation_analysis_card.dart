import 'package:flutter/material.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

class FormulationAnalysisCard extends StatelessWidget {
  const FormulationAnalysisCard({
    super.key,
    required this.analysis,
    this.title = 'AI Hair Analysis',
  });

  final FormulationAnalysisModel? analysis;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (analysis == null) {
      return const SizedBox.shrink();
    }

    final facts = <_InsightFact>[
      if (analysis!.estimatedBaseLevel != null)
        _InsightFact('Base estimate', 'Level ${analysis!.estimatedBaseLevel}'),
      if (analysis!.estimatedBaseLabel != null)
        _InsightFact('Base label', analysis!.estimatedBaseLabel!),
      if (analysis!.estimatedGreyPercentage != null)
        _InsightFact('Grey estimate', '${analysis!.estimatedGreyPercentage}%'),
      if (analysis!.estimatedUndertone != null)
        _InsightFact('Undertone', analysis!.estimatedUndertone!),
      if (analysis!.underlyingPigment != null)
        _InsightFact('Pigment', analysis!.underlyingPigment!),
      if (analysis!.confidenceLabel != null)
        _InsightFact('Confidence', analysis!.confidenceLabel!),
    ];

    final guidanceChips = analysis!.guidanceChips;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Dimensions.width15),
      decoration: BoxDecoration(
        color: AppColors.primary1,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.primary5.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary5,
            ),
          ),
          if (analysis!.analysisSummary?.trim().isNotEmpty == true) ...[
            SizedBox(height: Dimensions.height10),
            Text(
              analysis!.analysisSummary!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font13,
                color: AppColors.grey5,
                height: 1.5,
              ),
            ),
          ],
          if (guidanceChips.isNotEmpty) ...[
            SizedBox(height: Dimensions.height10),
            Wrap(
              spacing: Dimensions.width8,
              runSpacing: Dimensions.height8,
              children:
                  guidanceChips
                      .map(
                        (chip) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius20,
                            ),
                            border: Border.all(
                              color: AppColors.primary5.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            chip,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary5,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
          if (facts.isNotEmpty) ...[
            SizedBox(height: Dimensions.height12),
            Wrap(
              spacing: Dimensions.width13,
              runSpacing: Dimensions.height10,
              children:
                  facts
                      .map(
                        (fact) => Container(
                          constraints: BoxConstraints(
                            minWidth: Dimensions.width100,
                            maxWidth: Dimensions.width100 * 1.55,
                          ),
                          padding: EdgeInsets.all(Dimensions.width10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius12,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fact.label,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: Dimensions.font10,
                                  color: AppColors.grey4,
                                ),
                              ),
                              SizedBox(height: Dimensions.height5),
                              Text(
                                fact.value,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: Dimensions.font13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
          if (analysis!.cautions.isNotEmpty) ...[
            SizedBox(height: Dimensions.height12),
            Text(
              'Cautions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font13,
                fontWeight: FontWeight.w600,
                color: AppColors.black1,
              ),
            ),
            SizedBox(height: Dimensions.height8),
            ...analysis!.cautions.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: Dimensions.height8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: Dimensions.height5),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary5,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.width10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font12,
                          color: AppColors.grey5,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightFact {
  const _InsightFact(this.label, this.value);

  final String label;
  final String value;
}
