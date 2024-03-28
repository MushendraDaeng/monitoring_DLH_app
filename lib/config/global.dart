/*
baseUrl
apiUrl
current Monitoring Status
loggedUser
*/
import 'package:get/get.dart';
import 'package:truck_monitoring_apps/models/driver.dart';
import 'package:truck_monitoring_apps/models/trackings.dart';
import 'package:truck_monitoring_apps/models/truck.dart';
import 'package:truck_monitoring_apps/utils/geolocator_helper.dart';

import '../models/detail_tracking.dart';
//
const String baseUrl ="http://dlh-minahasa.it-project.work";
// "http://192.168.1.18:8000";
const String apiUrl = "/api/";
const String driverPhotoUrl = "/driver_photo/";
const String truckPhotoUrl = "/truck_photo/";
const String visitPhotoUrl = "/visit_photo/";
var loggedUser = DriverModel(
        id: "-",
        userName: "-",
        name: "-",
        password: "-",
        phone: "-",
        gender: "-")
    .obs;
var currentTrackings = Trackings(
        driverId: "-",
        driverName: "-",
        truckId: "-",
        truckPlate: "-",
        startLocation: "-",
        actDate: DateTime.now(),
        startTime: DateTime.now(),
        routeId: "-",
        routeName: "-")
    .obs;
var currentTruck =
    TruckModel(id: "-", name: "-", plate: "-", brand: "-", fuelType: "-").obs;

GeoLocatorHelper geoHelper = GeoLocatorHelper();
GeoLocationCollection geoLocCol =
    GeoLocationCollection(items: [], trackingId: "");
