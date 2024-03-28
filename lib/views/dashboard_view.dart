import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/controller/driver_controller.dart';
import 'package:truck_monitoring_apps/controller/truck_controller.dart';
import 'package:truck_monitoring_apps/models/trackings.dart';
import 'package:truck_monitoring_apps/models/truck.dart';
import 'package:truck_monitoring_apps/utils/style.dart';
import 'package:truck_monitoring_apps/views/testing_geofencing_view.dart';

import '../config/route.dart';
import '../controller/tracking_controller.dart';
import '../utils/logger.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

enum TrackingStatus {
  noData,
  noTruck,
  truckSelected,
  started,
}

class _DashboardViewState extends State<DashboardView> {
  /*Todo List
  - Determine Function to get Current Status of Tracking
  - If Status Tracking is on Progress (already Start)
    - Change Button to Visit Report
    - Block Button on Truck
    - Make Sure the Geo Locator is Active
    - If Not start the geolocator
    - Add View for showing Geolocator Status
  - If Status Tracking is Stop
    - Change Button to Stop
    - Or Get Current Tracking if there is another new Tracking Job
    - If No Tracking Job, Block the button Truck and Start Geofencing
  - Make Helper for Geolocator
    - Status
    - Start
    - Stop

  - Button Start (tracking status = truckSelected ) => Visit Report (tracking status = started )
  - Visit Report Button Stop => tracking status = no Data
  - Return From Visit Report = Started : tracking status = started, Stop : tracking status = no Data, Null No action
 */

  AppStyle style = AppStyle();
  late Size screen;
  var isTracking = 0.obs; //0 : disabled, 1: Empty, 2 : Tracking
  var truckDB = "".obs;
  var trackingStatus = TrackingStatus.noData.obs;
  TruckModel? selectedTruck;
  var isLoadingData = true.obs;
  final TrackingController _trackingController = TrackingController();

  Future<void> getCurrentTrackings() async {
    isLoadingData.value = true;
    Trackings? response = await _trackingController.getCurrentTracking(context);
    if (response != null) {
      currentTrackings.value = response;
      trackingStatus.value = TrackingStatus.noTruck;
      currentTrackings.refresh();

      if (currentTrackings.value.truckId != '-' &&
          currentTrackings.value.stopLocation == "-") {
        TruckController truckController = TruckController();
        if (context.mounted) {
          selectedTruck = await truckController.getTruckById(
              currentTrackings.value.truckId, context);
          if (selectedTruck != null) {
            currentTruck.value.copyFrom(selectedTruck!);
            truckDB.value = currentTruck.value.plate;
            trackingStatus.value = TrackingStatus.truckSelected;
          }
        }
      }
      if (currentTrackings.value.stopLocation != "-" &&
          currentTrackings.value.truckId == '-') {
        trackingStatus.value = TrackingStatus.noTruck;
      }
      if (currentTrackings.value.startLocation != "-" &&
          currentTrackings.value.stopLocation == "-") {
        isTracking.value = 2;
        trackingStatus.value = TrackingStatus.started;
      }
      setState(() {});
      printLog("Current Tracking change :${currentTrackings.value.toMap()}");
    }
    isLoadingData.value = false;
  }

  Future<void> startTracking() async {
    if (await geoHelper.checkStatus()) {
      showMessage(
          title: "Tracking Status",
          message: "Tracking Already Started",
          type: MessageType.info);
      return;
    } else {
      // geoLocCol.items.clear();
      geoLocCol.trackingId = currentTrackings.value.id!;
      await geoHelper.initGeolocator(updateUI: updateUI);
    }
    geoHelper.start();
  }

  Future<void> updateUI(dynamic message) async {
    print("Message : $message");
  }

  Future<void> stopTracking() async {
    if (!await geoHelper.checkStatus()) {
      showMessage(
          title: "Tracking Status",
          message: "No Tracking is Detected!",
          type: MessageType.danger);
      return;
    }
    geoLocCol.items.clear();
    geoLocCol.trackingId = "";
    await geoHelper.stop();

    showMessage(
        title: "Tracking Status",
        message: "Tracking is stopped!",
        type: MessageType.info);
  }

