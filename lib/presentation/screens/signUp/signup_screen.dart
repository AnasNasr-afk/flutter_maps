import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/helpers/color_manager.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_cubit.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_states.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../helpers/app_regex.dart';
import '../../../helpers/text_styles.dart';
import '../../../router/routes.dart';
import '../../widgets/app_text_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isObscured = false;

  // Password validation states
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;

  // Method to validate password and update states
  void _validatePassword(String password) {
    setState(() {
      hasMinLength = AppRegex.hasMinLength(password);
      hasUppercase = AppRegex.hasUpperCase(password);
      hasLowercase = AppRegex.hasLowerCase(password);
      hasNumber = AppRegex.hasNumber(password);
      hasSpecialChar = AppRegex.hasSpecialCharacter(password);
    });
  }

  @override
  Widget build(BuildContext context) {
    var cubit = SignupCubit.get(context);

    return BlocConsumer<SignupCubit, SignupStates>(
      listener: (context, state) {
        if (state is SignupSuccessState) {
          Navigator.pushReplacementNamed(context, Routes.loginScreen);
        } else if (state is SignupErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage ?? 'Error signing up',
                style: TextStyles.font16WhiteRegular,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SignupLoadingState;

        return Scaffold(
          backgroundColor: ColorManager.lightTeal,
          body: Form(
            key: cubit.formKey,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Please fill in the details to sign up.',
                        style: TextStyles.font14GreyRegular,
                      ),
                      SizedBox(height: 32.h),
                      AppTextFormField(
                        controller: cubit.nameController,
                        hintText: 'Full Name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      AppTextFormField(
                        controller: cubit.emailController,
                        hintText: 'Email Address',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      AppTextFormField(
                        maxLines: 1,
                        hintText: 'Password',
                        validator: (value) {
                          if (value == null || value.isEmpty || !AppRegex.isPasswordValid(value)) {
                            return 'Enter a valid password';
                          }
                          return null;
                        },
                        inputTextStyle: TextStyles.font15BlackRegular,
                        controller: cubit.passwordController,
                        backgroundColor: Colors.white,
                        onChanged: (value) {
                          _validatePassword(value);
                        },
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isObscured = !isObscured;
                            });
                          },
                          child: Icon(
                            isObscured ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        isObscureText: isObscured,
                        onFieldSubmitted: (value){
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.userSignup();
                          }
                        },
                      ),
                      SizedBox(height: 8.h),
                      // Dynamic password requirements
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password must contain:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            _buildPasswordRequirement(
                                'At least 8 characters',
                                hasMinLength
                            ),
                            _buildPasswordRequirement(
                                'One uppercase letter (A-Z)',
                                hasUppercase
                            ),
                            _buildPasswordRequirement(
                                'One lowercase letter (a-z)',
                                hasLowercase
                            ),
                            _buildPasswordRequirement(
                                'One number (0-9)',
                                hasNumber
                            ),
                            _buildPasswordRequirement(
                                'One special character (@\$!%*?&)',
                                hasSpecialChar
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                          : AppTextButton(
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.userSignup();
                          }
                        },
                        buttonStyle: ButtonStyle(
                          backgroundColor: const WidgetStatePropertyAll(Colors.blue),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12.r)),
                            ),
                          ),
                          minimumSize: WidgetStatePropertyAll(Size(double.infinity.w, 50.h)),
                        ),
                        text: Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, Routes.loginScreen);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build password requirement with dynamic styling
  Widget _buildPasswordRequirement(String text, bool isValid) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14.sp,
            color: isValid ? Colors.green : Colors.grey[400],
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: isValid ? Colors.green : Colors.grey[600],
                decoration: isValid ? TextDecoration.lineThrough : TextDecoration.none,
                decorationColor: Colors.green,
                decorationThickness: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}