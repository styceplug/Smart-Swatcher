import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/widgets/post_card.dart';

import '../routes/routes.dart';
import '../utils/app_constants.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class FolderCard extends StatelessWidget {
  final String clientName;
  final VoidCallback? onTap;

  const FolderCard({required this.clientName, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: Dimensions.screenWidth / 2.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radius10),
              border: Border.all(color: AppColors.primary3.withOpacity(0.2)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width10,
              vertical: Dimensions.height20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset(
                  AppConstants.getPngAsset('file-icon'),
                  color: AppColors.primary3,
                  height: Dimensions.height70,
                  width: Dimensions.width70,
                ),
                Spacer(),
                InkWell(
                  onTap: () {
                    debugPrint('post tapped');
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Container(
                              padding: EdgeInsets.fromLTRB(
                                Dimensions.width20,
                                Dimensions.height20,
                                Dimensions.width20,
                                Dimensions.height20,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: Dimensions.height10,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: AppColors.grey2,
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(
                                            AppConstants.getPngAsset('file-icon'),
                                            height: Dimensions.height20,
                                            width: Dimensions.width20,
                                            color: AppColors.primary3,
                                          ),
                                          SizedBox(width: Dimensions.width10),
                                          Text(
                                            clientName,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: Dimensions.font16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.cancel,
                                            color: AppColors.grey4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    OptionTile(
                                      icon: Iconsax.edit,
                                      title: 'Rename',
                                    ),
                                    OptionTile(
                                      icon: Iconsax.share,
                                      title: 'Share',
                                    ),
                                    OptionTile(
                                      icon: Icons.control_point_duplicate,
                                      title: 'Duplicate',
                                    ),
                                    OptionTile(
                                      icon: CupertinoIcons.delete,
                                      title: 'Delete',
                                    ),
                                    SizedBox(height: Dimensions.height20)
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },

                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey2,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.more_horiz,
                      color: AppColors.primary5,
                      size: Dimensions.iconSize20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.height5),
          Text(
            clientName,
            style: TextStyle(
              fontSize: Dimensions.font14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
