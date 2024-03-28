import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/controller/route_tracking_controller.dart';
import 'package:truck_monitoring_apps/controller/tracking_controller.dart';
import 'package:truck_monitoring_apps/models/route_tracking.dart';
import 'package:truck_monitoring_apps/models/tracking_visits.dart';
import 'package:truck_monitoring_apps/utils/style.dart';
import 'package:truck_monitoring_apps/views/dashboard_view.dart';

import '../config/route.dart';
import '../utils/logger.dart';

class VisitingListView extends StatefulWidget {
  final String routeId;
  const VisitingListView({required this.routeId, super.key});

  @override
  State<VisitingListView> createState() => _VisitingListViewState();
}

class _VisitingListViewState extends State<VisitingListView> {
  final AppStyle style = AppStyle();
  late Size screen;

  //Maps
  final Completer<GoogleMapController> _controller = Completer();
  late LocationData _locationData;
  var location = Location();
  bool _serviceEnabled = false;
  var selectedLocation =
      const LatLng(1.2666198485659967, 124.88656767402253).obs;
  Marker _centerMarker = const Marker(markerId: MarkerId("centerMarker"));
  late PermissionStatus _permissionGranted;
  late StreamSubscription<LocationData> _locationSubscription;
  final Set<Marker> _markers = {};
  final CameraPosition _kGooglePlex = const CameraPosition(
    target: LatLng(1.2666198485659967, 124.88656767402253),
    zoom: 16.4746,
  );
  void _setMarkers(
      {LatLng customPoint =
          const LatLng(1.2666198485659967, 124.88656767402253),
      bool self = false}) async {
    _markers.add(Marker(
        markerId: const MarkerId("_centerMarker"),
        position: customPoint,
        icon: self
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        onTap: () {}));

    if (mounted) setState(() {});
  }

