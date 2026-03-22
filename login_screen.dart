import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:movie_app/screens/auth/forgot_password.dart';
import 'package:movie_app/widgets/main_layout.dart';

import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;
  bool isLoading = false;

  final auth = FirebaseAuth.instance;

  Future login() async {
    FocusScope.of(context).unfocus();

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("enter_email_password".tr())),
      );

      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainLayout()),
      );

    }
    on FirebaseAuthException catch (e) {
      String message = "login_failed".tr();

      if (e.code == 'user-not-found') {
        message = "no_user_found".tr();
      }

      if (e.code == 'wrong-password') {
        message = "wrong_password".tr();
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("something_went_wrong".tr())));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {

      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();


      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: null,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainLayout()),
      );
    } catch (e) {
      debugPrint("Google Sign-In Error: ${e.toString()}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void changeLanguage() {
    if (context.locale == const Locale('en')) {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  }

  @override
  void initState() {
    super.initState();

    GoogleSignIn.instance.initialize();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = context.locale == const Locale('en');

    return Scaffold(
      backgroundColor: const Color(0xff121312),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),

          child: Column(
            children: [
              const SizedBox(height: 90),

              Image.asset("assets/images/login.png", height: 90),

              const SizedBox(height: 50),

              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xff282A28),

                  prefixIcon: const Icon(Icons.email, color: Colors.white),

                  hintText: "email".tr(),
                  hintStyle: const TextStyle(color: Colors.grey),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: obscure,
                style: const TextStyle(color: Colors.white),

                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xff282A28),

                  prefixIcon: const Icon(Icons.lock, color: Colors.white),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),

                  hintText: "password".tr(),
                  hintStyle: const TextStyle(color: Colors.grey),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: isEn ? Alignment.centerRight : Alignment.centerLeft,

                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgetPasswordScreen(),
                      ),
                    );
                  },

                  child: Text(
                    "forget_password".tr(),
                    style: const TextStyle(color: Color(0xffFFB83B)),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFB83B),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),

                  onPressed: isLoading ? null : login,

                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "login".tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFB83B),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),

                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },

                  child: Text(
                    "create_account".tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0xffFFB83B), thickness: 1),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "or".tr(),
                      style: const TextStyle(color: Color(0xffFFB83B)),
                    ),
                  ),

                  const Expanded(
                    child: Divider(color: Color(0xffFFB83B), thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFB83B),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),

                  onPressed: signInWithGoogle,

                  icon: Image.asset("assets/images/Google.png", height: 25),

                  label: Text(
                    "login_with_google".tr(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: changeLanguage,

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffFFB83B)),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        isEn
                            ? "assets/images/EN.png"
                            : "assets/images/EG.png",
                        height: 25,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        isEn ? "English" : "العربية",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
