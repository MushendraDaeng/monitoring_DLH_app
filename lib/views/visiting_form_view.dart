import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/controller/customer_controller.dart';
import 'package:truck_monitoring_apps/controller/visit_controller.dart';
import 'package:truck_monitoring_apps/models/customer.dart';
import 'package:truck_monitoring_apps/models/tracking_visits.dart';
// import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/style.dart';

import '../utils/logger.dart';

class VisitingFormView extends StatefulWidget {
  final TrackingVisits visits;

  const VisitingFormView({super.key, required this.visits});

  @override
  State<VisitingFormView> createState() => _VisitingFormViewState();
}

class _VisitingFormViewState extends State<VisitingFormView> {
  final AppStyle style = AppStyle();
  late Size screen;
  Customer? customer;
  bool isEdit = false;
  TrackingVisits? visits;
  var isLoadingCustomer = true.obs;
  var isLoadingData = true.obs;
  final CustomerController _customerController = CustomerController();
  final VisitController _visitController = VisitController();
  final txtDescription = TextEditingController();
  final _formKey = GlobalKey<FormBuilderState>();
  String selectedImagePath = "";

  Future<void> getCustomer() async {
    isLoadingCustomer.value = true;

    var response =
        await _customerController.getCustomerById(visits!.customerId, context);
    if (response != null) {
      customer = response;
    }

    isLoadingCustomer.value = false;
  }

