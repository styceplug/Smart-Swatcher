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

import '../../controllers/folder_controller.dart';
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
      folder = ClientFolderModel(
        clientName: "",
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
          folder.clientName ?? '',
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
          _infoRow('Client\'s Name', folder.clientName ?? ''),
          _infoRow('Phone Number', folder.clientPhone ?? ''),
          _infoRow('Email Address', folder.clientEmail ?? ''),
          _infoRow('Date of Birth', dob),
          _infoRow('Appointment Date', appointment),
          _infoRow('Consent Status', folder.consentStatus ?? ''),
          _infoRow('Last Consent', folder.consentStatus ?? ''),
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

  Widget _buildFormulationsTab() {
    final ClientFolderController controller =
        Get.find<ClientFolderController>();

    // Helper to format date (e.g., "Oct 24, 2023")
    // If you don't have intl package, you can just use string substring
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return "Recently";
      try {
        DateTime date = DateTime.parse(dateStr);
        return DateFormat.yMMMd().format(date); // Requires intl package
        // OR without intl: return "${date.day}/${date.month}/${date.year}";
      } catch (e) {
        return "Unknown date";
      }
    }

    // Helper to fix relative URLs
    String getFullUrl(String? path) {
      if (path == null || path.isEmpty) return "";
      if (path.startsWith('http')) return path;
      if (path.startsWith('/')) return '${AppConstants.BASE_URL}$path';
      return '${AppConstants.BASE_URL}/$path';
    }

    return Stack(
      children: [
        Obx(() {
        if (controller.formulationsList.isEmpty) {
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
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width50,
                  ),
                  child: CustomButton(
                    text: 'Add New',
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.formulationOrCorrection,
                        arguments: {'folderId': folder.id},
                      );
                    },
                    backgroundColor: AppColors.primary4,
                    icon: Icon(
                      CupertinoIcons.plus,
                      color: Colors.white,
                      size: Dimensions.iconSize20,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 3. List (Success)
        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height10,
          ),
          itemCount: controller.formulationsList.length,
          itemBuilder: (context, index) {
            final form = controller.formulationsList[index];

            String originalImg = getFullUrl(form.imageUrl);
            String predictedImg = getFullUrl(form.predictionImageUrl);

            return GestureDetector(
              onTap: () {
                var bundle = {
                  'inputs': form.inputData ?? {},
                  'outputs': form.resultData ?? {},
                };
                Get.toNamed(AppRoutes.formulationPreview, arguments: bundle);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: Dimensions.height15),
                padding: EdgeInsets.all(Dimensions.width10),
                // Increased padding slightly
                decoration: BoxDecoration(
                  color: Colors.white, // Need a background color for shadow
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- SPLIT IMAGE PREVIEW ---
                    Container(
                      width: Dimensions.width10 * 8,
                      // Adjusted width
                      height: Dimensions.width10 * 8,
                      // Square aspect
                      clipBehavior: Clip.hardEdge,
                      // Clip images to border
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius15 / 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Original Image (Left Half)
                          Expanded(
                            child:
                                originalImg.isNotEmpty
                                    ? Image.network(
                                      originalImg,
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      errorBuilder:
                                          (c, o, s) => Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 15,
                                            ),
                                          ),
                                    )
                                    : Container(color: Colors.grey[300]),
                          ),
                          // Prediction Image (Right Half)
                          Expanded(
                            child:
                                predictedImg.isNotEmpty
                                    ? Image.network(
                                      predictedImg,
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                      errorBuilder:
                                          (c, o, s) => Container(
                                            color: AppColors.primary4.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                    )
                                    : Container(
                                      color: AppColors.primary4.withOpacity(0.1),
                                    ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: Dimensions.width15),

                    // --- TEXT DETAILS ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // "Lvl 4 > Lvl 9"
                          Text(
                            'Lvl ${form.naturalBaseLevel} > Lvl ${form.desiredLevel}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          // "Created Oct 24, 2023"
                          Text(
                            'Created ${formatDate(form.createdAt)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: Dimensions.font12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- ACTIONS ---
                    InkWell(
                      onTap: () {
                        showShareModal();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.more_horiz, color: AppColors.grey4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
        Positioned(
          right: Dimensions.width20,
          bottom: Dimensions.height100,
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius30),
            ),
            heroTag: "folder_fab",
            onPressed: () {
              Get.toNamed(
                AppRoutes.formulationOrCorrection,
                arguments: {'folderId': folder.id},
              );
            },
            backgroundColor: AppColors.primary5,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),

      ],
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
        final List<IconData> icons = [
          Icons.add,
          CupertinoIcons.share,
          CupertinoIcons.link,
          CupertinoIcons.delete,
        ];
        final List<String> value = ['Post', 'Share', 'Copy Link', 'Delete'];

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
