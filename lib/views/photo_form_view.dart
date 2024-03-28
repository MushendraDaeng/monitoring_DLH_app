import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truck_monitoring_apps/controller/driver_controller.dart';

import '../config/global.dart';
import '../utils/logger.dart';
import '../utils/style.dart';

class PhotoFormView extends StatefulWidget {
  const PhotoFormView({Key? key}) : super(key: key);

  @override
  State<PhotoFormView> createState() => _PhotoFormViewState();
}

class _PhotoFormViewState extends State<PhotoFormView> {
  AppStyle style = AppStyle();
  var isChange = false.obs;
  File? imageFile;
  Size? screen;
  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Pilih Photo",
            style: style.typography(
                size: style.textH2, color: style.primaryColor, bold: true)),
        backgroundColor: style.lightColor,
        elevation: 0,
        iconTheme: IconThemeData(color: style.primaryColor),
      ),
      backgroundColor: style.lightColor,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
                width: screen!.width - 40,
                height: screen!.width - 40,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                    color: style.lightColor,
                    border: Border.all(color: style.primaryColor),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 2,
                          offset: const Offset(0, 2),
                          color: Colors.black.withOpacity(0.1))
                    ]),
                child: Obx(
                  () => isChange.value && imageFile != null
                      ? Image.file(imageFile!)
                      : Image.network(
                          loggedUser.value.photo != null
                              ? "$baseUrl$driverPhotoUrl${loggedUser.value.photo!}"
                              : "",
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset("assets/no_image.png"),
                        ),
                )),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: screen!.width - 40,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                        onPressed: () {
                          getImage(ImageSource.gallery);
                        },
                        style: style.defaultButton(),
                        child: Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: Text("Pilih Photo",
                              style: style.typography(
                                  size: style.textH6,
                                  useDefaultColor: true,
                                  bold: true)),
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        getImage(ImageSource.camera);
                      },
                      style: style.customButtonStyle(
                          bgColorNormal: style.warningColor,
                          bgColorPressed: style.accentColor,
                          radiusNormal: BorderRadius.circular(10),
                          radiusPressed: BorderRadius.circular(15),
                          fgColorNormal: style.lightColor,
                          fgColorPressed: style.primaryColor),
                      child: Container(
                        height: 60,
                        alignment: Alignment.center,
                        child: Text("Kamera",
                            style: style.typography(
                                size: style.textH6,
                                useDefaultColor: true,
                                bold: true)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25,
              child: Divider(color: style.primaryColor),
            ),
            Obx(() => isChange.value
                ? SizedBox(
                    width: screen!.width - 40,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                              onPressed: () {
                                isChange.value = false;
                              },
                              style: style.customButtonStyle(
                                  bgColorNormal: style.warningColor,
                                  bgColorPressed: style.accentColor,
                                  radiusNormal: BorderRadius.circular(10),
                                  radiusPressed: BorderRadius.circular(15),
                                  fgColorNormal: style.lightColor,
                                  fgColorPressed: style.primaryColor),
                              child: Container(
                                height: 60,
                                alignment: Alignment.center,
                                child: const Icon(Icons.clear_rounded),
                              )),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              submitPhoto();
                            },
                            style: style.defaultButton(),
                            child: Container(
                              height: 60,
                              alignment: Alignment.center,
                              child: Text("Submit",
                                  style: style.typography(
                                      size: style.textH6,
                                      useDefaultColor: true,
                                      bold: true)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink())
          ],
        ),
      ),
    );
  }

  final picker = ImagePicker();
  String photoPath = "";
  final _controller = DriverController();
  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      isChange.value = true;
      photoPath = pickedFile.path;
    } else {
      isChange.value = false;
      photoPath = "";
    }
  }

  Future<void> submitPhoto() async {
    showDialog(
        context: context,
        barrierColor: style.primaryColor.withOpacity(0.2),
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: screen!.width * .3,
                    height: screen!.width * .3,
                    child: CircularProgressIndicator(
                      color: style.lightColor,
                    ))
              ],
            ),
          );
        });
    var response = await _controller.updatePhotoProfile(photoPath, context);
    if (mounted) {
      Navigator.pop(context);
    }
    if (response) {
      showMessage(
          title: "Sukses",
          message: "Foto berhasil di ganti",
          type: MessageType.success);
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      showMessage(
          title: "Gagal",
          message: "Gagal mengganti foto!",
          type: MessageType.error);
    }
  }
}
