import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_swatcher/utils/colors.dart';
import 'package:smart_swatcher/utils/dimensions.dart';
import 'package:smart_swatcher/widgets/custom_appbar.dart';
import 'package:smart_swatcher/widgets/custom_button.dart';

import '../../controllers/folder_controller.dart';
import '../../widgets/custom_textfield.dart';

class CreateFolderScreen extends StatefulWidget {
  const CreateFolderScreen({super.key});

  @override
  State<CreateFolderScreen> createState() => _CreateFolderScreenState();
}

class _CreateFolderScreenState extends State<CreateFolderScreen> {
  final ClientFolderController controller = Get.find<ClientFolderController>();

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
  Future<void> _submitFolder() async {
    // Helper to format for Backend: YYYY-MM-DD
    String? apiDob = selectedDob != null
        ? DateFormat('yyyy-MM-dd').format(selectedDob!)
        : null;

    String? apiAppointment = selectedAppointmentDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedAppointmentDate!)
        : null;

    final success = await controller.createClientFolder(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      dob: apiDob,
      appointmentDate: apiAppointment,
      setReminder: reminder,
      shouldSendConsent: sendConsent,
    );

    if (success && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppbar(
        leadingIcon: const BackButton(),
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                Dimensions.width20,
                Dimensions.height20,
                Dimensions.width20,
                viewInsets.bottom + Dimensions.height20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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

                      GestureDetector(
                        onTap: () => _showDatePicker(context, isDob: true),
                        child: AbsorbPointer(
                          child: CustomTextField(
                            controller: dobController,
                            labelText: 'Date of birth',
                            hintText: 'Select Date',
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Dimensions.height20),
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

                      _CheckboxTile(
                        value: reminder,
                        label: 'Send appointment details to customer',
                        onChanged: (value) {
                          setState(() {
                            reminder = value;
                          });
                        },
                      ),
                      SizedBox(height: Dimensions.height12),
                      _CheckboxTile(
                        value: sendConsent,
                        label: 'Send consent form',
                        onChanged: (value) {
                          setState(() {
                            sendConsent = value;
                          });
                        },
                      ),

                      const Spacer(),
                      SizedBox(height: Dimensions.height20),
                      Obx(
                        () => CustomButton(
                          text:
                              controller.isLoading.value
                                  ? 'Creating...'
                                  : 'Next',
                          onPressed:
                              controller.isLoading.value ? () {} : _submitFolder,
                          backgroundColor: AppColors.primary4,
                        ),
                      ),
                      SizedBox(height: Dimensions.height30),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CheckboxTile extends StatelessWidget {
  const _CheckboxTile({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radius12),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.height5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                activeColor: AppColors.primary5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: (nextValue) => onChanged(nextValue ?? false),
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: Dimensions.height5),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
