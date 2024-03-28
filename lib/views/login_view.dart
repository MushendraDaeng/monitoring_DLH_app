import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:truck_monitoring_apps/controller/driver_controller.dart';
import 'package:truck_monitoring_apps/utils/style.dart';

import '../config/route.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  AppStyle style = AppStyle();
  final txtUid = TextEditingController();
  final txtPwd = TextEditingController();
  var isObscured = true.obs;
  final _formKey = GlobalKey<FormBuilderState>();
  final _driverController = DriverController();
  late Size screen;

  void checkIfLogin() async {
    var isLogged = await _driverController.checkIfLogin(context);
    if (isLogged) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RouteName.dashboardPage);
      }
    }
  }

  void tryLogin() async {
    var isLogged = await _driverController.login(context, txtUid.text, txtPwd.text);
    if (isLogged) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RouteName.dashboardPage);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLogin();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: style.backgroundColor,
      body: SafeArea(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 25,
              ),
              Container(
                width: screen.width,
                alignment: Alignment.center,
                margin: const EdgeInsets.all(5),
                child: Image.asset(
                  "assets/truck.png",
                  fit: BoxFit.contain,
                  width: screen.width * .35,
                  // height: 80,
                ),
              ),
              Container(
                width: screen.width,
                padding: const EdgeInsets.all(5),
                alignment: Alignment.center,
                child: Text("Truck Monitoring\nSystem", style: style.typography(size: 28, color: style.primaryColor, bold: true), textAlign: TextAlign.center),
              ),
              Container(
                width: screen.width,
                padding: const EdgeInsets.all(10),
                child: FormBuilderTextField(
                  name: "uid",
                  controller: txtUid,
                  validator: (value) {
                    if (value == "") {
                      return "User Id can be empty!";
                    }
                  },
                  style: style.typography(size: style.textH6, color: style.secondaryColor, bold: true),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: style.secondaryColor, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: style.accentColor, width: 2)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: style.secondaryColor, width: 2)),
                      prefixIcon: Icon(
                        Icons.account_circle,
                        color: style.accentColor,
                      )),
                ),
              ),
              Container(
                  width: screen.width,
                  padding: const EdgeInsets.all(10),
                  child: Obx(
                    () => FormBuilderTextField(
                      name: "pwd",
                      controller: txtPwd,
                      validator: (value) {
                        if (value == "") {
                          return "Password can be empty!";
                        }
                      },
                      obscureText: isObscured.value,
                      style: style.typography(size: style.textH6, color: style.secondaryColor, bold: true),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: style.secondaryColor, width: 2)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: style.accentColor, width: 2)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: style.secondaryColor, width: 2)),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: style.accentColor,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              isObscured.value = !isObscured.value;
                            },
                            icon: Icon(
                              isObscured.value ? Icons.visibility_off : Icons.visibility,
                              color: style.accentColor,
                            ),
                          )),
                    ),
                  )),
              Container(
                width: screen.width,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    if (await confirmTracking()) {
                      tryLogin();
                    }
                  },
                  style: style.defaultButton(),
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: Text("Login", style: style.typography(size: style.textH6, useDefaultColor: true, bold: true)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> confirmTracking() async {
    bool confirmed = await showDialog<bool>(
        context: context,
        barrierColor: const Color.fromARGB(255, 255, 255, 255),
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Background Location Confirmation", style: style.typography(size: style.textH6, bold: true, color: style.darkColor)),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Aplikasi akan mengumpulkan data lokasi anda, walaupun aplikasi ini di tutup, statusnya akan terlihat pada panel notifikasi.",
                  style: style.typography(size: style.textDesc, color: style.primaryColor, bold: true),
                ),
                Text("Data lokasi di gunakan untuk memonitoring kinerja anda dalam melakukan tugas, dan akan di kirimkan ke Admin DLH Minahasa untuk dijadikan bahan dalam laporan tugas anda", style: style.typography(size: style.textDesc, color: style.darkColor)),
                Text("Apakah anda setuju?", style: style.typography(size: style.textDesc, color: style.dangerColor, bold: true))
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  // style: style.defaultButton(),
                  child: Text("Tidak", style: style.typography(size: style.textDesc, useDefaultColor: true, bold: true))),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: style.defaultButton(),
                  child: Text("Ya", style: style.typography(size: style.textDesc, useDefaultColor: true, bold: true)))
            ],
          );
        }).then((value) => value ?? false);
    return confirmed;
  }
}
