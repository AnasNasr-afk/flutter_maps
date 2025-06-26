import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/issueCubit/issue_cubit.dart';
import 'package:flutter_maps/data/models/user_model.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../business_logic/issueCubit/issue_states.dart';
import '../../helpers/color_manager.dart';
import '../../helpers/text_styles.dart';

class ReportIssueBottomSheet extends StatefulWidget {
  const ReportIssueBottomSheet({super.key});

  @override
  State<ReportIssueBottomSheet> createState() => _ReportIssueBottomSheetState();
}

class _ReportIssueBottomSheetState extends State<ReportIssueBottomSheet> {
  bool hasPickedImage = false;
  final formKey = GlobalKey<FormState>();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = IssueCubit.get(context);
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);

    return BlocListener<IssueCubit, IssueStates>(
      listener: (context, state) async {
        if (state is IssueSubmittingState) {
          // Show loading dialog while submitting
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        } else if (state is IssueSubmitSuccessState) {
          // Remove loading dialog if showing
          if (Navigator.canPop(context)) Navigator.pop(context);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Issue submitted successfully!')),
          );

          // Close bottom sheet
          if (mounted) {
            Navigator.of(context).pop();
          }
        } else if (state is IssueSubmitFailureState) {
          // Remove loading dialog if showing
          if (Navigator.canPop(context)) Navigator.pop(context);

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission failed')),
          );
        } else if (state is ImagePickerErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image picker error')),
          );
        }
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration:  BoxDecoration(
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
                controller: scrollController,
                padding:  EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 5.h,
                        margin:  EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Report an Issue",
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:  BorderSide(
                            color: Colors.grey,
                            width: 1.3.w,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:  BorderSide(
                            color: Colors.red,
                            width: 1.3.w,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: ColorManager.mainBlue,
                            width: 1.3.w,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        hintText: 'Select Category',
                        labelText: 'Category',
                        labelStyle: TextStyles.font16GreyMedium,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.3.w,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: cubit.selectedCategory,
                      items: cubit.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
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
                    SizedBox(height: 16.h),
                    AppTextFormField(
                      controller: descriptionController,
                      hintText: 'Describe the issue',
                      maxLines: null,
                      minLines: 4,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              "Using current location automatically",
                              style:
                                  TextStyle(fontSize: 16.sp, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (cubit.imageFile == null)
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.photo,
                                color: Colors.cyan,
                              ),
                              label: const Text(
                                'Gallery',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.white)),
                              onPressed: () async {
                                await cubit
                                    .imagePickerPhoto(ImageSource.gallery);
                                setState(() {
                                  hasPickedImage = true;
                                });
                              },
                            ),
                            SizedBox(width: 16.w),
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.cyan,
                              ),
                              label: const Text(
                                'Camera',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                await cubit
                                    .imagePickerPhoto(ImageSource.camera);
                                setState(() {
                                  hasPickedImage = true;
                                });
                              },
                              style: const ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16.h),
                    BlocBuilder<IssueCubit, IssueStates>(
                      builder: (context, state) {
                        final cubit = IssueCubit.get(context);

                        if (state is ImagePickerLoadingState) {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: Colors.amber,
                          ));
                        }

                        if (cubit.imageFile != null) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Image.file(
                                  cubit.imageFile!,
                                  width: 300.w,
                                  height: 300.h,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await cubit.imagePickerPhoto(
                                          ImageSource.gallery);
                                      setState(() {
                                        hasPickedImage = true;
                                      });
                                    },
                                    style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.white)),
                                    child: const Text(
                                      'Try Again',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await cubit.cropImage(
                                          context, cubit.imageFile!);
                                    },
                                    style: const ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.white)),
                                    child: const Text(
                                      'Crop',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        cubit.imageFile = null;
                                        hasPickedImage = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          );
                        } else {
                          return hasPickedImage
                              ? const Center(
                                  child: Text('No image selected yet'))
                              : const SizedBox.shrink();
                        }
                      },
                    ),
                    SizedBox(height: 30.h),
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState?.validate() != true) return;

                          await cubit.fetchCurrentLocation();

                          if (cubit.currentPosition == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Failed to get location. Please enable location services.')),
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
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(firebaseUser.uid)
                                .get();

                            if (!userDoc.exists) {
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text('User profile not found')),
                              );

                              return;
                            }

                            final userModel =
                                UserModel.fromMap(userDoc.data()!);

                            await cubit.submitIssue(
                              context: context,
                              description: descriptionController.text.trim(),
                              currentUser: userModel,
                            );
                          } catch (e) {
                            debugPrint('❌ Failed to fetch user profile: $e');
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Submit",
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
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
