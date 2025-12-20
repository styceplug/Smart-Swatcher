import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_swatcher/utils/app_constants.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_textfield.dart';
import 'package:smart_swatcher/widgets/empty_state_widget.dart';
import 'package:smart_swatcher/widgets/folder_card.dart';

import '../../../routes/routes.dart';
import '../../../widgets/custom_button.dart';

class FormulatorScreen extends StatefulWidget {
  const FormulatorScreen({super.key});

  @override
  State<FormulatorScreen> createState() => _FormulatorScreenState();
}

class _FormulatorScreenState extends State<FormulatorScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final clients = [
      {'name': 'Client A'},
      {'name': 'Client B'},
      {'name': 'Client C'},
      {'name': 'Client D'},
      {'name': 'Client E'},
      {'name': 'Client F'},
      {'name': 'Client G'},
    ];

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
                      CustomTextField(
                        prefixIcon: Icons.search,
                        hintText: 'Search for client\'s name',
                      ),
                      SizedBox(height: Dimensions.height50),

                      ///EMPTY STATE
                      /*Container(
                      alignment: Alignment.center,
                      height: Dimensions.height20 * 19,
                      child: EmptyState(
                        message:
                            'No client folder yet, create one to start adding formulations',
                        imageAsset: 'file-icon',
                      ),
                    ),
                    CustomButton(text: 'Create Folder', onPressed: () {},backgroundColor: AppColors.primary5,),*/

                      ///FOLDER
                      Expanded(
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: Dimensions.height5,
                                crossAxisSpacing: Dimensions.width15,
                                childAspectRatio: 1.1,
                              ),
                          itemCount: clients.length,
                          itemBuilder: (context, index) {
                            final client = clients[index];
                            return FolderCard(clientName: client['name'] ?? '');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            right: Dimensions.width20,
            bottom: Dimensions.height50 + kBottomNavigationBarHeight,
            child: InkWell(
              onTap: (){
                Get.toNamed(AppRoutes.createFolder);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width15,vertical: Dimensions.height15),
                decoration: BoxDecoration(
                  color: AppColors.primary4,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add,color: Colors.white,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
