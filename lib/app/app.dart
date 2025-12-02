import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import "../screens/home_screen.dart";
import '../screens/login_screen.dart';
import "../screens/register_screen.dart";
import "../screens/forgot_password_screen.dart";

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Auth',
        theme: ThemeData(
          primaryColor: const Color(0xFF5669FF),
          scaffoldBackgroundColor: const Color(0xFFF7FAFC),
          fontFamily: 'Poppins',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5669FF),
            primary: const Color(0xFF5669FF),
          ),
        ),
        initialRoute: "/login",
        routes: {
          "/login": (context) => const LoginScreen(),
          "/register": (context) => const RegisterScreen(),
          "/home": (context) => const HomeScreen(),
          "/forgot-password": (context) => const ForgotPasswordScreen(),
        },
      ),
    );
  }
}
