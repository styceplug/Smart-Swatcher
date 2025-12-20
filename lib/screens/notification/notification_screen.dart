import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

import '../../routes/routes.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: Colors.white,
        leadingIcon: BackButton(
          onPressed: () {
            Get.back();
          },
        ),
        title: 'Notifications',
        actionIcon: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.notificationSettingsScreen);
          },
          child: Icon(Iconsax.setting),
        ),
      ),
      body: DefaultTabController(
        length: 4,
        child: Container(
          color: Colors.white,
          width: Dimensions.screenWidth,

          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: TabBar(
                  indicatorColor: Colors.black,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(fontFamily: 'Poppins',fontWeight: FontWeight.w500),
                  tabs: [
                    Tab(text: 'All'),
                    Tab(text: 'Activity'),
                    Tab(text: 'Connection'),
                    Tab(text: 'Replies'),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: AppColors.bgColor,
                  child: TabBarView(
                    children: [
                      Center(child: Text('All')),
                      Center(child: Text('Activities')),
                      Center(child: Text('Connections')),
                      Center(child: Text('Replies')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
