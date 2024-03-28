import 'package:flutter/material.dart';
import 'package:truck_monitoring_apps/models/tracking_visits.dart';
import 'package:truck_monitoring_apps/views/photo_form_view.dart';
import 'package:truck_monitoring_apps/views/visiting_form_view.dart';
import 'package:truck_monitoring_apps/views/visiting_list_view.dart';

import '../views/change_password_view.dart';
import '../views/dashboard_view.dart';
import '../views/history_view.dart';
import '../views/login_view.dart';
import '../views/route_list_view.dart';
import '../views/truck_list_view.dart';
import 'route.dart';

class _GeneratePageRoute extends PageRouteBuilder {
  final Widget widget;
  final String routeName;
  _GeneratePageRoute({required this.widget, required this.routeName})
      : super(
            settings: RouteSettings(name: routeName),
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return widget;
            },
            transitionDuration: const Duration(microseconds: 500),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SlideTransition(
                  position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .animate(animation),
                  child: child);
            });
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteName.dashboardPage:
        return _GeneratePageRoute(
            widget: const DashboardView(), routeName: RouteName.dashboardPage);
      case RouteName.historyPage:
        return _GeneratePageRoute(
            widget: const HistoryView(), routeName: RouteName.historyPage);
      case RouteName.truckListPage:
        return _GeneratePageRoute(
            widget: const TruckListView(), routeName: RouteName.truckListPage);
      case RouteName.changePasswordPage:
        return _GeneratePageRoute(
            widget: const ChangePasswordView(),
            routeName: RouteName.changePasswordPage);

      case RouteName.visitingViewPage:
        return _GeneratePageRoute(
            widget: VisitingListView(
              routeId: settings.arguments as String,
            ),
            routeName: RouteName.visitingViewPage);

      case RouteName.visitingFormPage:
        {
          return _GeneratePageRoute(
              widget: VisitingFormView(
                  visits: settings.arguments as TrackingVisits),
              routeName: RouteName.visitingFormPage);
        }

      case RouteName.photoFormPage:
        return _GeneratePageRoute(
            widget: const PhotoFormView(), routeName: RouteName.photoFormPage);
      case RouteName.routeListPage:
        return _GeneratePageRoute(
            widget: RouteListView(
              routeId: settings.arguments as String,
            ),
            routeName: RouteName.routeListPage);
      default:
        return _GeneratePageRoute(
            widget: const LoginView(), routeName: RouteName.loginPage);
    }
  }
}
