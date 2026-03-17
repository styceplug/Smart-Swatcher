import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/user_controller.dart';
import 'package:smart_swatcher/helpers/dependencies.dart';
import 'package:smart_swatcher/widgets/empty_state_widget.dart';

import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/recommended_account_card.dart';

class RecommendedAccountsScreen extends StatelessWidget {
  const RecommendedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController controller = Get.find<UserController>();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        title: 'Recommended Accounts',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height10,
              ),
              child: Obx(
                    () => Row(
                  children: [
                    _filterChip(
                      label: 'All',
                      selected: controller.selectedTypeFilter.value.isEmpty,
                      onTap: () => controller.setFilter(''),
                    ),
                    SizedBox(width: Dimensions.width10),
                    _filterChip(
                      label: 'Stylists',
                      selected:
                      controller.selectedTypeFilter.value == 'stylist',
                      onTap: () => controller.setFilter('stylist'),
                    ),
                    SizedBox(width: Dimensions.width10),
                    _filterChip(
                      label: 'Companies',
                      selected:
                      controller.selectedTypeFilter.value == 'company',
                      onTap: () => controller.setFilter('company'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isFetchingSuggestions.value &&
                    controller.suggestedAccounts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.suggestedAccounts.isEmpty) {
                  return const Center(
                    child: EmptyState(
                      message: 'No Recommended Accounts',
                      imageAsset: 'search-icon',
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshSuggestions,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height10,
                    ),
                    itemCount: controller.suggestedAccounts.length,
                    itemBuilder: (context, index) {
                      final account = controller.suggestedAccounts[index];
                      return RecommendedAccountCard(account: account);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius20),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary5 : AppColors.grey1,
          borderRadius: BorderRadius.circular(Dimensions.radius20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
            color: selected ? AppColors.white : AppColors.black1,
          ),
        ),
      ),
    );
  }
}