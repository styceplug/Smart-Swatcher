import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';

import '../../controllers/folder_controller.dart';
import '../../widgets/custom_textfield.dart';

class CreateFolderScreen extends StatefulWidget {
  const CreateFolderScreen({Key? key}) : super(key: key);

  @override
  State<CreateFolderScreen> createState() => _CreateFolderScreenState();
}

class _CreateFolderScreenState extends State<CreateFolderScreen> {
  // 1. Initialize Controller
  final ClientFolderController controller = Get.put(ClientFolderController());

  // 2. Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Display Controllers (Read-only for user, updated by picker)
  final TextEditingController dobController = TextEditingController();
  final TextEditingController appointmentController = TextEditingController();

  // 3. Variables to store actual Date objects for API (YYYY-MM-DD)
  DateTime? selectedDob;
  DateTime? selectedAppointmentDate;

  // 4. Toggles
  bool reminder = false;
  bool sendConsent = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    dobController.dispose();
    appointmentController.dispose();
    super.dispose();
  }

  // --- Date Picker Logic ---
  void _showDatePicker(BuildContext context, {required bool isDob}) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                maximumDate: isDob ? DateTime.now() : DateTime(2100),
                minimumDate: isDob ? DateTime(1900) : DateTime.now().subtract(const Duration(days: 1)),
                onDateTimeChanged: (val) {
                  setState(() {
                    if (isDob) {
                      selectedDob = val;
                      // Display: Jun 14, 2025
                      dobController.text = DateFormat('MMM dd, yyyy').format(val);
                    } else {
                      selectedAppointmentDate = val;
                      // Display: Jun 14, 2025
                      appointmentController.text = DateFormat('MMM dd, yyyy').format(val);
                    }
                  });
                },
              ),
            ),
            // Close Button
            CupertinoButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
    );
  }

  // --- Submit Logic ---
  void _submitFolder() {
    // Helper to format for Backend: YYYY-MM-DD
    String? apiDob = selectedDob != null
        ? DateFormat('yyyy-MM-dd').format(selectedDob!)
        : null;

    String? apiAppointment = selectedAppointmentDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedAppointmentDate!)
        : null;

    controller.createClientFolder(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      dob: apiDob,
      appointmentDate: apiAppointment,
      shouldSendConsent: sendConsent,
      // Pass reminder if your backend supports it (add to controller if needed)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        backgroundColor: Colors.white,
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client\'s Details',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: Dimensions.font22,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'Add Client information to start the formulation process',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: Dimensions.font14,
                fontFamily: 'Poppins',
                color: AppColors.grey5,
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // --- INPUT FIELDS ---
            CustomTextField(
              controller: nameController,
              labelText: 'Client\'s name',
              hintText: 'Enter name',
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              controller: phoneController,
              labelText: 'Phone number',
              hintText: 'Enter phone number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              controller: emailController,
              labelText: 'Email address',
              hintText: 'Enter email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: Dimensions.height20),

            // --- DATE PICKERS ---
            // Date of Birth
            GestureDetector(
              onTap: () => _showDatePicker(context, isDob: true),
              child: AbsorbPointer( // Prevents keyboard from opening
                child: CustomTextField(
                  controller: dobController,
                  labelText: 'Date of birth',
                  hintText: 'Select Date',
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // Appointment Date
            GestureDetector(
              onTap: () => _showDatePicker(context, isDob: false),
              child: AbsorbPointer(
                child: CustomTextField(
                  controller: appointmentController,
                  labelText: 'Appointment date',
                  hintText: 'Select Date',
                  suffixIcon: const Icon(Icons.calendar_month),
                ),
              ),
            ),
            SizedBox(height: Dimensions.height20),

            // --- SWITCH (Reminder) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment Reminder',
                  style: TextStyle(
                    fontSize: Dimensions.font15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                Switch(
                  value: reminder,
                  onChanged: (value) {
                    setState(() {
                      reminder = value;
                    });
                  },
                  activeTrackColor: AppColors.primary5,
                  activeColor: AppColors.primary4,
                  inactiveThumbColor: AppColors.white,
                  inactiveTrackColor: AppColors.grey2,
                ),
              ],
            ),

            const Spacer(),

            // --- CHECKBOX (Consent) ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: sendConsent,
                    activeColor: AppColors.primary5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    onChanged: (value) {
                      setState(() {
                        sendConsent = value!;
                      });
                    },
                  ),
                ),
                SizedBox(width: Dimensions.width10),
                Expanded(
                  child: Text(
                    'Email the client a consent form to approve or waive the 24-hour color patch test.',
                    style: TextStyle(
                      fontSize: Dimensions.font13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // --- SUBMIT BUTTON ---
            Obx(() => CustomButton(
              text: controller.isLoading.value ? 'Creating...' : 'Next',
              onPressed: controller.isLoading.value ? () {} : _submitFolder,
              backgroundColor: AppColors.primary4,
            )),

            SizedBox(height: Dimensions.height50),
          ],
        ),
      ),
    );
  }
}