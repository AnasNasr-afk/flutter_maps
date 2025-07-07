import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/issueCubit/issue_cubit.dart';
import 'package:flutter_maps/data/models/user_model.dart';
import 'package:flutter_maps/helpers/components.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../../../business_logic/issueCubit/issue_states.dart';
import '../../../helpers/color_manager.dart';

class ReportIssueBottomSheet extends StatefulWidget {
  const ReportIssueBottomSheet({super.key});

  @override
  State<ReportIssueBottomSheet> createState() => _ReportIssueBottomSheetState();
}

class _ReportIssueBottomSheetState extends State<ReportIssueBottomSheet> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  final int maxChars = 100;
  int charsLeft = 100;


  @override
  void initState() {
    super.initState();
    descriptionController.addListener(() {
      final text = descriptionController.text;
      if (text.length > maxChars) {
        descriptionController.value = TextEditingValue(
          text: text.substring(0, maxChars),
          selection: TextSelection.collapsed(offset: maxChars),
        );
      }
      setState(() {
        charsLeft = maxChars - descriptionController.text.length;
      });
    });



  }


  bool get isSubmitEnabled {
    final cubit = IssueCubit.get(context);
    return cubit.selectedCategory != null &&
        cubit.imageFile != null &&
        descriptionController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    var cubit = IssueCubit.get(context);

    final messenger = ScaffoldMessenger.of(context);

    return BlocListener<IssueCubit, IssueStates>(
      listener: (context, state) async {
        if (state is IssueSubmittingLoadingState) {
          showAppLoadingDialog(context);
        }
        else if (state is IssueSubmitSuccessState) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close loading dialog
          }
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => Dialog(
              elevation: 8,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 140.h,
                      width: 140.h,
                      child: Lottie.network(
                        'https://assets2.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                        repeat: false,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "All Set!",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      "Your report was submitted successfully.\nOur team will review it shortly.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 28.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Close bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: Colors.green.shade600,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          "Great!",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        else if (state is IssueSubmitFailureState) {
          if (Navigator.canPop(context)) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission failed')),
          );
        }
        else if (state is ImagePickerErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image picker error')),
          );
        }
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7.h,
        minChildSize: 0.3.h,
        maxChildSize: 0.8.h,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12.r,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 5.h,
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Report an Issue",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 0.3.w),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ColorManager.mainBlue, width: 0.4.w),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        labelText: 'Category',
                        labelStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 0.3.w),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: Colors.grey[800]),
                      value: cubit.selectedCategory,
                      items: cubit.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          cubit.selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: descriptionController,
                      builder: (context, value, _) {
                        final charCount = value.text.length;
                        final charsLeft = maxChars - charCount;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextFormField(
                              maxLength: maxChars, // Optional, shows counter inside field
                              maxLines: 2,
                              minLines: 2, // Fixed height for 2 lines
                              controller: descriptionController,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 0.3.w),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: ColorManager.mainBlue, width: 0.4.w),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              inputTextStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                              ),
                              hintText: 'Provide a short description of the problem',
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a description';
                                }
                                if (value.trim().length > maxChars) {
                                  return 'Please keep it under $maxChars characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Words left: ${charsLeft < 0 ? 0 : charsLeft}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: charsLeft < 0 ? Colors.red : Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    BlocBuilder<IssueCubit, IssueStates>(
                      builder: (context, state) {
                        final cubit = IssueCubit.get(context);
                        if (cubit.imageFile == null) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  showAdaptiveActionSheet(
                                    context: context,
                                    title:  Text(
                                        'Avoid uploading sensitive images' , style: TextStyle(
                                            fontSize: 12.sp)),
                                    actions: <BottomSheetAction>[
                                      BottomSheetAction(
                                        title: Text('Take a photo',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18.sp)),
                                        onPressed: (_) async {
                                          Navigator.pop(context);
                                          await cubit.imagePickerPhoto(
                                              ImageSource.camera);
                                          setState(() {});
                                        },
                                      ),
                                      BottomSheetAction(
                                        title: Text('Choose from gallery',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18.sp)),
                                        onPressed: (_) async {
                                          Navigator.pop(context);
                                          await cubit.imagePickerPhoto(
                                              ImageSource.gallery);
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                    cancelAction: CancelAction(
                                        title:  Text('Cancel' ,
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18.sp))),
                                  );
                                },
                                child: Container(
                                  height: 120.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    border: Border.all(
                                        color: Colors.grey, width: 0.3.w),
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.camera_alt_outlined,
                                            size: 60.sp, color: Colors.black),
                                        SizedBox(height: 5.h),
                                        Text(
                                          'Add Photo',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Center(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: InteractiveViewer(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                child: Image.file(
                                                  cubit.imageFile!,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        child: Image.file(
                                          cubit.imageFile!,
                                          fit: BoxFit.cover,
                                          width: 120.w,
                                          height: 120.h,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          cubit.clearImage();
                                          setState(() {});
                                        },
                                        child: CircleAvatar(
                                          radius: 14.r,
                                          backgroundColor: Colors.red,
                                          child: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.white,
                                              size: 16.sp),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20.h),
                            ],
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                    Column(
                      children: [
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!isSubmitEnabled) {
                                  return; // 🛑 Block click behavior
                                }

                                if (formKey.currentState?.validate() != true) {
                                  return;
                                }

                                await cubit.fetchCurrentLocation();
                                if (cubit.currentPosition == null) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to get location. Please enable location services.'),
                                    ),
                                  );
                                  return;
                                }

                                final firebaseUser =
                                    FirebaseAuth.instance.currentUser;
                                if (firebaseUser == null) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                        content: Text('User not logged in')),
                                  );
                                  return;
                                }

                                try {
                                  final userDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(firebaseUser.uid)
                                      .get();

                                  if (!userDoc.exists) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('User profile not found')),
                                    );
                                    return;
                                  }

                                  final userModel =
                                      UserModel.fromMap(userDoc.data()!);
                                  await cubit.submitIssue(
                                    context: context,
                                    description:
                                        descriptionController.text.trim(),
                                    currentUser: userModel,
                                  );
                                } catch (e) {
                                  debugPrint(
                                      '❌ Failed to fetch user profile: $e');
                                  messenger.showSnackBar(
                                      SnackBar(content: Text('Error: $e')));
                                }
                              },
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                    EdgeInsets.symmetric(vertical: 14.h)),
                                backgroundColor: WidgetStateProperty.all(
                                  isSubmitEnabled
                                      ? Colors.green
                                      : Colors.green[200],
                                ),
                                overlayColor: WidgetStateProperty.all(
                                  isSubmitEnabled ? null : Colors.transparent,
                                ),
                                mouseCursor: WidgetStateProperty.all(
                                  isSubmitEnabled
                                      ? SystemMouseCursors.click
                                      : SystemMouseCursors.basic,
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: Colors.white,
                                ),
                              ),
                            )),
                        SizedBox(height: 8.h),
                        Text(
                          'This report will include your current location',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
