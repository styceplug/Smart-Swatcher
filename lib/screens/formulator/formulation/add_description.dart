import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';

class AddDescription extends StatefulWidget {
  const AddDescription({super.key});

  @override
  State<AddDescription> createState() => _AddDescriptionState();
}


class _AddDescriptionState extends State<AddDescription> {
  late TextEditingController textController;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    String initialText = Get.arguments is String ? Get.arguments : "";
    textController = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        title: 'Description',
        actionIcon: InkWell(
          onTap: () {
            // RETURN DATA BACK && ADD TIME-STAMP
            Get.back(result: textController.text.trim());
            print('Hello World');
          },
          child: Text(
            'Done',
            style: TextStyle(
              fontSize: Dimensions.font15,
              color: AppColors.primary5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20
        ),
        child: TextField(
          controller: textController,
          autofocus: true,
          maxLines: null, // Allow multiline
          cursorHeight: Dimensions.height20,
          style: TextStyle(fontFamily: 'Poppins', fontSize: Dimensions.font16),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add notes about this formulation...",
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}