  Future<void> getVisitDetail() async {
    isLoadingData.value = true;
    var response = await _visitController.getVisitByCustomerId(
        widget.visits.customerId, widget.visits.trackingId, context);
    if (response != null) {
      visits = response;
      txtDescription.text = visits!.description!;
      isEdit = true;
    } else {
      visits = widget.visits;
      isEdit = false;
    }
    isLoadingData.value = false;
    getCustomer();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> submitData() async {
    isLoadingData.value = true;
    printLog("Geo location from submit visit form : ${geoLocCol.items.length}");
    if (!isEdit) {
      visits!.description = txtDescription.text;
      visits!.customerId = widget.visits.customerId;
      visits!.trackingId = widget.visits.trackingId;
      visits!.trackingDate = DateTime.now();
      visits!.customerLat = customer!.latitude.toString();
      visits!.customerLng = customer!.longitude.toString();
      visits!.customerName = customer!.name;
      var response = await _visitController.createVisit(
          visits: visits!, context: context, geoLocationCollection: geoLocCol);
      if (response != null) {
        if (mounted) {
          if (mounted) {
            showMessage(
                title: "Success",
                message: "Visit Report successfully created",
                type: MessageType.success);
          }
          if (selectedImagePath != "") {
            await _visitController.updatePhoto(
                filePath: selectedImagePath,
                id: response.id!,
                context: context);
          }
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }
    } else {
      visits!.description = txtDescription.text;
      visits!.customerId = widget.visits.customerId;
      visits!.trackingId = widget.visits.trackingId;
      visits!.trackingDate = DateTime.now();
      visits!.customerLat = customer!.latitude.toString();
      visits!.customerLng = customer!.longitude.toString();
      visits!.customerName = customer!.name;
      printLog("Visits : ${visits!.toMap()}");
      var response = await _visitController.updateVisit(
          visits: visits!, context: context, geoLocationCollection: geoLocCol);
      if (response != null) {
        if (mounted) {
          if (mounted) {
            showMessage(
                title: "Success",
                message: "Visit Report successfully created",
                type: MessageType.success);
          }
          if (selectedImagePath != "") {
            await _visitController.updatePhoto(
                filePath: selectedImagePath,
                id: response.id!,
                context: context);
          }
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }
    }
    isLoadingData.value = false;
  }

  @override
  void dispose() {
    txtDescription.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    visits = widget.visits;
    getVisitDetail();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: style.backgroundColor,
          title: Column(
            children: [
              Text("Visiting Report",
                  style: style.typography(
                      size: style.textH5,
                      color: style.primaryColor,
                      bold: true)),
              Text(
                DateFormat("EEEEE, d MMMM y").format(DateTime.now()),
                style: style.typography(size: 11, color: style.darkColor),
              )
            ],
          ),
          iconTheme: IconThemeData(color: style.primaryColor),
          elevation: 0,
        ),
        backgroundColor: style.primaryColor,
        body: Obx(
          () => isLoadingData.value
              ? Container(
                  width: screen.width,
                  height: screen.height,
                  color: style.backgroundColor,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(color: style.primaryColor),
                  ),
                )
              : SizedBox(
                  width: screen.width,
                  height: screen.height,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: screen.width,
                          decoration: BoxDecoration(
                              color: style.backgroundColor,
                              boxShadow: const [
                                BoxShadow(
                                    blurRadius: 2,
                                    spreadRadius: 2,
                                    offset: Offset(0, 2),
                                    color: Colors.black12)
                              ],
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                customerPanel(),
                                Container(
                                  width: screen.width,
                                  height: 150,
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: style.lightColor,
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      boxShadow: const [
                                        BoxShadow(
                                            blurRadius: 2,
                                            color: Colors.black12,
                                            spreadRadius: 3)
                                      ],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: visits!.photoUrl == null &&
                                          selectedImagePath == ""
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            final ImagePicker picker =
                                                ImagePicker();
                                            final XFile? image =
                                                await picker.pickImage(
                                                    source: ImageSource.camera);
                                            if (image != null) {
                                              selectedImagePath = image.path;
                                            } else {
                                              selectedImagePath = "";
                                            }
                                          },
                                          style: style.defaultButton(),
                                          child: Container(
                                            width: 100,
                                            height: 50,
                                            alignment: Alignment.center,
                                            child: Text("Take Picture",
                                                style: style.typography(
                                                    size: style.textH6,
                                                    useDefaultColor: true,
                                                    bold: true)),
                                          ))
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 130,
                                                clipBehavior: Clip.antiAlias,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color:
                                                            style.primaryColor,
                                                        width: 2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: InteractiveViewer(
                                                    child: selectedImagePath ==
                                                            ""
                                                        ? Image.network(
                                                            "$baseUrl$visitPhotoUrl${visits!.photoUrl}",
                                                            fit: BoxFit.contain,
                                                          )
                                                        : Image.file(
                                                            File(
                                                                selectedImagePath),
                                                            fit: BoxFit.contain,
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    final ImagePicker picker =
                                                        ImagePicker();
                                                    final XFile? image =
                                                        await picker.pickImage(
                                                            source: ImageSource
                                                                .camera);
                                                    if (image != null) {
                                                      selectedImagePath =
                                                          image.path;
                                                    } else {
                                                      selectedImagePath = "";
                                                    }
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 58,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            style.primaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Icon(
                                                      Icons.camera_alt_rounded,
                                                      color: style.lightColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    selectedImagePath = "";
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 58,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            style.dangerColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: style.lightColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Text("Description",
                                      style: style.typography(
                                          size: style.textH5,
                                          color: style.primaryColor,
                                          bold: true)),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                      color: style.lightColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: FormBuilder(
                                    key: _formKey,
                                    child: FormBuilderTextField(
                                      name: "txtDescription",
                                      controller: txtDescription,
                                      maxLines: 4,
                                      decoration: InputDecoration(
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
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: screen.width,
                        height: 80,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, 1);
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
                                    submitData();
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
                ),
        ));
  }

  Container customerPanel() {
    return Container(
      width: screen.width,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: style.lightColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10)),
      child: Obx(() => isLoadingCustomer.value
          ? Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: style.primaryColor,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer!.name,
                    style: style.typography(
                        size: style.textH5,
                        color: style.primaryColor,
                        bold: true)),
                Divider(
                  color: style.primaryColor,
                ),
                Text("District : ${customer!.urbanVillage}",
                    style: style.typography(
                        size: style.textDesc, color: style.fourthColor)),
                Text("Sub District : ${customer!.subDistrict}",
                    style: style.typography(
                        size: style.textDesc, color: style.darkColor)),
                Text("Status : ${customer!.status}",
                    style: style.typography(
                        size: style.textDesc,
                        color: style.darkColor,
                        bold: true))
              ],
            )),
    );
  }
}
