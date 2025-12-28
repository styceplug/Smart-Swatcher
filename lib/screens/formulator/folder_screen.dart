import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../models/folder_model.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({Key? key}) : super(key: key);

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  // 1. Get the Client Data passed from the previous screen
  late ClientFolderModel folder;

  @override
  void initState() {
    super.initState();
    if (Get.arguments is ClientFolderModel) {
      folder = Get.arguments as ClientFolderModel;
    } else {
      // Fallback for safety
      folder = ClientFolderModel(
        clientName: "Unknown",
        clientEmail: "",
        clientPhone: "",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        customTitle: Text(
          folder.clientName,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: Dimensions.font20,
          ),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width30),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.grey2)),
                ),
                child: TabBar(
                  indicatorColor: AppColors.primary5,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.primary5,
                  unselectedLabelColor: AppColors.grey4,
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: Dimensions.font16,
                  ),
                  tabs: const [Tab(text: 'Profile'), Tab(text: 'Formulations')],
                ),
              ),

              // --- TAB CONTENT ---
              Expanded(
                child: TabBarView(
                  children: [_buildProfileTab(), _buildFormulationsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    String dob = folder.dateOfBirth != null ? folder.dateOfBirth! : "N/A";
    String appointment =
        folder.appointmentDate != null
            ? folder.appointmentDate!
            : "No appointment set";

    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.width20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Dimensions.height100,
            width: Dimensions.width100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary1,
            ),
            child: Icon(CupertinoIcons.person, size: Dimensions.iconSize30 * 2),
          ),
          SizedBox(height: Dimensions.height20),
          _infoRow('Client\'s Name', folder.clientName),
          _infoRow('Phone Number', folder.clientPhone),
          _infoRow('Email Address', folder.clientEmail),
          _infoRow('Date of Birth', dob),
          _infoRow('Appointment Date', appointment),
          _infoRow('Consent Status', folder.consentStatus),
          _infoRow('Last Consent', folder.consentStatus),
          SizedBox(height: Dimensions.height20),
          CustomButton(
            text: 'Schedule Appointment',
            onPressed: () {},
            isDisabled: folder.consentStatus != 'approved',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.primary5,
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey4,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right),
            ],
          ),
          SizedBox(height: Dimensions.height10 * 0.6),
          Divider(),
        ],
      ),
    );
  }

  // --- TAB 2: FORMULATIONS UI (Empty State Logic) ---
  Widget _buildFormulationsTab() {
    // TODO: Connect this to a FormulationController later
    // For now, we assume the list is empty to show your design
    bool hasFormulations = false;

    if (!hasFormulations) {
      return Container(
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppConstants.getPngAsset('no-formulation'),
              height: Dimensions.height100 * 2,
              width: Dimensions.width100 * 2,
            ),
            SizedBox(height: Dimensions.height20),
            Text(
              'No formulation yet, create one \nto get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: Dimensions.height20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width50),
              child: CustomButton(
                text: 'Add New',
                onPressed: () {
                  Get.toNamed(AppRoutes.formulationOrCorrection);
                },
                backgroundColor: AppColors.primary4,
                icon: Icon(
                  CupertinoIcons.plus,
                  color: Colors.white,
                  size: Dimensions.iconSize20,
                ),
              ),
            ),
            SizedBox(height: Dimensions.height100), // Visual balance
          ],
        ),
      );
    }

    // If list is not empty (Placeholder for later)
    return Center(child: Text("List of Formulations will go here"));
  }
}
