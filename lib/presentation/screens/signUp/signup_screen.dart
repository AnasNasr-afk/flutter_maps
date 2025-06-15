import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_cubit.dart';
import 'package:flutter_maps/presentation/screens/signUp/signupCubit/signup_states.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';

import '../../../helpers/text_styles.dart';
import '../../../router/routes.dart';
import '../../widgets/app_text_button.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 40, vertical: 100),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Sign up ',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    const SizedBox(height: 50),
                    AppTextFormField(
                      controller: cubit.nameController,
                      hintText: 'Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a valid Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextFormField(
                      controller: cubit.emailController,
                      hintText: 'Email',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextFormField(
                      controller: cubit.passwordController,
                      hintText: 'Password',
                      isObscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter a valid password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    // Show button or loading indicator depending on state
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.blue)
                        : AppTextButton(
                      onPressed: () {
                        if (cubit.formKey.currentState!.validate()) {
                          cubit.userSignup();
                        }
                      },
                      buttonStyle: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.blue),
                        shape: WidgetStatePropertyAll(
                          ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        minimumSize: WidgetStatePropertyAll(Size(340, 50)),
                      ),
                      text: const Text(
                        'Sign up',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        const Text('Already have an account? '),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, Routes.loginScreen);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
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
        );
      },
    );
  }
}
