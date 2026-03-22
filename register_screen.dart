import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future register() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty) {
      showError("fill_all_fields".tr());
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showError("passwords_not_match".tr());
      return;
    }

    if (passwordController.text.length < 8) {
      showError("password_too_short".tr());
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "something_went_wrong".tr();
      if (e.code == 'email-already-in-use') {
        message = "email_already_in_use".tr();
      } else if (e.code == 'invalid-email') {
        message = "invalid_email".tr();
      } else if (e.code == 'weak-password') {
        message = "weak_password".tr();
      }
      showError(message);
    } catch (e) {
      showError("cannot_connect".tr());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  void changeLanguage() {
    if (context.locale == const Locale('en')) {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEn = context.locale == const Locale('en');

    return Scaffold(
      backgroundColor: const Color(0xff121312),
      appBar: AppBar(
        backgroundColor: const Color(0xff121312),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("register".tr(), style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/images/avatar1.png"),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage("assets/images/avatar2.png"),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage("assets/images/avatar3.png"),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text("avatar".tr(), style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 30),

              buildField(Icons.person, "name".tr(), nameController),
              const SizedBox(height: 15),
              buildField(
                Icons.email,
                "email".tr(),
                emailController,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              buildPasswordField("password".tr(), passwordController, obscure1, () {
                setState(() => obscure1 = !obscure1);
              }),
              const SizedBox(height: 15),

              buildPasswordField(
                "confirm_password".tr(),
                confirmPasswordController,
                obscure2,
                () {
                  setState(() => obscure2 = !obscure2);
                },
              ),
              const SizedBox(height: 15),

              buildField(
                Icons.phone,
                "phone_number".tr(),
                phoneController,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffFFB83B),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: isLoading ? null : register,
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
                          "create_account".tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "already_have_account".tr(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "login".tr(),
                      style: const TextStyle(color: Color(0xffFFB83B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: changeLanguage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffFFB83B)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        isEn ? "assets/images/EN.png" : "assets/images/EG.png",
                        height: 25,
                        errorBuilder: (c, e, s) =>
                            const Icon(Icons.flag, color: Colors.white),
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

  Widget buildField(
    IconData icon,
    String text,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xff282A28),
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: text,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildPasswordField(
    String text,
    TextEditingController controller,
    bool obscure,
    VoidCallback press,
  ) {
    return TextField(
      controller: controller,
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
          onPressed: press,
        ),
        hintText: text,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
