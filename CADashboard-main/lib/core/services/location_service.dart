import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';

import '../../main.dart';
import '../../ui/screen/home.dart';
import '../../ui/widget/custom_btn.dart';
import '../utils/images.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Location _location = Location();
  final ValueNotifier<bool> isLocationEnabled = ValueNotifier(true);

  OverlayEntry? _overlayEntry;
  Timer? _locationCheckTimer;

  void startMonitoring(BuildContext context) {
    _locationCheckTimer?.cancel();
    _locationCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      bool enabled = await _location.serviceEnabled();
      if (!enabled) {
        if (_overlayEntry == null) _showOverlay(context);
        isLocationEnabled.value = false;
      } else {
        _removeOverlay();
        isLocationEnabled.value = true;
      }
    });
  }

  void _showOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          ModalBarrier(
            color: Colors.black.withValues(alpha: 0.3),
            dismissible: false,
          ),
          Center(
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: SizedBox(
                height: 400,
                width: 300,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(AppImages.locationAnimation, height: 150),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          child: Text(
                            "Oops! Location is turned off. Please enable it to use the app smoothly.
                            Setting -> Privacy & Security -> Location Services -> ON",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CusBtn(
                                btnName: "Not Now",
                                bGColor: Colors.red,
                                onTap: () {
                                  _removeOverlay();
                                },
                              ),
                            ),
                            Expanded(
                              child: CusBtn(
                                btnName: "Turn on",
                                onTap: () async {
                                  await _openLocationSettings();
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          /*Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Oops! Location is turned off. Please enable it to use the app smoothly.",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              appPrint("Click : Exit");
                              SystemNavigator.pop();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text("Exit", style: TextStyle(color: Colors.white))
                            ),
                          )
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          color: Colors.white,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              bool permissionGranted = await requestLocationPermission(context);
                              appPrint("Permission granted: $permissionGranted");
                              if (permissionGranted) {
                                bool serviceTurnedOn = await _location.requestService();
                                appPrint("Service turned on: $serviceTurnedOn");
                                if (serviceTurnedOn) {
                                  _removeOverlay();
                                }
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text("Turn on", style: TextStyle(color: Colors.white))
                            ),
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),*/
        ],
      ),
    );

    // Overlay.of(context).insert(_overlayEntry!);
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      appPrint("Overlay is not available");
      return;
    }
    overlayState.insert(_overlayEntry!);
  }

  requestLocationPermission(context) async {
    LocationPermission permission;
    // Check if location services are enabled

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (Platform.isIOS) {
      if (!serviceEnabled) {
        final ctx = navigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          locationDialog(
            context: ctx,
            onTapGotIt: () => Navigator.pop(ctx),
          );
        }
        return false;
      }
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true ;
  }

  Future<void> _openLocationSettings() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();

      // If permission is denied/restricted, open app settings directly.
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return;
      }

      // Otherwise open device location service settings.
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      // Fallback: keep user in app if everything is already enabled.
      _removeOverlay();
    } catch (e) {
      appPrint("Unable to open location settings: $e");
    }
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      try {
        _overlayEntry!.remove();
      } catch (e) {
        debugPrint("Overlay already removed: $e");
      }
      _overlayEntry = null;
    }
  }

  void dispose() {
    _locationCheckTimer?.cancel();
    _removeOverlay();
  }
}
