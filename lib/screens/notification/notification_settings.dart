import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/snackbars.dart';

import '../../utils/dimensions.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {

  bool notifications = true;

  void switchNotifications(bool value) {
    setState(() {
      notifications = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Settings',
        backgroundColor: Colors.white,
        actionIcon: InkWell(
          onTap: (){
            CustomSnackBar.success(message: 'Congratulations');
          },
          child: Text(
            'Done',
            style: TextStyle(
              color: Colors.black,
              fontSize: Dimensions.font14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        leadingIcon: BackButton(
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          color: AppColors.bgColor,
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Socials & Events',
                style: TextStyle(
                  fontSize: Dimensions.font18,
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              SettingsSwitchTile(
                title: 'Likes',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'Comments & Replies',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'Mentions & Tags',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'New Connections',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'Friend Activity Updates',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'Invite to spaces',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'Space Announcements',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height30),
              Container(height: 1,color: AppColors.grey4,),
              SizedBox(height: Dimensions.height30),
              Text(
                'Messages',
                style: TextStyle(
                  fontSize: Dimensions.font18,
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              SettingsSwitchTile(
                title: 'Direct Messages',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'Group Chat Messages',
                value: notifications,
                onChanged: switchNotifications,
              ),
              SizedBox(height: Dimensions.height10),
              SettingsSwitchTile(
                title: 'Mentions in group chats',
                value: notifications,
                onChanged: switchNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(
      //   horizontal: Dimensions.width20,
      //   vertical: Dimensions.height10,
      // ),
      decoration: BoxDecoration(

      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: Dimensions.font15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.success1,
            activeTrackColor: AppColors.success2,
            inactiveThumbColor: AppColors.grey4,
            inactiveTrackColor: AppColors.grey3,
          ),
        ],
      ),
    );
  }
}
