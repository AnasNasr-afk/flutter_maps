import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_cubit.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_states.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';

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
          backgroundColor: Colors.white,
          body: Form(
            key: cubit.formKey,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please fill in the details to sign up.',
                        style: TextStyles.font14GreyRegular,
                      ),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 20),
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
                      const SizedBox(height: 32),
                      isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                          : AppTextButton(
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.userSignup();
                          }
                        },
                        buttonStyle: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.blue),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          minimumSize: WidgetStatePropertyAll(Size(double.infinity, 50)),
                        ),
                        text: const Text(
                          'Sign Up',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 32),
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
}
