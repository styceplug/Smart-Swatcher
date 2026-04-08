import 'package:flutter/material.dart';
import 'package:smart_swatcher/models/formulation_model.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';

class FormulationAnalysisCard extends StatelessWidget {
  const FormulationAnalysisCard({
    super.key,
    required this.analysis,
    this.title = 'Preview Analysis',
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
      if (analysis!.confidenceLabel != null)
        _InsightFact('Confidence', analysis!.confidenceLabel!),
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
        color: const Color(0xFFFBF8F5),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: AppColors.grey2),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: Dimensions.width10,
            vertical: Dimensions.height5,
          ),
          childrenPadding: EdgeInsets.fromLTRB(
            Dimensions.width10,
            0,
            Dimensions.width10,
            Dimensions.height12,
          ),
          initiallyExpanded: initiallyExpanded,
          iconColor: AppColors.primary5,
          collapsedIconColor: AppColors.grey4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius15),
          ),
          title: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary5.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.primary5,
                  size: 15,
                ),
              ),
              SizedBox(width: Dimensions.width10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w700,
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
                      maxLines: 2,
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
            if (guidanceChips.isNotEmpty) ...[
              Wrap(
                spacing: Dimensions.width8,
                runSpacing: Dimensions.height8,
                children:
                    guidanceChips
                        .map(
                          (chip) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width10,
                              vertical: Dimensions.height5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius20,
                              ),
                              border: Border.all(
                                color: AppColors.grey2,
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
              SizedBox(height: Dimensions.height10),
            ],
            if (facts.isNotEmpty) ...[
              Wrap(
                spacing: Dimensions.width8,
                runSpacing: Dimensions.height8,
                children:
                    facts
                        .map(
                          (fact) => Container(
                            constraints: BoxConstraints(
                              minWidth: Dimensions.width85,
                              maxWidth: Dimensions.width100 * 1.35,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width10,
                              vertical: Dimensions.height8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius12,
                              ),
                              border: Border.all(color: AppColors.grey1),
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
                                    fontSize: Dimensions.font12,
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
              SizedBox(height: Dimensions.height10),
            ],
            if (analysis!.cautions.isNotEmpty) ...[
              Text(
                'Cautions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: Dimensions.font12,
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
                          width: 5,
                          height: 5,
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
    final summary = analysis.analysisSummary?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }

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
