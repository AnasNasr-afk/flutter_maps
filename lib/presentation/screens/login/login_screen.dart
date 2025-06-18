import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_cubit.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_states.dart';
import 'package:flutter_maps/presentation/widgets/app_text_button.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please login to continue',
                    style: TextStyles.font14GreyRegular,
                  ),
                  const SizedBox(height: 32),
                  AppTextFormField(
                    controller: cubit.emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email Address',
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppTextFormField(
                    maxLines: 1,
                    hintText: 'Enter your password',
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
                  const SizedBox(height: 32),
                  BlocConsumer<LoginCubit, LoginStates>(
                    listener: (context, state) {
                      if (state is LoginLoadingState) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(
                            child: CircularProgressIndicator(color: Colors.blue),
                          ),
                        );
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
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
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
