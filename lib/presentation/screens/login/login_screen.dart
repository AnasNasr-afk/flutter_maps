import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/helpers/components.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_cubit.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_states.dart';
import 'package:flutter_maps/presentation/widgets/app_text_button.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../helpers/app_regex.dart';
import '../../../helpers/text_styles.dart';
import '../../../router/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isObscured = false;

  @override
  Widget build(BuildContext context) {
    var cubit = LoginCubit.get(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: cubit.formKey,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Please login to continue',
                    style: TextStyles.font14GreyRegular,
                  ),
                  SizedBox(height: 32.h),
                  AppTextFormField(
                    controller: cubit.emailController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email Address',
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  AppTextFormField(
                    maxLines: 1,
                    hintText: 'Enter your password',
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty || !AppRegex.isPasswordValid(value)) {
                        return 'Enter a valid password';
                      }
                      return null;
                    },
                    inputTextStyle: TextStyles.font15BlackRegular,
                    controller: cubit.passwordController,
                    backgroundColor: Colors.white,
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
                      if(LoginCubit.get(context).formKey.currentState!.validate()) {
                        cubit.userLogin(context);
                      }
                    },
                  ),
                  SizedBox(height: 32.h),
                  BlocConsumer<LoginCubit, LoginStates>(
                    listener: (context, state) {
                      if (state is LoginLoadingState) {
                       showAppLoadingDialog(context);
                      }

                      if (state is LoginSuccessState) {
                        Navigator.pop(context); // close loading dialog
                        Navigator.pushReplacementNamed(context, Routes.mapScreen);
                      }

                      if (state is LoginErrorState) {
                        Navigator.pop(context); // close loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Login failed. Please try again."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return AppTextButton(
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.userLogin(context);
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
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 18.sp),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, Routes.signUpScreen);
                        },
                        child: const Text(
                          'Sign Up',
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
  }
}
