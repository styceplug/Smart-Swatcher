import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../widgets/custom_appbar.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: BackButton(), title: "Subscriptions"),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            body: Column(
              children: [
                TabBar(
                  padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
                  labelStyle: TextStyle(
                    fontSize: Dimensions.font15,
                    fontFamily: 'Poppins',
                  ),
                  indicatorColor: AppColors.primary6,
                  labelColor: Colors.black,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.symmetric(
                    vertical: Dimensions.height10,
                  ),
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Text('Essential'),
                    Text('Pro Artist'),
                    Text('Educator/Owner', overflow: TextOverflow.ellipsis),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      buildEssentialTab(),
                      buildProTab(),
                      buildEducatorTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEssentialTab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Essential',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Access to swatch library',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Basic smart formulator',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Save up to 20 client profiles',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Export PDFs (limited styling)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Color club access',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Stack(
                    children: [
                      Container(height: Dimensions.height100),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height15,
                            horizontal: Dimensions.width20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary4),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                          ),

                          child: Row(
                            children: [
                              Icon(Icons.circle_outlined),
                              SizedBox(width: Dimensions.width20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Annual',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: Dimensions.width10),
                                      Text(
                                        '\$99.99/year',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '7 Days Trial (Save 17%)',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: Dimensions.width20,
                        bottom: Dimensions.height20 * 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary5,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                          ),
                          child: Text(
                            'Best Value',
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height15,
                      horizontal: Dimensions.width20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary4),
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),

                    child: Row(
                      children: [
                        Icon(Icons.circle_outlined),
                        SizedBox(width: Dimensions.width20),
                        Row(
                          children: [
                            Text(
                              'Monthly',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Text(
                              '\$9.99/month',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height20,
              Dimensions.width20,
              0,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.grey4)),
              color: AppColors.white,
            ),
            child: Column(
              children: [
                CustomButton(
                  text: 'Start 7-Days Free Trial',
                  onPressed: () {},
                  backgroundColor: AppColors.primary5,
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(width: Dimensions.width50),
                    Text(
                      'Terms of use',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: Dimensions.height20,
                      width: 2,
                      color: AppColors.primary5,
                    ),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: Dimensions.width50),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProTab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Pro Artist',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Everything in essential +',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Unlimited client profiles',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Text(
                          'Full smart formulator (Advanced color theory assist)',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Color club elite',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Text(
                          'Swatch sharing/Team collaboration',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Branded client reports',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Priority Support',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Stack(
                    children: [
                      Container(height: Dimensions.height100),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height15,
                            horizontal: Dimensions.width20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary4),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                          ),

                          child: Row(
                            children: [
                              Icon(Icons.circle_outlined),
                              SizedBox(width: Dimensions.width20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Annual',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: Dimensions.width10),
                                      Text(
                                        '\$99.99/year',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '7 Days Trial (Save 17%)',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: Dimensions.width20,
                        bottom: Dimensions.height20 * 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary5,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                          ),
                          child: Text(
                            'Best Value',
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height15,
                      horizontal: Dimensions.width20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary4),
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),

                    child: Row(
                      children: [
                        Icon(Icons.circle_outlined),
                        SizedBox(width: Dimensions.width20),
                        Row(
                          children: [
                            Text(
                              'Monthly',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Text(
                              '\$9.99/month',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height20,
              Dimensions.width20,
              0,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.grey4)),
              color: AppColors.white,
            ),
            child: Column(
              children: [
                CustomButton(
                  text: 'Start 7-Days Free Trial',
                  onPressed: () {},
                  backgroundColor: AppColors.primary5,
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(width: Dimensions.width50),
                    Text(
                      'Terms of use',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: Dimensions.height20,
                      width: 2,
                      color: AppColors.primary5,
                    ),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: Dimensions.width50),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEducatorTab() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Educator/Owner',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: Dimensions.font20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Everything in Pro Artist +',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Multi-user/team logins',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Text(
                          'Education Mode (Lesson templates, student tracking)',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Custom Swatch Palettes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Text(
                        'Data Backup + Sync',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: Dimensions.font17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Text(
                          'White -label reports (salon branding)',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: AppColors.primary3,
                        size: Dimensions.iconSize20,
                      ),
                      SizedBox(width: Dimensions.width20),
                      Expanded(
                        child: Text(
                          'Early beta access to new features',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Stack(
                    children: [
                      Container(height: Dimensions.height100),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.height15,
                            horizontal: Dimensions.width20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary4),
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                          ),

                          child: Row(
                            children: [
                              Icon(Icons.circle_outlined),
                              SizedBox(width: Dimensions.width20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Annual',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: Dimensions.width10),
                                      Text(
                                        '\$99.99/year',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: Dimensions.font17,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '7 Days Trial (Save 17%)',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: Dimensions.font14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: Dimensions.width20,
                        bottom: Dimensions.height20 * 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                            vertical: Dimensions.height5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary5,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                          ),
                          child: Text(
                            'Best Value',
                            style: TextStyle(
                              color: AppColors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height15,
                      horizontal: Dimensions.width20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary4),
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),

                    child: Row(
                      children: [
                        Icon(Icons.circle_outlined),
                        SizedBox(width: Dimensions.width20),
                        Row(
                          children: [
                            Text(
                              'Monthly',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            Text(
                              '\$9.99/month',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: Dimensions.font17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height20,
              Dimensions.width20,
              0,
            ),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.grey4)),
              color: AppColors.white,
            ),
            child: Column(
              children: [
                CustomButton(
                  text: 'Start 7-Days Free Trial',
                  onPressed: () {},
                  backgroundColor: AppColors.primary5,
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(width: Dimensions.width50),
                    Text(
                      'Terms of use',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: Dimensions.height20,
                      width: 2,
                      color: AppColors.primary5,
                    ),
                    Text(
                      'Privacy Policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontFamily: 'Poppins',
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: Dimensions.width50),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