  Future<void> getLocation() async {
    printLog("Wait Service Enabled------------------");
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    printLog("Waiting Location Data : ----------------");
    _locationData = await location.getLocation();
    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) async {
      // Use current location
      var lastLocation = _locationData;
      _locationData = currentLocation;

      if (lastLocation != currentLocation) {
        _setMarkers(
            customPoint: LatLng(
              _locationData.latitude!,
              _locationData.longitude!,
            ),
            self: true);

        if (mounted) setState(() {});
      }
    });
  }

  late GoogleMapController _gMapController;

  void _onMapCreated(GoogleMapController controller) async {
    _gMapController = controller;
    _controller.complete(controller);
    await getLocation();

    Future.delayed(const Duration(seconds: 1), () async {
      GoogleMapController controller = await _controller.future;
      var center = LatLng(_locationData.latitude!, _locationData.longitude!);
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: center, zoom: 16.0)));
    });
  }

  var isLoadingData = true.obs;

  final TrackingRouteController _routeController = TrackingRouteController();
  TrackingRoute? route;
  List<TrackingRouteDetail> routeDetails = [];
  Future<void> getRouteList() async {
    isLoadingData.value = true;
    var response =
        await _routeController.getRoute(context: context, id: widget.routeId);
    if (response.isNotEmpty) {
      route = response['route'];
      routeDetails.addAll(response['detail']);
    }
    isLoadingData.value = false;
  }

  final TrackingController _trackingController = TrackingController();
  Future<void> startTracking() async {
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
    var cLocation = await location.getLocation();
    currentTrackings.value.startLocation =
        "${cLocation.latitude},${cLocation.longitude}";
    currentTrackings.value.startTime = DateTime.now();
    if (mounted) {
      var response = await _trackingController.startTracking(
          newData: currentTrackings.value, context: context);
      if (response != null) {
        currentTrackings.refresh();
        showMessage(
            title: "Success",
            message: "Tracking has been started",
            type: MessageType.success);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context, TrackingStatus.started);
        }
      } else {
        showMessage(
            title: "Failed",
            message: "Tracking failed to start!",
            type: MessageType.warning);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> stopTracking() async {
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
    var cLocation = await location.getLocation();
    currentTrackings.value.stopLocation =
        "${cLocation.latitude},${cLocation.longitude}";
    currentTrackings.value.stopTime = DateTime.now();
    if (mounted) {
      var response = await _trackingController.stopTracking(
          newData: currentTrackings.value, context: context,geoLocationCollection:geoLocCol);
      if (response != null) {
        currentTrackings.refresh();
        showMessage(
            title: "Success",
            message: "Tracking has been stopped",
            type: MessageType.success);
        if (mounted) {
          Navigator.pop(context);
          Navigator.pop(context, TrackingStatus.noData);
        }
      } else {
        showMessage(
            title: "Failed",
            message: "Tracking failed to stopped!",
            type: MessageType.warning);
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _locationSubscription.cancel();

    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRouteList();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          if (currentTrackings.value.startLocation == '-') {
            Navigator.pop(context, 1);
          } else {
            Navigator.pop(context, 2);
          }
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: style.backgroundColor,
            title: Column(
              children: [
                Text("Visiting Report List",
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
                    alignment: Alignment.center,
                    color: style.backgroundColor,
                    child: CircularProgressIndicator(color: style.accentColor),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: style.backgroundColor,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20))),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: GoogleMap(
                                      mapType: MapType.hybrid,
                                      initialCameraPosition: _kGooglePlex,
                                      onMapCreated: _onMapCreated,
                                      myLocationEnabled: true,
                                      myLocationButtonEnabled: true,
                                      markers: <Marker>{_centerMarker},
                                      onCameraMove:
                                          (CameraPosition position) async {
                                        Marker marker = _centerMarker;
                                        Marker updatedMarker = marker.copyWith(
                                            positionParam: position.target);
                                        // printLog("LatLng : ${position.target}");
                                        setState(() {
                                          if (mounted) {
                                            _centerMarker = updatedMarker;
                                          }
                                        });
                                        selectedLocation.value =
                                            _centerMarker.position;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text("Customer List on the Route : ",
                                  style: style.typography(
                                      size: style.textDesc,
                                      bold: true,
                                      color: style.darkColor)),
                              const SizedBox(
                                height: 10,
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border:
                                          Border.all(color: style.darkColor)),
                                  child: ListView.builder(
                                      itemCount: routeDetails.isEmpty
                                          ? 1
                                          : routeDetails.length,
                                      itemBuilder: (context, index) {
                                        if (routeDetails.isEmpty) {
                                          return Container(
                                            width: screen.width,
                                            height: 100,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: style.accentColor
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                                "No Data Customers yet!",
                                                style: style.typography(
                                                    size: style.textH6,
                                                    bold: true,
                                                    color: style.darkColor)),
                                          );
                                        }
                                        return InkWell(
                                          onTap: () {
                                            var pos = LatLng(
                                                routeDetails[index].customerLat,
                                                routeDetails[index]
                                                    .customerLng);
                                            _gMapController.animateCamera(
                                                CameraUpdate.newLatLng(pos));
                                            _centerMarker = _centerMarker
                                                .copyWith(positionParam: pos);
                                            setState(() {});
                                          },
                                          child: Container(
                                            width: screen.width,
                                            height: 150,
                                            margin: const EdgeInsets.fromLTRB(
                                                10, 5, 10, 5),
                                            // padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: style.darkColor),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: style.lightColor),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                            routeDetails[
                                                                    index]
                                                                .customerName,
                                                            style: style
                                                                .typography(
                                                                    size: style
                                                                        .textH5,
                                                                    color: style
                                                                        .darkColor,
                                                                    bold:
                                                                        true)),
                                                        Divider(
                                                          color:
                                                              style.darkColor,
                                                        ),
                                                        Text(
                                                            "District : ${routeDetails[index].customerVillage}",
                                                            style: style.typography(
                                                                size: style
                                                                    .textDesc,
                                                                color: style
                                                                    .fourthColor)),
                                                        Text(
                                                            "Sub District : ${routeDetails[index].customerDistrict}",
                                                            style: style.typography(
                                                                size: style
                                                                    .textDesc,
                                                                color: style
                                                                    .darkColor)),
                                                        Text(
                                                            "Status : ${routeDetails[index].customerStatus}",
                                                            style: style.typography(
                                                                size: style
                                                                    .textDesc,
                                                                color: style
                                                                    .darkColor,
                                                                bold: true))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    var visits = TrackingVisits(
                                                        customerId:
                                                            routeDetails[index]
                                                                .customerId,
                                                        trackingId:
                                                            currentTrackings
                                                                .value.id!);
                                                    Navigator.pushNamed(
                                                        context,
                                                        RouteName
                                                            .visitingFormPage,
                                                        arguments: visits);
                                                  },
                                                  child: Container(
                                                    width: 100,
                                                    height: 150,
                                                    decoration: BoxDecoration(
                                                        color: style
                                                            .primaryColor,
                                                        borderRadius:
                                                            const BorderRadius
                                                                    .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        9),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        9))),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.send,
                                                          color:
                                                              style.lightColor,
                                                        ),
                                                        Text("Fill Report",
                                                            style: style.typography(
                                                                size: style
                                                                    .textDesc,
                                                                color: style
                                                                    .lightColor,
                                                                bold: true))
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              )
                            ],
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
                                    if (currentTrackings.value.startLocation !=
                                        "-") {
                                      stopTracking();
                                    } else {
                                      startTracking();
                                    }
                                  },
                                  style: currentTrackings.value.startLocation !=
                                          "-"
                                      ? style.customButtonStyle(
                                          bgColorNormal: style.dangerColor,
                                          bgColorPressed: style.lightColor,
                                          fgColorNormal: style.warningColor,
                                          fgColorPressed: style.darkColor,
                                          sideNormal: BorderSide(
                                            color: style.darkColor,
                                          ))
                                      : style.customButtonStyle(
                                          bgColorNormal: style.secondaryColor,
                                          bgColorPressed: style.lightColor,
                                          fgColorNormal: style.lightColor,
                                          fgColorPressed: style.warningColor,
                                          sideNormal: BorderSide(
                                            color: style.lightColor,
                                          )),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                        currentTrackings.value.startLocation !=
                                                '-'
                                            ? "Stop Geofencing"
                                            : "Start Geofencing",
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
}
