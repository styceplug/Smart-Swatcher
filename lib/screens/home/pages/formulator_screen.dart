import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';
import 'package:smart_swatcher/widgets/empty_state_widget.dart';
import 'package:smart_swatcher/widgets/folder_card.dart';

import '../../../controllers/folder_controller.dart';
import '../../../routes/routes.dart';
import '../../../widgets/custom_button.dart';

class FormulatorScreen extends StatefulWidget {
  const FormulatorScreen({super.key});

  @override
  State<FormulatorScreen> createState() => _FormulatorScreenState();
}

class _FormulatorScreenState extends State<FormulatorScreen>
    with AutomaticKeepAliveClientMixin {

  // 1. Inject Controller
  final ClientFolderController controller = Get.put(ClientFolderController());

  // 2. Search State
  final TextEditingController searchInputCtrl = TextEditingController();
  final RxString searchQuery = ''.obs; // Reactive variable for search

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for KeepAlive

    return Container(
      width: Dimensions.screenWidth,
      height: Dimensions.screenHeight,
      padding: EdgeInsets.fromLTRB(
        0,
        Dimensions.width20,
        0,
        Dimensions.height20 + kBottomNavigationBarHeight,
      ),
      child: Stack(
        children: [
          Column(
            children: [
              CustomAppbar(
                centerTitle: false,
                customTitle: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Text('Formulator')],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- SEARCH BAR ---
                      CustomTextField(
                        controller: searchInputCtrl,
                        prefixIcon: Icons.search,
                        hintText: 'Search for client\'s name',
                        // Update search query on type
                        onChanged: (val) => searchQuery.value = val,
                      ),
                      SizedBox(height: Dimensions.height20),

                      // --- MAIN CONTENT AREA (Reactive) ---
                      Expanded(
                        child: Obx(() {
                          // A. LOADING STATE
                          if (controller.isFetching.value) {
                            return Center(
                              child: CircularProgressIndicator(color: AppColors.primary5),
                            );
                          }

                          // Filter Logic: Search Filter
                          final filteredList = controller.foldersList.where((folder) {
                            return folder.clientName.toLowerCase().contains(searchQuery.value.toLowerCase());
                          }).toList();

                          // B. EMPTY STATE (No Clients or No Search Results)
                          if (filteredList.isEmpty) {
                            // If user is searching and finds nothing
                            if (searchQuery.value.isNotEmpty) {
                              return Center(child: Text("No clients found matching '${searchQuery.value}'"));
                            }

                            // If actually no data (Your Empty Design)
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: Dimensions.height20 * 10, // Adjusted height
                                  child: EmptyState(
                                    message: 'No client folder yet, create one to start adding formulations',
                                    // imageAsset: 'file-icon', // Uncomment if asset exists
                                  ),
                                ),
                                SizedBox(height: Dimensions.height20),
                                CustomButton(
                                  text: 'Create Folder',
                                  backgroundColor: AppColors.primary5,
                                  onPressed: () => Get.toNamed(AppRoutes.createFolder),
                                ),
                              ],
                            );
                          }

                          // C. GRID VIEW (Success)
                          return RefreshIndicator(
                            onRefresh: () async => await controller.getFolders(),
                            color: AppColors.primary5,
                            child: GridView.builder(
                              padding: EdgeInsets.only(bottom: Dimensions.height100), // Space for FAB
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: Dimensions.height15,
                                crossAxisSpacing: Dimensions.width15,
                                childAspectRatio: 1.1,
                              ),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final folder = filteredList[index];
                                return FolderCard(
                                  clientName: folder.clientName,
                                  onTap: (){
                                    Get.toNamed(AppRoutes.folderScreen, arguments: folder);
                                  },

                                );
                              },
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // --- FAB (Only show if list is not empty, or always show - your choice) ---
          Positioned(
            right: Dimensions.width20,
            bottom: Dimensions.height50 + kBottomNavigationBarHeight,
            child: InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.createFolder);
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary4,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
