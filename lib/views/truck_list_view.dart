import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:truck_monitoring_apps/controller/truck_controller.dart';
import 'package:truck_monitoring_apps/models/truck.dart';
import 'package:truck_monitoring_apps/utils/style.dart';

import '../config/global.dart';

class TruckListView extends StatefulWidget {
  const TruckListView({super.key});

  @override
  State<TruckListView> createState() => _TruckListViewState();
}

class _TruckListViewState extends State<TruckListView> {
  AppStyle style = AppStyle();
  late Size screen;
  var isLoading = true.obs;
  TruckModel? selectedTruck;
  List<TruckModel> trucks = [];
  var page = 0.obs, limit = 10.obs;
  TruckController _truckController = TruckController();
  Future<void> getData() async {
    isLoading.value = true;
    var res = await _truckController.getTruckList(
        page: 0, limit: 10, context: context);
    if (res.isNotEmpty) {
      trucks.clear();
      trucks.addAll(res);
    }
    isLoading.value = false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: style.lightColor),
        title: Text("Truck List",
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
              child: Obx(() => isLoading.value
                  ? Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child:
                          CircularProgressIndicator(color: style.primaryColor),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await getData();
                      },
                      child: ListView.builder(
                        itemCount: trucks.isEmpty ? 1 : trucks.length,
                        itemBuilder: (context, index) {
                          if (trucks.isEmpty) {
                            return Container(
                              width: screen.width,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: style.fifthColor,
                                  border: Border.all(
                                      color: style.darkColor, width: 2),
                                  borderRadius: BorderRadius.circular(20)),
                              alignment: Alignment.center,
                              child: Text("No Trucks Data at a moment!",
                                  style: style.typography(
                                      size: style.textDesc,
                                      bold: true,
                                      color: style.darkColor)),
                            );
                          }
                          return InkWell(
                            onTap: () {
                              selectedTruck = trucks[index];
                              setState(() {});
                            },
                            child: Container(
                              width: screen.width,
                              height: 150,
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                  color: selectedTruck != null &&
                                          selectedTruck!.plate ==
                                              trucks[index].plate
                                      ? style.accentColor
                                      : style.lightColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: style.primaryColor, width: 2)),
                              child: Row(
                                children: [
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: style.primaryColor),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        "$baseUrl/fto_truck/${trucks[index].image}",
                                        fit: BoxFit.cover,
                                        width: 130,
                                        height: 130,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(trucks[index].plate,
                                            style: style.typography(
                                                size: style.textH2,
                                                color: style.darkColor,
                                                bold: true)),
                                        Text(trucks[index].brand,
                                            style: style.typography(
                                              size: style.textDesc,
                                              color: style.darkColor,
                                            )),
                                        Text(
                                            "Manufacture Year : ${trucks[index].mnfYear}",
                                            style: style.typography(
                                                size: style.textDesc,
                                                color: style.darkColor)),
                                        Text("Name : ${trucks[index].name}",
                                            style: style.typography(
                                                size: style.textDesc,
                                                color: style.darkColor))
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )),
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
                        Navigator.pop(context, selectedTruck);
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
                        child: Text("Select the truck",
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
