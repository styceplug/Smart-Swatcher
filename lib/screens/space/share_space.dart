import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/reminder_card.dart';
import 'package:smart_swatcher/widgets/share_event_card.dart';

class ShareSpaceScreen extends StatefulWidget {
  const ShareSpaceScreen({super.key});

  @override
  State<ShareSpaceScreen> createState() => _ShareSpaceScreenState();
}

class _ShareSpaceScreenState extends State<ShareSpaceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: Icon(Icons.close),
        backgroundColor: AppColors.white,
      ),

      body: Container(
        color: AppColors.bgColor,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width40),
              child: Text(
                'Event Created. Time to share it with your people',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Dimensions.font17,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),
            ShareEventCard(
              hostName: 'Macho',
              hostRole: 'Host',
              sessionType: 'VIDEO',
              title: 'Grey Coverage Q&A',
              dateTime: '18 Aug 2025 at 18:30',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
