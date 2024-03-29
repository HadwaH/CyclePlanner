import 'package:cycle_planner/models/bikestation.dart';
import 'package:cycle_planner/services/marker_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cycle_planner/models/location.dart';
import 'package:cycle_planner/models/geometry.dart';
import 'package:cycle_planner/models/place.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MarkerService serviceMarker = MarkerService();

  group('MarkerService', () {
    test('Null value given when bound is empty', () async {
      // final boundsGiven = serviceMarker.bounds(<Marker>{});

      expect(serviceMarker.bounds(<Marker>{}), null);
    });
    test('create bounds method return', () async {
      var m1 = const LatLng(50.1108, 8.6821);
      var m2 = const LatLng(54.1108, 8.3821);
      List<LatLng> positions = [];
      positions.add(m1);
      positions.add(m2);
      expect(serviceMarker.createBounds(positions), isA<LatLngBounds>());
    });

    test('Create Marker from Place given', () async {
      final mockLocation = Location(lat: 50.1109, lng: 8.6821);
      final mockGeometry = Geometry(location: mockLocation);
      final mockPlace =
          Place(geometry: mockGeometry, name: "Test", vicinity: "Test");
      final markerID = mockPlace.name;
      final createMarker = serviceMarker.createMarkerFromPlace(mockPlace);
      expect(
          createMarker,
          Marker(
              markerId: MarkerId(markerID),
              draggable: false,
              visible: true,
              infoWindow: InfoWindow(
                  title: mockPlace.name, snippet: mockPlace.vicinity),
              position: LatLng(mockPlace.geometry.location.lat,
                  mockPlace.geometry.location.lng)));
    });

    test('create marker', () async {
      serviceMarker.setBikeMarkerIcon();
      serviceMarker.bikeMarker = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(
            devicePixelRatio: 2.0,
            size: Size(2.0, 2.0),
          ),
          'assets/bike-marker.png');

      var station =
          BikeStation(id: "test", commonName: "test", lat: 55, lon: 0.15);

      expect(serviceMarker.createBikeMarker(station), isA<Marker>());
    });
  });
}
