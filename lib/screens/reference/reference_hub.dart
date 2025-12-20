import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/reference_card.dart';

import '../../routes/routes.dart';

class ReferenceHub extends StatefulWidget {
  const ReferenceHub({super.key});

  @override
  State<ReferenceHub> createState() => _ReferenceHubState();
}

class _ReferenceHubState extends State<ReferenceHub> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: BackButton()),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reference Hub',
              style: TextStyle(fontSize: Dimensions.font20),
            ),
            SizedBox(height: Dimensions.height20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  InkWell(
                    onTap: (){
                      Get.toNamed(AppRoutes.hairFormulatorGuide);
                    },
                    child: Container(
                      height: Dimensions.height20 * 15,
                      width: Dimensions.screenWidth * 0.8,
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radius15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            AppConstants.getPngAsset('formulator-guide'),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Hair Formulator Guide',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w600
                    
                            ),
                          ),
                          Text(
                            'Hair color theory fundamentals - reference guide',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  InkWell(
                    onTap: (){
                      Get.toNamed(AppRoutes.mixingRatioGuide);
                    },
                    child: Container(
                      height: Dimensions.height20 * 15,
                      width: Dimensions.screenWidth * 0.8,
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radius15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            AppConstants.getPngAsset('ratio'),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Mixing Ratios at a Glance Guide',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w600
                    
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  InkWell(
                    onTap: (){
                      Get.toNamed(AppRoutes.troubleShootingGuide);
                    },
                    child: Container(
                      height: Dimensions.height20 * 15,
                      width: Dimensions.screenWidth * 0.8,
                      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radius15),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            AppConstants.getPngAsset('trouble'),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Trouble Shooting At A Glance',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font17,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            'Quick Fixes for Common Formulation Issues',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.white,
                              fontSize: Dimensions.font14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'Quick Reference',
              style: TextStyle(fontSize: Dimensions.font20),
            ),
            SizedBox(height: Dimensions.height20),
            ReferenceCard(timeAgo: '02 HOUR AGO', title: 'From Level to Lift: Understanding Hair Color Changes'),
            ReferenceCard(timeAgo: '55 MINS AGO', title: 'From Subtle Shifts to Bold Statements'),
          ],
        ),
      ),
    );
  }
}
