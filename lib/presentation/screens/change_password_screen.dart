import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/userSecurityCubit/user_security_cubit.dart';
import 'package:flutter_maps/helpers/components.dart';
import 'package:flutter_maps/presentation/widgets/app_text_button.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../business_logic/userSecurityCubit/user_security_states.dart';
import '../../helpers/app_regex.dart';
import '../../helpers/color_manager.dart';
import '../../helpers/text_styles.dart';
import '../../router/routes.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isObscured = false;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();

    var cubit = UserSecurityCubit.get(context);

    cubit.currentPasswordController.addListener(_validateForm);
    cubit.newPasswordController.addListener(_validateForm);
    cubit.confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    var cubit = UserSecurityCubit.get(context);
    final current = cubit.currentPasswordController.text;
    final newPass = cubit.newPasswordController.text;
    final confirm = cubit.confirmPasswordController.text;

    final isValid = AppRegex.isPasswordValid(current) &&
        AppRegex.isPasswordValid(newPass) &&
        AppRegex.isPasswordValid(confirm) &&
        (newPass == confirm);

    if (isValid != isFormValid) {
      setState(() {
        isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var cubit = UserSecurityCubit.get(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ColorManager.gradientStart, ColorManager.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Change Password',
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Password',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                AppTextFormField(
                  maxLines: 1,
                  hintText: '........',
                  validator: (value) {
                    if (value == null || value.isEmpty || !AppRegex.isPasswordValid(value)) {
                      return 'Enter a valid password';
                    }
                    return null;
                  },
                  inputTextStyle: TextStyles.font15BlackRegular,
                  controller: cubit.currentPasswordController,
                  backgroundColor: Colors.white,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                    child: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  isObscureText: isObscured,
                ),
                SizedBox(height: 20.h),
                Text(
                  'New Password',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                AppTextFormField(
                  maxLines: 1,
                  hintText: '........',
                  validator: (value) {
                    if (value == null || value.isEmpty || !AppRegex.isPasswordValid(value)) {
                      return 'Enter a valid password';
                    }
                    return null;
                  },
                  inputTextStyle: TextStyles.font15BlackRegular,
                  controller: cubit.newPasswordController,
                  backgroundColor: Colors.white,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                    child: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  isObscureText: isObscured,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Password must be and should include: \n'
                      'At least 8 characters.'
                      '\nAt least one uppercase letter.'
                      '\nAt least one lowercase letter.'
                      '\nAt least one number.'
                      '\nAt least one special character (!@#\$&*~)',
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey, height: 1.5.h),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Confirm Password',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                AppTextFormField(
                  maxLines: 1,
                  hintText: '........',
                  validator: (value) {
                    if (value == null || value.isEmpty || !AppRegex.isPasswordValid(value)) {
                      return 'Enter a valid password';
                    }
                    return null;
                  },
                  inputTextStyle: TextStyles.font15BlackRegular,
                  controller: cubit.confirmPasswordController,
                  backgroundColor: Colors.white,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                    child: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                  isObscureText: isObscured,
                ),
                SizedBox(height: 20.h),
                BlocConsumer<UserSecurityCubit, UserSecurityStates>(
                  listener: (context, state) {
                    if (state is ChangePasswordSuccessState) {
                      Navigator.pushReplacementNamed(context, Routes.loginScreen);
                    } else if (state is ChangePasswordErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ ${state.error}')),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is ChangePasswordLoadingState;
                    return isLoading
                        ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                        : AppTextButton(
                      buttonStyle: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                              (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Colors.black54;
                            }
                            return Colors.green;
                          },
                        ),
                        minimumSize: WidgetStateProperty.all(Size(double.infinity, 50.h)),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                      onPressed: isFormValid
                          ? () {
                        showConfirmDialog(
                          context: context,
                          title: 'Change Password',
                          message:
                          'Are you sure you want to change your password?\nYou will be logged out.',
                        ).then((confirm) {
                          if (confirm == true) {
                            cubit.changePassword();
                          }
                        });
                      }
                          : () {},  // empty function, but then button is enabled, just no-op

                      text: Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );

                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
