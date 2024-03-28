import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:truck_monitoring_apps/controller/tracking_controller.dart';
import 'package:truck_monitoring_apps/utils/style.dart';

import '../models/trackings.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final style = AppStyle();
  var isLoading = true.obs;
  late Size screen;
  List<Trackings> trackings = [];
  final TrackingController _controller = TrackingController();
  int page = 0, limit = 10;
  Future<void> getTrackingData() async {
    var res = await _controller.getTrackingList(
        page: page, limit: limit, context: context);
    if (res.isNotEmpty) {
      trackings.addAll(res);
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTrackingData();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: style.lightColor),
        title: Text("History List",
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
              margin: const EdgeInsets.only(bottom: 10),
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
              child: ListView.builder(
                  itemCount: trackings.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: screen.width,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: style.lightColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: style.primaryColor)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              DateFormat('dd MMMM y')
                                  .format(trackings[index].actDate),
                              style: style.typography(
                                  size: style.textH5,
                                  color: style.primaryColor,
                                  bold: true)),
                          Divider(
                            color: style.primaryColor,
                            thickness: 2,
                          ),
                          Text("Truck : ${trackings[index].truckPlate}",
                              style: style.typography(
                                  size: style.textDesc,
                                  color: style.primaryColor,
                                  bold: true)),
                          Text("Route : ${trackings[index].routeName}",
                              style: style.typography(
                                  size: style.textDesc,
                                  color: style.primaryColor)),
                          Text(
                              "Start Time : ${DateFormat('HH:mm:ss').format(trackings[index].startTime)}",
                              style: style.typography(
                                  size: style.textDesc,
                                  color: style.primaryColor)),
                          if (trackings[index].stopTime != null)
                            Text(
                                "End Time : ${DateFormat('HH:mm:ss').format(trackings[index].stopTime!)}",
                                style: style.typography(
                                    size: style.textDesc,
                                    color: style.primaryColor))
                        ],
                      ),
                    );
                  }),
            ),
          ),
          Container(
            width: screen.width,
            height: 80,
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: style.customButtonStyle(
                    bgColorNormal: style.lightColor,
                    bgColorPressed: style.dangerColor2,
                    fgColorNormal: style.dangerColor,
                    fgColorPressed: style.lightColor,
                    sideNormal: BorderSide(
                      color: style.dangerColor,
                    )),
                child: Container(
                  // width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        // color: style.dangerColor2,
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text("Back",
                          style: style.typography(
                              size: style.textH6,
                              bold: true,
                              useDefaultColor: true))
                    ],
                  ),
                )),
          )
        ],
      ),
    );
  }
}
