import 'package:flutter/material.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

class FormulationAnalysisCard extends StatelessWidget {
  const FormulationAnalysisCard({
    super.key,
    required this.analysis,
    this.title = 'Recommendations',
    this.initiallyExpanded = false,
  });

  final FormulationAnalysisModel? analysis;
  final String title;
  final bool initiallyExpanded;

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
    ];

    final guidanceChips = analysis!.guidanceChips;
    final compactSummary = _buildCompactSummary(
      analysis: analysis!,
      facts: facts,
      guidanceChips: guidanceChips,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5F1),
        borderRadius: BorderRadius.circular(Dimensions.radius12),
        border: Border.all(color: AppColors.grey1.withValues(alpha: 0.8)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.height8,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            Dimensions.width10,
            0,
            Dimensions.width10,
            Dimensions.height10,
          ),
          initiallyExpanded: initiallyExpanded,
          iconColor: AppColors.primary5,
          collapsedIconColor: AppColors.grey4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius12),
          ),
          title: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary5.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary5,
                  size: 13,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black1,
                  ),
                ),
              ),
            ],
          ),
          subtitle:
              compactSummary == null
                  ? null
                  : Padding(
                    padding: EdgeInsets.only(
                      left: Dimensions.width39,
                      top: Dimensions.height5,
                    ),
                    child: Text(
                      compactSummary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font12,
                        color: AppColors.grey5,
                        height: 1.4,
                      ),
                    ),
                  ),
          children: [
            if (facts.isNotEmpty)
              Text(
                facts
                    .map((fact) => '${fact.label}: ${fact.value}')
                    .join('  •  '),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
                  color: AppColors.grey5,
                  height: 1.45,
                ),
              ),
            if (facts.isNotEmpty && guidanceChips.isNotEmpty)
              SizedBox(height: Dimensions.height8),
            if (guidanceChips.isNotEmpty)
              Text(
                guidanceChips.join('  •  '),
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary5,
                  height: 1.45,
                ),
              ),
            if ((facts.isNotEmpty || guidanceChips.isNotEmpty) &&
                analysis!.cautions.isNotEmpty)
              SizedBox(height: Dimensions.height10),
            if (analysis!.cautions.isNotEmpty) ...[
              Text(
                'Notes',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey5,
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
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.grey4,
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
                            height: 1.4,
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
      ),
    );
  }

  String? _buildCompactSummary({
    required FormulationAnalysisModel analysis,
    required List<_InsightFact> facts,
    required List<String> guidanceChips,
  }) {
    final hints = <String>[
      if (analysis.estimatedBaseLevel != null)
        'Base L${analysis.estimatedBaseLevel}',
      if (analysis.estimatedGreyPercentage != null)
        '${analysis.estimatedGreyPercentage}% grey',
      if (analysis.estimatedUndertone != null) analysis.estimatedUndertone!,
      if (analysis.recommendedShadeType != null) analysis.recommendedShadeType!,
      ...guidanceChips.take(1),
    ];

    if (hints.isEmpty && facts.isEmpty) {
      return null;
    }

    if (hints.isNotEmpty) {
      return hints.join(' • ');
    }

    return facts.take(2).map((fact) => fact.value).join(' • ');
  }
}

class _InsightFact {
  const _InsightFact(this.label, this.value);

  final String label;
  final String value;
}
