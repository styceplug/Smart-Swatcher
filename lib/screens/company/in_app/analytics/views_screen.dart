import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/custom_appbar.dart';

class ViewsScreen extends StatefulWidget {
  const ViewsScreen({super.key});

  @override
  State<ViewsScreen> createState() => _ViewsScreenState();
}

class _ViewsScreenState extends State<ViewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Views',
        leadingIcon: BackButton(),
        actionIcon: Icon(Iconsax.info_circle, color: AppColors.grey5),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10,
                        vertical: Dimensions.height5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey3),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text('1 Week'),
                          SizedBox(width: Dimensions.width5),
                          Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10,
                        vertical: Dimensions.height5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey3),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                      ),
                      child: Text('21 Jul - 22 Aug'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '15,430 views',
                      style: TextStyle(
                        fontSize: Dimensions.font25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_up_circle_fill,
                          color: AppColors.primary3,
                          size: Dimensions.iconSize16,
                        ),
                        SizedBox(width: Dimensions.width5),
                        Text(
                          '+33% vs Last Week',
                          style: TextStyle(color: AppColors.grey5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Content Type',
                      style: TextStyle(
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Media', style: TextStyle(color: AppColors.grey5)),
                        Text('6,664', style: TextStyle(color: AppColors.grey5)),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Formular',
                          style: TextStyle(color: AppColors.grey5),
                        ),
                        Text('4,564', style: TextStyle(color: AppColors.grey5)),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Posts', style: TextStyle(color: AppColors.grey5)),
                        Text('5,594', style: TextStyle(color: AppColors.grey5)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.height5),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.height20,
                  horizontal: Dimensions.width20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.grey2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Contents',
                          style: TextStyle(
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            fontSize: Dimensions.font15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width10,
                        vertical: Dimensions.height10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.grey3),
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius10,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: Dimensions.height30,
                                width: Dimensions.width30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary1,
                                ),
                              ),
                              SizedBox(width: Dimensions.width10),
                              Text(
                                'jakobjelling',
                                style: TextStyle(
                                  fontSize: Dimensions.font13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: Dimensions.width10),
                              Text(
                                '. April 2, 2025',
                                style: TextStyle(
                                  fontSize: Dimensions.font13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Dimensions.height10),
                          Text(
                            'Lorem ipsum dolor sit amet consectetur. Aenean amet leo viverra feugiat ante. Pellentesque scelerisque malesuada arcu integer sapien...',
                            style: TextStyle(color: AppColors.grey5),
                          ),
                          SizedBox(height: Dimensions.height10),
                          Divider(),
                          SizedBox(height: Dimensions.height10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.heart,
                                    size: Dimensions.iconSize20,
                                  ),
                                  SizedBox(width: Dimensions.width5),
                                  Text(
                                    '125',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: Dimensions.width20),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.bookmark,
                                    size: Dimensions.iconSize20,
                                  ),
                                  SizedBox(width: Dimensions.width5),
                                  Text(
                                    '65',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: Dimensions.width20),

                              Row(
                                children: [
                                  Icon(
                                    Iconsax.message,
                                    size: Dimensions.iconSize20,
                                  ),
                                  SizedBox(width: Dimensions.width5),
                                  Text(
                                    '240',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text('994 views'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Dimensions.height100),
            ],
          ),
        ),
      ),
    );
  }
}
