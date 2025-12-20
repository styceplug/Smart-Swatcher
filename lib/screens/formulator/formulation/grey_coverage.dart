import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/post_card.dart';

class GreyCoverage extends StatefulWidget {
  const GreyCoverage({super.key});

  @override
  State<GreyCoverage> createState() => _GreyCoverageState();
}

class _GreyCoverageState extends State<GreyCoverage> {
  String selectedPercent = '';

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
              width: (Dimensions.screenWidth/6)*5,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Grey Coverage %',
              style: TextStyle(fontSize: Dimensions.font20),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Estimate the percentage of grey hair your client has.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // Dropdown field
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape:  RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radius15),
                    ),
                  ),
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        final List<String> percents = [
                          '10%', '20%', '30%', '40%', '50%',
                          '60%', '70%', '80%', '90%', '100%',
                        ];

                        return Container(
                          height: Dimensions.screenHeight * 0.75,
                          padding: EdgeInsets.all(Dimensions.width20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Grey %',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font17,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => Get.back(),
                                    child: Icon(
                                      Icons.cancel,
                                      color: AppColors.grey4,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: AppColors.grey2),

                              Expanded(
                                child: ListView.builder(
                                  itemCount: percents.length,
                                  itemBuilder: (context, index) {
                                    final percent = percents[index];
                                    final isSelected =
                                        percent == selectedPercent;
                                    return InkWell(
                                      onTap: () {
                                        setModalState(() {
                                          selectedPercent = percent;
                                        });
                                        setState(() {
                                          selectedPercent = percent;
                                        });
                                        Get.back();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: Dimensions.height20),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isSelected
                                                  ? Icons.circle
                                                  : Icons.circle_outlined,
                                              color: isSelected
                                                  ? AppColors.primary4
                                                  : AppColors.grey4,
                                            ),
                                            SizedBox(
                                                width: Dimensions.width10),
                                            Text(
                                              percent,
                                              style: TextStyle(
                                                fontSize: Dimensions.font15,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w500,
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
                        );
                      },
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey3),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedPercent.isEmpty
                          ? 'Grey coverage %'
                          : selectedPercent,
                      style: TextStyle(
                        color: selectedPercent.isEmpty
                            ? AppColors.grey3
                            : Colors.black,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_outlined,
                      color: AppColors.grey3,
                      size: Dimensions.iconSize20,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Prev',
                    onPressed: () {
                      Get.toNamed(AppRoutes.selectDesireLevel);
                    },
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    text: 'Next',
                    onPressed: () {
                      if (selectedPercent.isEmpty) {
                        Get.snackbar('Select Percentage',
                            'Please choose a grey coverage percentage.');
                        return;
                      }
                      Get.toNamed(AppRoutes.greyExceeds, arguments: selectedPercent);
                    },
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
}

