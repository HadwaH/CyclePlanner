import 'dart:convert';

import 'package:cycle_planner/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cycle_planner/models/groups.dart';
import 'package:cycle_planner/models/place_search.dart';
import 'package:cycle_planner/processes/application_processes.dart';
import 'package:cycle_planner/services/bike_station_service.dart';
import 'package:cycle_planner/services/places_service.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:cycle_planner/services/geolocator_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';




const String key = 'AIzaSyDHP-Fy593557yNJxow0ZbuyTDd2kJhyCY';

Position get mockPosition => Position(
    latitude: 52.561270,
    longitude: 5.639382,
    timestamp: DateTime.fromMillisecondsSinceEpoch(
      500,
      isUtc: true,
    ),
    altitude: 3000.0,
    accuracy: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0);

void main() {
  group('Geolocator', () {
    setUp(() {
      GeolocatorPlatform.instance = MockGeolocatorPlatform();
    });

    // Checks whether permission is enabled
    test('checkPermission', () async {
      final permission = await Geolocator.checkPermission();

      expect(permission, LocationPermission.whileInUse);
    });

    // Permission is requested
    test('requestPermission', () async {
      final permission = await Geolocator.requestPermission();

      expect(permission, LocationPermission.whileInUse);
    });

    // Check whether location service is enabled
    test('isLocationServiceEnabled', () async {
      final isLocationServiceEnabled =
      await Geolocator.isLocationServiceEnabled();

      expect(isLocationServiceEnabled, true);
    });

    // Last known location is given
    test('getLastKnownPosition', () async {
      final position = await Geolocator.getLastKnownPosition();

      expect(position, mockPosition);
    });

    // Current position is given
    test('getCurrentPosition', () async {
      final position = await Geolocator.getCurrentPosition();

      expect(position, mockPosition);
    });

    // Current position given for IOS
    test('getCurrentPosition iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final position = await Geolocator.getCurrentPosition();
      expect(position, mockPosition);
      debugDefaultTargetPlatformOverride = null;
    });

    // Accuracy of location is given
    test('getLocationAccuracy', () async {
      final accuracy = await Geolocator.getLocationAccuracy();

      expect(accuracy, LocationAccuracyStatus.reduced);
    });

    // Checks whether full accuracy is asked for
    test('requestTemporaryFullAccuracy', () async {
      final accuracy = await Geolocator.requestTemporaryFullAccuracy(
        purposeKey: "purposeKeyValue",
      );

      expect(accuracy, LocationAccuracyStatus.reduced);
    });

    // Service status is enabled
    test('getServiceStatusStream', () {
      when(GeolocatorPlatform.instance.getServiceStatusStream())
          .thenAnswer((_) => Stream.value(ServiceStatus.enabled));

      final locationService = Geolocator.getServiceStatusStream();

      expect(locationService,
          emitsInOrder([emits(ServiceStatus.enabled), emitsDone]));
    });

    test('getPositionStream', () {
      when(GeolocatorPlatform.instance.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: null,
          ))).thenAnswer((_) => Stream.value(mockPosition));

      final position = Geolocator.getPositionStream();

      expect(position, emitsInOrder([emits(mockPosition), emitsDone]));
    });

    // Check if app settings is opened
    test('openAppSettings', () async {
      final hasOpened = await Geolocator.openAppSettings();
      expect(hasOpened, true);
    });

    // Checks if location settings is open
    test('openLocationSettings', () async {
      final hasOpened = await Geolocator.openLocationSettings();
      expect(hasOpened, true);
    });

    // Distance between the locations given
    test('distanceBetween', () {
      final distance = Geolocator.distanceBetween(0, 0, 0, 0);
      expect(distance, 42);
    });

    // Bearings given between locations
    test('bearingBetween', () {
      final bearing = Geolocator.bearingBetween(0, 0, 0, 0);
      expect(bearing, 42);
    });
  });

//
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