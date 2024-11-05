import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/home/home_screen.dart';

import './mock_users.dart';
import './services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 2250);

  Future<String?> _loginUser(LoginData data) async {
    AuthService authService = AuthService();
    bool success = await authService.login(data.name, data.password);
    if (!success) {
      return "Invalid username or password";
    }
    return null;
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      debugPrint('Signup button pressed');
      debugPrint(
          'Signup info at client: ${data.name} ${data.email} ${data.password}');

      String? email = data.email;
      if (data.name == null || email == null || data.password == null) {
        return "All fields are required";
      }

      AuthService authService = AuthService();
      bool success =
          await authService.register(data.name!, email, data.password!);
      if (!success) {
        return "Registration failed";
      }

      // Registration successful, navigate back to login screen
      debugPrint("Registration successful. Please log in.");
      return null; // Return null to indicate no error
    } catch (e) {
      debugPrint('Error during signup: $e');
      return "An error occurred during registration";
    }
  }

  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      if (!mockUsers.containsKey(name)) {
        return "User doesn't exists";
      }
      return null;
    });
  }

  Future<String?> _signupConfirm(String error, LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'Training Tracker',
      //logo:
      //logoTag:
      //titleTag:
      //navigateBackAfterRecovery:
      //onConfirmRecover:
      //onConfrimSignup:
      //loginAfterSignup: false,
      loginProviders: [
        LoginProvider(
          icon: FontAwesomeIcons.google,
          label: 'Google',
          callback: () async {
            return null;
          },
        ),
        LoginProvider(
            icon: FontAwesomeIcons.facebook,
            label: 'Facebook',
            callback: () async {
              return null;
            }),
      ],
      //termsOfService: [],
      additionalSignupFields: [
        const UserFormField(
          keyName: 'username',
          displayName: 'Username',
          icon: Icon(FontAwesomeIcons.userLarge),
        ),
      ],
      /*
      userValidator: (value) {
        if (!value!.contains('@')) {
          return "Email must contain '@'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value!.isEmpty) {
          return 'Password is empty';
        }

        // TODO: how to validate password length on signup only
        /*if (value.length < 5) {
          return 'Password should be longer that 4 characters';
        }*/
        return null;
      },
      */
      onLogin: (loginData) {
        debugPrint('Login info');
        debugPrint('Email ${loginData.name}');
        debugPrint('Password ${loginData.password}');
        return _loginUser(loginData);
      },
      onSignup: (signupData) {
        debugPrint('Signup info');
        debugPrint('Name ${signupData.name}');
        debugPrint('Password ${signupData.password}');

        signupData.additionalSignupData?.forEach((key, value) {
          debugPrint('$key: $value');
        });

        String? username = signupData.additionalSignupData?['username'];
        String? email = signupData.name;

        if (email == null) {
          return Future.value("Email is required");
        }

        return _signupUser(SignupData.fromSignupForm(
          name: username,
          additionalSignupData: {'email': email},
          password: signupData.password,
        ));
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => TrainingTracker(),
        ));
      },
      onRecoverPassword: (name) {
        debugPrint('Recover password info');
        debugPrint('Name $name');
        return _recoverPassword(name);
      },
      headerWidget: const IntroWidget(),
    );
  }
}

extension SignupDataExtension on SignupData {
  String? get email => additionalSignupData?['email'];
}

class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Text("Login"),
            ),
            Expanded(child: Divider()),
          ],
        ),
      ],
    );
  }
}
