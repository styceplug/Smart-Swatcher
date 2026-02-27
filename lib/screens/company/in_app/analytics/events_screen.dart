import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smart_swatcher/widgets/reminder_card.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/custom_appbar.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'Events',
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
                      '31 events',
                      style: TextStyle(
                        fontSize: Dimensions.font25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_down_circle_fill,
                          color: AppColors.grey4,
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
                      'Event Type',
                      style: TextStyle(
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Audio', style: TextStyle(color: AppColors.grey5)),
                        Text('20', style: TextStyle(color: AppColors.grey5)),
                      ],
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Video', style: TextStyle(color: AppColors.grey5)),
                        Text('3', style: TextStyle(color: AppColors.grey5)),
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
                    ReminderCard(
                      hostName: 'Terry',
                      hostRole: 'Host',
                      sessionType: 'Video',
                      title: 'Irony of Life',
                      dateTime: '1 Aug 2022',
                      onPressed: () {},
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
