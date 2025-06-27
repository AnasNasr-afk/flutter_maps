import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/userSecurityCubit/user_security_cubit.dart';
import 'package:flutter_maps/helpers/components.dart';
import 'package:flutter_maps/presentation/widgets/app_text_button.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../business_logic/userSecurityCubit/user_security_states.dart';
import '../../helpers/app_regex.dart';
import '../../helpers/text_styles.dart';
import '../../router/routes.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool isObscured = false;

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
              colors: [Colors.amber, Colors.orange],
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(
              horizontal: 20.w, vertical: 30.h),
          child: Form(
            key: cubit.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Password',
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                AppTextFormField(
                  maxLines: 1,
                  hintText: '........',
                  validator: (value) {
                    if (value == null || value.isEmpty ||
                        !AppRegex.isPasswordValid(value)) {
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
                  onFieldSubmitted: (value) {

                  },
                ),
                SizedBox(height: 20.h),
                Text(
                  'New Password',
                  style: TextStyle(
                      fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                AppTextFormField(
                  maxLines: 1,
                  hintText: '........',
                  validator: (value) {
                    if (value == null || value.isEmpty ||
                        !AppRegex.isPasswordValid(value)) {
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
                  onFieldSubmitted: (value) {

                  },
                ),
                SizedBox(height: 10.h),
                Text('Password must be and should include: \n'
                    'At least 8 characters.'
                    '\nAt least one uppercase letter.'
                    '\nAt least one lowercase letter.'
                    '\nAt least one number.'
                    '\nAt least one special character (!@#\$&*~)',
                  style: TextStyle(
                      fontSize: 10.sp, color: Colors.grey, height: 1.5.h
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Confirm Password',
                  style: TextStyle(
                      fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 10.h),
                AppTextFormField(
                  maxLines: 1,
                  hintText: '........',
                  validator: (value) {
                    if (value == null || value.isEmpty ||
                        !AppRegex.isPasswordValid(value)) {
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
                  onFieldSubmitted: (value) {

                  },
                ),
                SizedBox(height: 20.h),
                BlocConsumer<UserSecurityCubit, UserSecurityStates>(
                  listener: (context, state) {
                    if (state is ChangePasswordSuccessState) {
                      Navigator.pushReplacementNamed(context, Routes.loginScreen);
                    } else
                    if (state is ChangePasswordErrorState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ ${state.error}')),
                      );
                    }
                  },

                  builder: (context, state) {
                    final isLoading = state is ChangePasswordLoadingState;
                    return isLoading
                        ? const Center(
                        child: CircularProgressIndicator(color: Colors.amber))
                        : AppTextButton(
                      buttonStyle: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll(Colors
                            .black54),
                        minimumSize: WidgetStatePropertyAll(Size(
                            double.infinity, 50.h)),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context: context,
                          title: 'Change Password',
                          message: 'Are you sure you want to change your password?\nYou will be logged out.',
                        );

                        if (confirm == true) {
                          cubit.changePassword();
                        }

                      },

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
