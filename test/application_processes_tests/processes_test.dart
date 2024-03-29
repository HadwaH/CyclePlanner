import 'dart:async';
import 'package:cycle_planner/processes/application_processes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cycle_planner/models/location.dart';
import 'package:cycle_planner/models/geometry.dart';
import 'package:cycle_planner/models/place.dart';

import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

Position get mockPosition => Position(
    latitude: 51.50087611180803,
    longitude: -0.12455029998540676,
    timestamp: DateTime.fromMillisecondsSinceEpoch(
      500,
      isUtc: true,
    ),
    altitude: 3000.0,
    accuracy: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0);
final appProcesses = ApplicationProcesses();

void main() {
  GeolocatorPlatform.instance = MockGeolocatorPlatform();
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel('flutter.baseflow.com/geolocator')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getCurrentPosition') {
      return {};
    }
    return {};
  });

  group('MarkerService', () {
    test('setGroupSize', () async {
      appProcesses.setGroupSize(2);
      //ensure the number 2 is set
      expect(appProcesses.groupSize, 2);
    });

    test('Remove Polylines', () async {
      appProcesses.removePolyline();

      expect(appProcesses.polylines, []);
      expect(appProcesses.polyCoords, []);
    });

    test('Remove a marker', () async {
      final mockLocation = Location(lat: 50.1109, lng: 8.6821);
      final mockGeometry = Geometry(location: mockLocation);
      final mockPlace =
          Place(geometry: mockGeometry, name: "Test", vicinity: "Test");
      final markerID = mockPlace.name;
      final marker1 = Marker(
          markerId: MarkerId(markerID),
          draggable: false,
          visible: true,
          infoWindow:
              InfoWindow(title: mockPlace.name, snippet: mockPlace.vicinity),
          position: LatLng(mockPlace.geometry.location.lat,
              mockPlace.geometry.location.lng));

      final addedMarker = appProcesses.markers;

      addedMarker.add(marker1);
      appProcesses.removeMarker(0);

      expect(addedMarker, []);
    });

    test('Timer is null', () async {
      Builder(builder: (BuildContext context) {
        appProcesses.drawNewRouteIfPossible(context);
        return Placeholder();
      });
      expect(appProcesses.timer?.isActive, null);
    });

    test('Bike stations length is 0', () async {
      Builder(builder: (BuildContext context) {
        appProcesses.drawNewRouteIfPossible(context);
        return Placeholder();
      });
      expect(appProcesses.bikeStations.length, 0);
    });

    test('Markers length is 0', () async {
      Builder(builder: (BuildContext context) {
        appProcesses.drawNewRouteIfPossible(context);
        return Placeholder();
      });
      expect(appProcesses.markers.length, 0);
    });

    test('Markers length is 1 after adding marker', () async {
      final mockLocation =
          Location(lat: 51.49419789342217, lng: -0.1324269658815591);
      final mockGeometry = Geometry(location: mockLocation);
      final mockPlace =
          Place(geometry: mockGeometry, name: "Test", vicinity: "Test");
      final markerID = mockPlace.name;
      final marker = Marker(
          markerId: MarkerId(markerID),
          draggable: false,
          visible: true,
          infoWindow:
              InfoWindow(title: mockPlace.name, snippet: mockPlace.vicinity),
          position: LatLng(mockPlace.geometry.location.lat,
              mockPlace.geometry.location.lng));

      appProcesses.currentLocation =
          await MockGeolocatorPlatform().getCurrentPosition();
      appProcesses.markers.add(marker);

      await Builder(builder: (BuildContext context) {
        appProcesses.drawNewRouteIfPossible(context);
        return Placeholder();
      });

      expect(appProcesses.markers.length, 1);
    });
  });
}

class MockGeolocatorPlatform extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        GeolocatorPlatform {
  @override
  Future<LocationPermission> checkPermission() =>
      Future.value(LocationPermission.whileInUse);

  @override
  Future<LocationPermission> requestPermission() =>
      Future.value(LocationPermission.whileInUse);

  @override
  Future<bool> isLocationServiceEnabled() => Future.value(true);

  @override
  Future<Position> getLastKnownPosition({
    bool forceLocationManager = false,
  }) =>
      Future.value(mockPosition);

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) =>
      Future.value(mockPosition);

  @override
  Stream<ServiceStatus> getServiceStatusStream() {
    return super.noSuchMethod(
      Invocation.method(
        #getServiceStatusStream,
        null,
      ),
      returnValue: Stream.value(ServiceStatus.enabled),
    );
  }

  @override
  Stream<Position> getPositionStream({
    LocationSettings? locationSettings,
  }) {
    return super.noSuchMethod(
      Invocation.method(
        #getPositionStream,
        null,
        <Symbol, Object?>{
          #desiredAccuracy: locationSettings?.accuracy ?? LocationAccuracy.best,
          #distanceFilter: locationSettings?.distanceFilter ?? 0,
          #timeLimit: locationSettings?.timeLimit ?? 0,
        },
      ),
      returnValue: Stream.value(mockPosition),
    );
  }

  @override
  Future<bool> openAppSettings() => Future.value(true);

  @override
  Future<LocationAccuracyStatus> getLocationAccuracy() =>
      Future.value(LocationAccuracyStatus.reduced);

  @override
  Future<LocationAccuracyStatus> requestTemporaryFullAccuracy({
    required String purposeKey,
  }) =>
      Future.value(LocationAccuracyStatus.reduced);

  @override
  Future<bool> openLocationSettings() => Future.value(true);

  @override
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) =>
      42;

  @override
  double bearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) =>
      42;
}