  Future<void> logout() async {
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
                    width: screen.width * .3,
                    height: screen.width * .3,
                    child: CircularProgressIndicator(
                      color: style.lightColor,
                    ))
              ],
            ),
          );
        });
    var res = await DriverController().logout(context);
    if (res) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, RouteName.loginPage);
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentTrackings();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: style.backgroundColor,
        centerTitle: true,
        title: Column(
          children: [
            Text(DateFormat('EEEE, d MMMM y').format(DateTime.now()),
                style: style.typography(
                    size: style.textH6, color: style.primaryColor, bold: true)),
            Text(
              describeEnum(trackingStatus.value),
              style: style.typography(
                  size: style.textDesc, color: style.primaryColor, bold: true),
            )
          ],
        ),
      ),
      backgroundColor: style.primaryColor,
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: screen.width,
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
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
                  children: [
                    upperPanel(),
                    const SizedBox(
                      height: 20,
                    ),
                    buttonSelectTruck(),
                    const SizedBox(
                      height: 20,
                    ),
                    Obx(() => trackingStatus.value == TrackingStatus.started
                        ? Container(
                            alignment: Alignment.center,
                            height: (screen.width * .5) - 30,
                            decoration: BoxDecoration(
                                color: style.dangerColor,
                                border: Border.all(
                                    color: style.darkColor, width: 4),
                                borderRadius: BorderRadius.circular(10)),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  trackingStatus.value =
                                      await Navigator.pushNamed(
                                          context, RouteName.visitingViewPage,
                                          arguments: currentTrackings
                                              .value.routeId) as TrackingStatus;
                                  if (trackingStatus.value ==
                                      TrackingStatus.noData) {
                                    await stopTracking();
                                  }
                                  isTracking.value = trackingStatus.value ==
                                          TrackingStatus.started
                                      ? 2
                                      : 0;
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox.expand(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_copy,
                                        color: style.warningColor,
                                        size: 80,
                                      ),
                                      Text("Visiting Report",
                                          style: style.typography(
                                              size: style.textH1,
                                              color: style.lightColor,
                                              bold: true))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () async {
                              if (trackingStatus.value ==
                                  TrackingStatus.truckSelected) {
                                isTracking.value = await Navigator.pushNamed(
                                    context, RouteName.routeListPage,
                                    arguments:
                                        currentTrackings.value.routeId) as int;
                                trackingStatus.value = TrackingStatus.started;
                                await startTracking();
                                printLog(
                                    "Is Tracking Value : ${isTracking.value}");
                              }
                            },
                            child: Container(
                              width: screen.width,
                              height: 160,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: isTracking.value == 0
                                      ? style.disabledColor
                                      : isTracking.value == 1
                                          ? style.secondaryColor
                                          : style.dangerColor,
                                  border: Border.all(
                                      color: isTracking.value == 0
                                          ? Colors.grey.shade800
                                          : isTracking.value == 1
                                              ? style.primaryColor
                                              : style.darkColor,
                                      width: 4),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.my_location_outlined,
                                    color: isTracking.value == 0
                                        ? Colors.grey.shade800
                                        : isTracking.value == 1
                                            ? style.primaryColor
                                            : style.warningColor,
                                    size: 80,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Text(
                                        trackingStatus.value ==
                                                TrackingStatus.started
                                            ? "Stop Tracking"
                                            : "Start Geofencing",
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: style.typography(
                                            size: 36,
                                            height: 1,
                                            color: isTracking.value == 0
                                                ? Colors.grey.shade800
                                                : style.lightColor,
                                            bold: true)),
                                  )
                                ],
                              ),
                            ),
                          ))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteName.historyPage);
                      },
                      style: style.customButtonStyle(
                          bgColorNormal: style.lightColor,
                          bgColorPressed: style.accentColor,
                          radiusNormal: BorderRadius.circular(10),
                          radiusPressed: BorderRadius.circular(15),
                          fgColorNormal: style.secondaryColor,
                          fgColorPressed: style.primaryColor),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.route_rounded,
                            color: style.primaryColor,
                            size: 48,
                          ),
                          Text("History",
                              style: style.typography(
                                  size: style.textH6,
                                  useDefaultColor: true,
                                  bold: true))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RouteName.changePasswordPage);
                          },
                          style: style.customButtonStyle(
                              bgColorNormal: style.warningColor,
                              bgColorPressed: style.accentColor,
                              radiusNormal: BorderRadius.circular(10),
                              radiusPressed: BorderRadius.circular(15),
                              fgColorNormal: style.lightColor,
                              fgColorPressed: style.primaryColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.key,
                                color: style.lightColor,
                                size: 36,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text("Change Password",
                                    style: style.typography(
                                        size: style.textH6,
                                        useDefaultColor: true,
                                        bold: true)),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () async {
                            await logout();
                          },
                          style: style.customButtonStyle(
                              bgColorNormal: style.accentColor,
                              bgColorPressed: style.primaryColor,
                              radiusNormal: BorderRadius.circular(10),
                              radiusPressed: BorderRadius.circular(15),
                              fgColorNormal: style.lightColor,
                              fgColorPressed: style.primaryColor),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.logout,
                                color: style.lightColor,
                                size: 36,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text("Logout",
                                    style: style.typography(
                                        size: style.textH6,
                                        useDefaultColor: true,
                                        bold: true)),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buttonSelectTruck() {
    printLog(
        "Current Start Location : ${currentTrackings.value.startLocation} - Stop Location : ${currentTrackings.value.stopLocation}");
    return Obx(() => isLoadingData.value
        ? Container(
            width: screen.width,
            height: 140,
            padding: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: style.accentColor.withOpacity(0.2),
                border: Border.all(color: style.accentColor, width: 2),
                borderRadius: BorderRadius.circular(20)),
            child: CircularProgressIndicator(color: style.accentColor),
          )
        : trackingStatus.value == TrackingStatus.noData
            ? Container(
                width: screen.width,
                height: 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: style.dangerColor2.withOpacity(0.2),
                    border: Border.all(color: style.dangerColor, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "You don't have assigned tracks yet, please contact Admin for information!",
                      style: style.typography(
                          size: style.textH5,
                          color: style.dangerColor,
                          bold: true),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    IconButton(
                        onPressed: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (_) => TestGeofencingView()));
                          getCurrentTrackings();
                        },
                        icon: Icon(
                          Icons.refresh,
                          color: style.dangerColor,
                          size: 36,
                        ))
                  ],
                ),
              )
            : InkWell(
                onTap: () async {
                  if (trackingStatus.value == TrackingStatus.noTruck &&
                      trackingStatus.value != TrackingStatus.started) {
                    var db = await Navigator.pushNamed(
                        context, RouteName.truckListPage);
                    if (db != null) {
                      truckDB.value = (db as TruckModel).plate;
                      if (currentTrackings.value.driverId != '-') {
                        isTracking.value = 1;
                        currentTrackings.value.truckId = db.id;
                        currentTrackings.value.truckPlate = db.plate;
                        currentTruck.value.copyFrom(db);
                        trackingStatus.value = TrackingStatus.truckSelected;
                      }
                    }
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: screen.width,
                  height: 140,
                  decoration: BoxDecoration(
                      border: Border.all(color: style.darkColor, width: 2),
                      color: style.dangerColor2,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Container(
                          width: screen.width,
                          height: 105,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: style.lightColor,
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: style.darkColor, width: 3)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Truck Information",
                                  style: style.typography(
                                      size: style.textDesc,
                                      color: style.darkColor,
                                      bold: true)),
                              Obx(
                                () => Text(
                                    trackingStatus.value ==
                                            TrackingStatus.noTruck
                                        ? "No Truck Selected"
                                        : truckDB.value,
                                    style: style.typography(
                                        size: 32,
                                        color: style.darkColor,
                                        bold: true)),
                              ),
                            ],
                          )),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              trackingStatus.value ==
                                          TrackingStatus.truckSelected &&
                                      trackingStatus.value !=
                                          TrackingStatus.started
                                  ? 'Click to change'
                                  : 'Truck Selected',
                              style: style.typography(
                                  size: style.textDesc,
                                  color: style.darkColor,
                                  bold: true)),
                        ),
                      )
                    ],
                  ),
                ),
              ));
  }

  Container upperPanel() {
    printLog("Driver Photo : $baseUrl$driverPhotoUrl${loggedUser.value.photo}");
    return Container(
        width: screen.width,
        height: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  style.fifthColor,
                  style.fifthColor,
                  style.accentColor
                ]),
            border: Border.all(color: style.lightColor, width: 2),
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  blurRadius: 2,
                  spreadRadius: 2,
                  offset: Offset(0, 2),
                  color: Colors.black26)
            ]),
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: screen.width,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (mounted) {
                          await Navigator.pushNamed(
                              context, RouteName.photoFormPage);
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(2),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: style.primaryColor, width: 2),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                  color: Colors.black26)
                            ]),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            "$baseUrl$driverPhotoUrl${loggedUser.value.photo}",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              "assets/truck.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const TestGeofencingView()));
                          },
                          child: Text("Welcome",
                              style: style.typography(
                                  size: style.textH4, color: style.lightColor)),
                        ),
                        Text(loggedUser.value.name,
                            overflow: TextOverflow.ellipsis,
                            style: style.typography(
                                size: 32,
                                height: 0.8,
                                color: style.sixthColor,
                                bold: true)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                            loggedUser.value.gender == "L"
                                ? "Laki-Laki"
                                : "Perempuan",
                            overflow: TextOverflow.ellipsis,
                            style: style.typography(
                                size: style.textH6,
                                height: 0.8,
                                color: style.sixthColor)),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                            "DOB : ${DateFormat('d MMMM y').format(loggedUser.value.dob!)}",
                            overflow: TextOverflow.ellipsis,
                            style: style.typography(
                                size: style.textH6,
                                height: 0.8,
                                color: style.warningColor))
                      ],
                    ))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
