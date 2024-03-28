import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/controller/driver_controller.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/style.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final style = AppStyle();
  late Size screen;
  final txtOpwd = TextEditingController();
  final txtNpwd = TextEditingController();
  final txtCpwd = TextEditingController();
  final txtUid = TextEditingController();
  var isObscuredOld = true.obs;
  var isObscuredNew = true.obs;
  var isObscuredConfirm = true.obs;
  var isLoading = false.obs;
  final DriverController _driverController = DriverController();
  final _formKey = GlobalKey<FormBuilderState>();

  void submit() async {
    isLoading.value = true;
    var response = await _driverController.updatePassword(
        txtOpwd.text, txtNpwd.text, context);
    if (response) {
      if (context.mounted) {
        showMessage(
            title: "Success",
            message: "Password successfully updated!",
            type: MessageType.success);
      }
      txtCpwd.clear();
      txtNpwd.clear();
      txtOpwd.clear();
    }
    isLoading.value = false;
  }

  @override
  void dispose() {
    txtCpwd.dispose();
    txtNpwd.dispose();
    txtOpwd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    txtUid.text = loggedUser.value.userName;
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: style.lightColor),
        title: Text("Change Passsword",
            style: style.typography(
                size: style.textH1, color: style.lightColor, bold: true)),
        backgroundColor: style.primaryColor,
        elevation: 1,
      ),
      backgroundColor: style.primaryColor,
      body: Column(
        children: [
          Expanded(
              child: Container(
            width: screen.width,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: style.backgroundColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                boxShadow: const [
                  BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 2,
                      offset: Offset(0, 2),
                      color: Colors.black26)
                ]),
            child: Obx(
              () => isLoading.value
                  ? Container(
                      alignment: Alignment.center,
                      width: screen.width,
                      height: screen.height,
                      child: CircularProgressIndicator(
                        color: style.accentColor,
                      ),
                    )
                  : SingleChildScrollView(
                      child: FormBuilder(
                        key: _formKey,
                        child: Column(
                          children: [
                            Container(
                              width: screen.width,
                              padding: const EdgeInsets.all(10),
                              child: FormBuilderTextField(
                                name: "uid",
                                controller: txtUid,
                                readOnly: true,
                                validator: (value) {
                                  if (value == "") {
                                    return "User Id can be empty!";
                                  }
                                  return null;
                                },
                                style: style.typography(
                                    size: style.textH6,
                                    color: style.secondaryColor,
                                    bold: true),
                                decoration: InputDecoration(
                                    labelText: "USER ID",
                                    labelStyle: style.typography(
                                        size: style.textH6,
                                        color: style.accentColor,
                                        bold: true),
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: style.secondaryColor,
                                            width: 2)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: style.accentColor,
                                            width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: style.secondaryColor,
                                            width: 2)),
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
                                    controller: txtOpwd,
                                    validator: (value) {
                                      if (value == "") {
                                        return "Password can be empty!";
                                      }
                                    },
                                    obscureText: isObscuredOld.value,
                                    style: style.typography(
                                        size: style.textH6,
                                        color: style.secondaryColor,
                                        bold: true),
                                    decoration: InputDecoration(
                                        labelText: "OLD PASSWORD",
                                        labelStyle: style.typography(
                                            size: style.textH6,
                                            color: style.accentColor,
                                            bold: true),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                10, 5, 10, 5),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.secondaryColor,
                                                width: 2)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.accentColor,
                                                width: 2)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.secondaryColor,
                                                width: 2)),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: style.accentColor,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            isObscuredOld.value =
                                                !isObscuredOld.value;
                                          },
                                          icon: Icon(
                                            isObscuredOld.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: style.accentColor,
                                          ),
                                        )),
                                  ),
                                )),
                            Divider(
                              color: style.primaryColor,
                              thickness: 8,
                            ),
                            Container(
                                width: screen.width,
                                padding: const EdgeInsets.all(10),
                                child: Obx(
                                  () => FormBuilderTextField(
                                    name: "Npwd",
                                    controller: txtNpwd,
                                    validator: (value) {
                                      if (value == "") {
                                        return "Password can be empty!";
                                      }
                                      if (txtNpwd.text != txtCpwd.text) {
                                        return "Confirm password wrong";
                                      }
                                      return null;
                                    },
                                    obscureText: isObscuredNew.value,
                                    style: style.typography(
                                        size: style.textH6,
                                        color: style.secondaryColor,
                                        bold: true),
                                    decoration: InputDecoration(
                                        labelText: "NEW PASSWORD",
                                        labelStyle: style.typography(
                                            size: style.textH6,
                                            color: style.accentColor,
                                            bold: true),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                10, 5, 10, 5),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.secondaryColor,
                                                width: 2)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.accentColor,
                                                width: 2)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.secondaryColor,
                                                width: 2)),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: style.accentColor,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            isObscuredNew.value =
                                                !isObscuredNew.value;
                                          },
                                          icon: Icon(
                                            isObscuredNew.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: style.accentColor,
                                          ),
                                        )),
                                  ),
                                )),
                            Container(
                                width: screen.width,
                                padding: const EdgeInsets.all(10),
                                child: Obx(
                                  () => FormBuilderTextField(
                                    name: "cpwd",
                                    controller: txtCpwd,
                                    validator: (value) {
                                      if (value == "") {
                                        return "Password can be empty!";
                                      }
                                      if (txtNpwd.text != txtCpwd.text) {
                                        return "Confirm password wrong";
                                      }
                                      return null;
                                    },
                                    obscureText: isObscuredConfirm.value,
                                    style: style.typography(
                                        size: style.textH6,
                                        color: style.secondaryColor,
                                        bold: true),
                                    decoration: InputDecoration(
                                        labelText: "CONFRIM NEW PASSWORD",
                                        labelStyle: style.typography(
                                            size: style.textH6,
                                            color: style.accentColor,
                                            bold: true),
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                10, 5, 10, 5),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.secondaryColor,
                                                width: 2)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.accentColor,
                                                width: 2)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: style.secondaryColor,
                                                width: 2)),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: style.accentColor,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            isObscuredConfirm.value =
                                                !isObscuredConfirm.value;
                                          },
                                          icon: Icon(
                                            isObscuredConfirm.value
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: style.accentColor,
                                          ),
                                        )),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
            ),
          )),
          Container(
            width: screen.width,
            height: 80,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: style.customButtonStyle(
                        bgColorNormal: style.lightColor,
                        bgColorPressed: style.dangerColor2,
                        sideNormal: BorderSide(
                          color: style.dangerColor2,
                        )),
                    child: Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: style.dangerColor2,
                      ),
                    )),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          submit();
                        }
                      },
                      style: style.customButtonStyle(
                          bgColorNormal: style.secondaryColor,
                          bgColorPressed: style.lightColor,
                          fgColorNormal: style.lightColor,
                          fgColorPressed: style.warningColor,
                          sideNormal: BorderSide(
                            color: style.lightColor,
                          )),
                      child: Container(
                        alignment: Alignment.center,
                        child: Text("Submit",
                            style: style.typography(
                                size: style.textH6,
                                useDefaultColor: true,
                                bold: true)),
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
