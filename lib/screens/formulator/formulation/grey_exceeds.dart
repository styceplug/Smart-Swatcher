import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../routes/routes.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';

class GreyExceeds extends StatefulWidget {
  const GreyExceeds({super.key});

  @override
  State<GreyExceeds> createState() => _GreyExceedsState();
}

class _GreyExceedsState extends State<GreyExceeds> {
  String? selectedRatio;
  String? selectedShade;
  String? selectedAdd;

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
              width: Dimensions.screenWidth / 1,
              height: Dimensions.height5,
              color: AppColors.primary4,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Grey Hair Coverage Exceeds 10%',
              style: TextStyle(fontSize: Dimensions.font20),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Please select the appropriate grey coverage shade for the client’s hair.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height20),
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
            InkWell(
              onTap: () {
                setState(() {
                  selectedShade = 'fashion';
                });
              },
              child: Row(
                children: [
                  Icon(
                    selectedShade == 'fashion'
                        ? Icons.radio_button_checked_outlined
                        : Icons.circle_outlined,
                    size: Dimensions.iconSize20,
                    color:
                        selectedShade == 'fashion'
                            ? AppColors.primary4
                            : AppColors.grey4,
                  ),
                  SizedBox(width: Dimensions.width10),
                  Text(
                    'Fashion Shade',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),
            InkWell(
              onTap: () {
                setState(() {
                  selectedShade = 'natural-shade';
                });
              },
              child: Row(
                children: [
                  Icon(
                    selectedShade == 'natural-shade'
                        ? Icons.radio_button_checked
                        : Icons.circle_outlined,
                    size: Dimensions.iconSize20,
                    color: selectedShade == 'natural-shade' ? AppColors.primary4 : AppColors.grey4
                  ),
                  SizedBox(width: Dimensions.width10),
                  Text(
                    'Natural Shade',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.height40),
            Text(
              'Add Natural or Gold',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            InkWell(
              onTap: (){
                setState(() {
                  selectedAdd = 'natural';
                });
              },
              child: Row(
                children: [
                  Icon(selectedAdd == 'natural' ? Icons.radio_button_checked : Icons.circle_outlined, size: Dimensions.iconSize20),
                  SizedBox(width: Dimensions.width10),
                  Text(
                    'Natural',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Row(
              children: [
                Icon(Icons.circle_outlined, size: Dimensions.iconSize20),
                SizedBox(width: Dimensions.width10),
                Text(
                  'Gold',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),
            IntrinsicWidth(
              child: CustomButton(
                text: 'Mixing Ratios',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(Dimensions.radius15),
                      ),
                    ),
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          final List<String> percents = [
                            'Up to 25%',
                            '25% - 50%',
                            '50% - 100%',
                          ];
                          final List<String> ratios = ['2:1', '1:1', '1:1'];

                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: Padding(
                              padding: EdgeInsets.all(Dimensions.width20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '% Grey',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Mixing ratio (DL:N/G)',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: percents.length,
                                      itemBuilder: (context, index) {
                                        final percent = percents[index];
                                        final ratio = ratios[index];
                                        return InkWell(
                                          onTap: () {
                                            setModalState(() {
                                              selectedRatio = percent;
                                            });
                                            setState(() {
                                              selectedRatio = percent;
                                            });
                                            Get.back();
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: Dimensions.height20,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  percent,
                                                  style: TextStyle(
                                                    fontSize: Dimensions.font15,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  ratio,
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
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                icon: Icon(Icons.rounded_corner, size: Dimensions.iconSize20),
                backgroundColor: Colors.white,
                borderColor: AppColors.primary5,
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Prev',
                    onPressed: () {
                      Get.toNamed(AppRoutes.greyCoverage);
                    },
                    backgroundColor: AppColors.primary1,
                  ),
                ),
                SizedBox(width: Dimensions.width20),
                Expanded(
                  child: CustomButton(
                    isDisabled: selectedRatio == null,
                    text: 'Next',
                    onPressed: () {
                      if (selectedRatio == null)
                        Get.toNamed(AppRoutes.selectDesireLevel);
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
