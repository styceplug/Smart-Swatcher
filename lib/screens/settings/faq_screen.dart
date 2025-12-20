import 'package:flutter/material.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: 'FAQ',
        leadingIcon: BackButton(),
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
      ),
    );
  }
}
