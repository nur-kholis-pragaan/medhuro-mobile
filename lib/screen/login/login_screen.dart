import 'package:flutter/material.dart';
import 'package:medhuro_mobile/config/pallet_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/api/auth_api.dart';
import '/widget/form_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool loginLoader = false;

  @override
  void initState() {
    super.initState();
    emailController.text = 'salesman1@email.com';
    passwordController.text = '123456';
  }

  void login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loginLoader = true;
      });

      final response = await AuthApi().login(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        loginLoader = false;
      });

      if (response == null) {
        _showErrorDialog('Error', 'Gagal terhubung ke server');
        return;
      }

      if (response.success && response.code == 200) {
        // Simpan token dan data user ke SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.token ?? '');
        await prefs.setInt('userId', response.data?.id ?? 0);
        await prefs.setString('userName', response.data?.name ?? '');
        await prefs.setString('userEmail', response.data?.email ?? '');

        if (mounted) {
          // Navigate to home screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (Route<dynamic> route) => false,
          );
        }
      } else {
        _showErrorDialog('Login Gagal', response.message);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 64),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.app_registration,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Medhuro Mobile',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Selamat datang kembali',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),
            Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  FormWidget().textFormField(
                    controller: emailController,
                    label: 'Email',
                    type: TextInputType.emailAddress,
                    icon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!value.contains('@')) {
                        return 'Email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FormWidget().textFormField(
                    controller: passwordController,
                    label: 'Password',
                    type: TextInputType.visiblePassword,
                    icon: Icons.vpn_key,
                    obscureText: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            FormWidget().button(
              icon: Icons.lock_open,
              label: 'Login',
              callBack: login,
              showLoader: loginLoader,
              backgroundColor: PalletConfig.primaryColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
