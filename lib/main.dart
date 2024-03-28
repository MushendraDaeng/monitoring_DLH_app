import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:truck_monitoring_apps/config/route.dart';
import 'package:truck_monitoring_apps/config/route_generator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory docDir = await getApplicationDocumentsDirectory();
  Hive.init(docDir.path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: RouteName.loginPage,
    );
  }
}
