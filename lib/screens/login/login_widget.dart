import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pfaa/prof/DashboardProf.dart';
import 'package:pfaa/student/DashboardStudent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../admin/DashboardAdmin.dart';
import '../../nodejs/rest_api.dart';
import 'package:pfaa/screens/ChangePassword.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> with TickerProviderStateMixin {
  late LoginModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences _sharedPreferences;

  LoginModel createModel(BuildContext context, LoginModel Function() modelCreator) {
    return modelCreator();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());
    _model.emailAddressController = TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordController = TextEditingController();
    _model.passwordFocusNode ??= FocusNode();
    _model.passwordVisibility = false;
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.black,
              ],
              stops: [0.0, 1.0],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.lightBlue.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo2.jpeg',
                          width: 150,
                          height: 150,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Connexion',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _model.emailAddressController,
                          focusNode: _model.emailAddressFocusNode,
                          autofocus: true,
                          autofillHints: [AutofillHints.email],
                          obscureText: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              fontFamily: 'Tahoma',
                              color: Colors.blueGrey.shade500,
                              letterSpacing: 0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white30,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                          minLines: null,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _model.passwordController,
                          focusNode: _model.passwordFocusNode,
                          autofocus: true,
                          autofillHints: [AutofillHints.password],
                          obscureText: !_model.passwordVisibility,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.blueGrey.shade500,
                              fontFamily: 'Tahoma',
                              letterSpacing: 0,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.white30,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueGrey.shade500,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white30,
                            suffixIcon: InkWell(
                              onTap: () =>
                                  setState(() =>
                                  _model.passwordVisibility =
                                  !_model.passwordVisibility),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                _model.passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.blueGrey.shade500,
                                size: 24,
                              ),
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Readex Pro',
                            letterSpacing: 0,
                          ),
                          minLines: null,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            if (_model.emailAddressController.text.isNotEmpty &&
                                _model.passwordController.text.isNotEmpty) {
                              await doLogin(
                                  _model.emailAddressController.text,
                                  _model.passwordController.text);
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'All fields are required',
                                  textColor: Colors.red);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color.fromARGB(255, 108, 169, 200),
                            padding: EdgeInsets.zero,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            alignment: Alignment.center,
                            child: const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontFamily: 'Readex Pro',
                                color: Colors.white,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  doLogin(String email, String password) async {
    _sharedPreferences = await SharedPreferences.getInstance();

    // Vérifier si l'utilisateur est un étudiant
    var res = await userLogin(email.trim(), password.trim());
    print(res.toString());
    if (res['success']) {
      String userRole = res['user'][0]['role'];
      if (userRole == "student") {
        int lastLoginAttempt = _sharedPreferences.getInt('lastLoginAttempt') ?? 0;
        int currentTime = DateTime.now().millisecondsSinceEpoch;

        if (currentTime - lastLoginAttempt < 10 * 60 * 1000) {
          Fluttertoast.showToast(
              msg: 'Please wait 10 minutes before trying again.',
              textColor: Colors.red);
          return;
        }

        _sharedPreferences.setInt('lastLoginAttempt', currentTime);
      }

      String userEmail = res['user'][0]['email'];
      String userName = res['user'][0]['nom'];
      int userId = res['user'][0]['id'];
      bool firstLogin = res['user'][0]['first_login'] == 1;

      _sharedPreferences.setInt('userid', userId);
      _sharedPreferences.setString('usermail', userEmail);
      _sharedPreferences.setString('username', userName);
      _sharedPreferences.setBool('first_login', firstLogin);

      if (firstLogin) {
        Route route = MaterialPageRoute(
            builder: (_) => ChangePassword(user: res['user'][0]));
        Navigator.pushReplacement(context, route);
      } else {
        if (res['user'][0]['role'] == "admin") {
          Route route = MaterialPageRoute(
              builder: (_) => DashboardAdmin(user: res['user'][0]));
          Navigator.pushReplacement(context, route);
        } else if (res['user'][0]['role'] == "prof") {
          Route route = MaterialPageRoute(
              builder: (_) => DashboardProf(user: res['user'][0]));
          Navigator.pushReplacement(context, route);
        } else if (res['user'][0]['role'] == "student") {
          Route route = MaterialPageRoute(
              builder: (_) => DashboardStudent(user: res['user'][0]));
          Navigator.pushReplacement(context, route);
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Email and password not valid!', textColor: Colors.red);
    }
  }
}
