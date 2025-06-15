import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_cubit.dart';
import 'package:flutter_maps/presentation/screens/login/loginCubit/login_states.dart';
import 'package:flutter_maps/presentation/widgets/app_text_button.dart';
import 'package:flutter_maps/presentation/widgets/app_text_form_field.dart';

import '../../../router/routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    var cubit = LoginCubit.get(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 40, vertical: 200),
          child: Form(
            key: cubit.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Welcome back ',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  AppTextFormField(
                    controller: cubit.emailController,
                    hintText: 'Email Address',
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
              
                  const SizedBox(
                    height: 40,
                  ),
                  AppTextFormField(
                    controller: cubit.passwordController,
                    hintText: 'Password',

                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: const Icon(Icons.visibility),
                    isObscureText: true,
                  ),
              
                  const SizedBox(height: 40,),
                  BlocConsumer<LoginCubit, LoginStates>(
                    listener: (context, state) {
                      if (state is LoginLoadingState) {

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.yellow,)),
                        );
                      }

                      if (state is LoginSuccessState) {
                        Navigator.pop(context); // remove the loading dialog
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(content: Text("Login Successful")),
                        // );
                        Navigator.pushReplacementNamed(context, Routes.mapScreen); // navigate to home or wherever
                      }

                      if (state is LoginErrorState) {
                        Navigator.pop(context); // remove the loading dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Login Failed. Please try again.")),
                        );
                      }
                    },
                    builder: (context, state) {
                      var cubit = LoginCubit.get(context);
                      return AppTextButton(
                        onPressed: () {
                          if (cubit.formKey.currentState!.validate()) {
                            cubit.userLogin(context);
                          }
                        },
                        buttonStyle: const ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(Colors.blue),
                          shape: WidgetStatePropertyAll(ContinuousRectangleBorder(
                              borderRadius: BorderRadiusGeometry.all(Radius.circular(20)))),
                          minimumSize: WidgetStatePropertyAll(Size(340, 50)),
                        ),
                        text: const Text(
                          'Login',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      );
                    },
                  ),


                  const SizedBox(height: 50,),
                   Row(
                     children: [
                       const Text('Don\'t have an account? '),
                       const Spacer(),
                       InkWell(
                         onTap: (){
                           Navigator.pushReplacementNamed(context, Routes.signUpScreen);
                         },
                         child: const Text('Sign Up' ,
                         style:TextStyle(
                             fontWeight: FontWeight.bold,
                           decoration: TextDecoration.underline
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
