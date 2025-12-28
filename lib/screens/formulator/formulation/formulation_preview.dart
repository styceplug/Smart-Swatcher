import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/controllers/folder_controller.dart';
import 'package:smart_swatcher/routes/routes.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../../widgets/snackbars.dart';

class FormulationPreview extends StatefulWidget {
  const FormulationPreview({Key? key}) : super(key: key);

  @override
  State<FormulationPreview> createState() => _FormulationPreviewState();
}

class _FormulationPreviewState extends State<FormulationPreview> {
  final ClientFolderController controller = Get.find<ClientFolderController>();

  Map<String, dynamic> inputs = {};
  Map<String, dynamic> outputs = {};
  String description = ""; // Local state for description

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      var bundle = Get.arguments as Map;
      inputs = bundle['inputs'] ?? {};
      outputs = bundle['outputs'] ?? {};
    }
  }

  // Save Logic
  // Inside _FormulationPreviewState

  void _onSave() {
    // 1. Try to get folderId from the wizard inputs first
    String? folderId = inputs['folderId'];

    // 2. Fallback: Try to get from the active ClientFolderController
    // We check if the controller is still in memory
    if ((folderId == null || folderId.isEmpty) && Get.isRegistered<ClientFolderController>()) {

      // Get the controller
      var folderController = Get.find<ClientFolderController>();

      // Access the Observable (.value) and then the nullable ID (.id)
      // Assuming 'currentFolder' is an Rx<ClientFolderModel?>
      folderId = folderController.currentFolder.value?.id;
    }

    // 3. Final Validation
    if (folderId == null || folderId.isEmpty) {
      CustomSnackBar.failure(message: "Folder ID is missing. Cannot save.");
      return;
    }

    // 4. Map Data
    Map<String, dynamic> savePayload = {
      "folderId": folderId,
      "status": "draft",

      // Images
      "imageUrl": inputs['imageUrl'] ?? "",
      "predictionImageUrl": outputs['predictionImageUrl'] ?? "",
      "finalImageUrl": "",

      // User Inputs
      "naturalBaseLevel": inputs['naturalBaseLevel'] ?? 0,
      "greyPercentage": inputs['greyPercentage'] ?? 0,
      "shadeType": inputs['shadeType'] ?? "natural",
      "desiredLevel": inputs['desiredLevel'] ?? 0,
      "desiredTone": inputs['desiredTone'] ?? "Natural",

      // AI Outputs
      "developerVolume": outputs['developerVolume'] ?? 0,
      "mixingRatio": outputs['mixingRatio'] ?? "1:1",
      "noteToStylist": outputs['noteToStylist'] ?? "",

      // Local Description
      "longDescription": description,

      // Complex Objects
      "steps": outputs['steps'] ?? [],
      "media": [],

      // Debug Data
      "inputData": inputs,
      "resultData": outputs,
      "logicVersion": "1.0"
    };

    // 5. Send via Controller -> Repo
    controller.saveFormulation(savePayload);
  }

  // Helper to get Full URL
  String _getFullUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('/')) {
      return '${AppConstants.BASE_URL}$path';
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate Lift
    int nbl = inputs['naturalBaseLevel'] ?? 0;
    int dl = inputs['desiredLevel'] ?? 0;
    int lift = (dl > nbl) ? dl - nbl : 0;
    int grey = inputs['greyPercentage'] ?? 0;

    String originalImg = _getFullUrl(inputs['imageUrl']);
    String predictionImg = _getFullUrl(outputs['predictionImageUrl']);

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        actionIcon: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: showShareModal,
              child: Icon(CupertinoIcons.share),
            ),
            SizedBox(width: Dimensions.width15),
            InkWell(
              onTap: _onSave,
              child: Text(
                'Save',
                style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w500, color: AppColors.primary5),
              ),
            ),
            SizedBox(width: Dimensions.width10),
          ],
        ),
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PREVIEW ORIGINAL ---
              if (originalImg.isNotEmpty)
                Container(
                  height: Dimensions.height100 * 2.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    image: DecorationImage(image: NetworkImage(originalImg), fit: BoxFit.cover),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(padding: EdgeInsets.all(8), child: Chip(label: Text("Original"))),
                  ),
                ),

              // --- PREVIEW NEW ---
              if (predictionImg.isNotEmpty)
                Container(
                  height: Dimensions.height100 * 2.5,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade100,
                    image: DecorationImage(image: NetworkImage(predictionImg), fit: BoxFit.cover),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(padding: EdgeInsets.all(8), child: Chip(label: Text("Prediction"))),
                  ),
                ),

              SizedBox(height: Dimensions.height20),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FORMULA SUMMARY ---
                    Row(
                      children: [
                        Icon(CupertinoIcons.drop, color: AppColors.accent1),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'NBL $nbl - G%$grey - DL $dl = $lift Lvl Lift',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.font16),
                        ),
                      ],
                    ),

                    SizedBox(height: Dimensions.height10),
                    Divider(color: AppColors.grey2),
                    SizedBox(height: Dimensions.height10),

                    // --- NOTE TO STYLIST ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(CupertinoIcons.lightbulb, color: AppColors.accent1, size: Dimensions.iconSize20),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: Text(
                            outputs['noteToStylist'] ??
                                'Your formulation requires $lift levels of lift. Pre-lighten client to raw base pigment (RBP) of level $dl then apply desired tone.',
                            style: TextStyle(height: 1.5, fontSize: Dimensions.font14),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: Dimensions.height10),
                    Divider(color: AppColors.grey2),
                    SizedBox(height: Dimensions.height10),

                    // --- ADD DESCRIPTION BUTTON ---
                    if (description.isEmpty)
                      IntrinsicWidth(
                        child: CustomButton(
                          text: 'Add description',
                          onPressed: () async {
                            // Wait for result from next screen
                            final result = await Get.toNamed(AppRoutes.addDescription);
                            if (result != null && result is String) {
                              setState(() {
                                description = result;
                              });
                            }
                          },
                          icon: Icon(CupertinoIcons.pencil, color: AppColors.primary5, size: 16),
                          backgroundColor: AppColors.bgColor,
                          borderColor: AppColors.primary5,
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.width10, vertical: Dimensions.height10),
                        ),
                      )
                    else
                    // Show Description if added
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Description:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(description),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: () async {
                              final result = await Get.toNamed(AppRoutes.addDescription, arguments: description);
                              if (result != null) setState(() => description = result);
                            },
                            child: Text("Edit", style: TextStyle(color: AppColors.primary5)),
                          )
                        ],
                      ),

                    SizedBox(height: Dimensions.height50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showShareModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius15),
        ),
      ),
      builder: (context) {
        final List<IconData> icons = [Icons.add, CupertinoIcons.share, CupertinoIcons.link];
        final List<String> value = ['Post', 'Share', 'Copy Link'];

        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formulator',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: icons.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {});
                        Get.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: Dimensions.height15,
                        ),
                        child: Row(
                          children: [
                            Icon(icons[index]),
                            SizedBox(width: Dimensions.width10),
                            Text(
                              value[index],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}