import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cycle_planner/widgets/google_map_page.dart';
import 'package:cycle_planner/widgets/bottom_navbar.dart';
import 'package:cycle_planner/widgets/nav_bar.dart';
import 'package:cycle_planner/processes/application_processes.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    final applicationProcesses = Provider.of<ApplicationProcesses>(context);
    return SafeArea(
      bottom: true,
      child: Scaffold(
        key: scaffoldKey,
        extendBody: true,
        drawer: const NavBar(),
        body: (applicationProcesses.currentLocation == null) ? const Center(child: CircularProgressIndicator())
        :GoogleMapPage(mapController: _mapController, applicationProcesses: applicationProcesses),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final GoogleMapController controller = await _mapController.future;
            setState(() {
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(
                      applicationProcesses.currentLocation!.latitude,
                      applicationProcesses.currentLocation!.longitude
                    ),
                    zoom: 14.0,
                  ),
                ),
              );
            });
          },
          child: const Icon(Icons.my_location),
          backgroundColor: Colors.redAccent,
        ),
        bottomNavigationBar: BottomNavBar(scaffoldKey: scaffoldKey),
      ),
    );
  }
}





  // // Hard coded waypoints for testing purposes
  // final _origin = WayPoint(
  //   name: "Big Ben",
  //   latitude: 51.500863,
  //   longitude: -0.124593
  // );

  // final _stop1 = WayPoint(
  //   name: "Buckingham Palace",
  //   latitude: 51.50204176039292,
  //   longitude: -0.14188788458748477
  // );

  // final _stop2 = WayPoint(
  //   name: "British Museum",
  //   latitude: 51.521285300295474,
  //   longitude: -0.126953347081018
  // );

  // final _stop3 = WayPoint(
  //   name: "Trafalgar Square",
  //   latitude: 51.50809338374528,
  //   longitude: -0.12804891498586773
  // );

  // final _stop4 = WayPoint(
  //   name: "London Eye",
  //   latitude: 51.50461919293181,
  //   longitude: -0.11954631306912968
  // );

  // final marker1 = const Marker(
  //   markerId: MarkerId("London eye"),
  //   position: LatLng(51.50461919293181, -0.11954631306912968)
  // );

  // final marker2 = const Marker(
  //   markerId: MarkerId("Trafalgar Square"),
  //   position: LatLng(51.50809338374528, -0.12804891498586773)
  // );

  // final marker3 = const Marker(
  //   markerId: MarkerId("museum"),
  //   position: LatLng(51.50809338374528, -0.126953347081018)
  // );

  // final marker5 = const Marker(
  //   markerId: MarkerId("knightsbridge"),
  //   position: LatLng(51.50809338374528, -0.16162)
  // );

 // //method to draw route overview
  // //will assume the first 2 and last markers are for getting to the bike stations
  // Future<void> drawRouteOverview()  async {
  //   Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   //some dummy data
  //   final marker4 = Marker(
  //       markerId: const MarkerId("current"),
  //       position: LatLng(position.latitude, position.longitude)
  //   );
  //   //adds markers to the list of markers
  //   _markers.add(marker4);
  //   _markers.add(marker1);
  //   _markers.add(marker2);
  //   _markers.add(marker3);
  //   _markers.add(marker5);
  //   //will go through list of markers
  //   for(var i = 1; i < _markers.length; i++){
  //       late PolylinePoints polylinePoints;
  //       polylinePoints = PolylinePoints();
  //       final markerS = _markers.elementAt(i - 1);
  //       final markerd = _markers.elementAt(i);
  //       final PointLatLng marker1 = PointLatLng(markerd.position.latitude, markerd.position.longitude);
  //       final PointLatLng marker2 = PointLatLng(markerS.position.latitude, markerS.position.longitude);
  //       //gets a set of coordinates between 2 markers
  //       PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //           "AIzaSyDHP-Fy593557yNJxow0ZbuyTDd2kJhyCY",
  //           marker1,
  //           marker2,
  //           travelMode: TravelMode.bicycling,);
  //       //drawing route to bike stations
  //       late List<LatLng> nPoints = [];
  //       double stuff = 0;
  //       for (var point in result.points) {
  //         nPoints.add(LatLng(point.latitude, point.longitude));
  //         stuff = point.latitude + point.longitude;
  //       }
  //       //adds stuff to polyline
  //       //if its a cycle path line is red otherwise line is blue
  //       if (i == 1 || i == _markers.length - 1){
  //         _polyline.add(Polyline(
  //           polylineId: PolylineId(stuff.toString()),
  //           points: nPoints,
  //           color: Colors.red
  //       ));
  //     }
  //       else{
  //         _polyline.add(Polyline(
  //             polylineId: PolylineId(stuff.toString()),
  //             points: nPoints,
  //             color: Colors.blue
  //         ));
  //       }

  //   }
  //   setState(() {

  //   });
  // }

  // // Creates alert if there are no available bike stations nearby.
  // Future<void> _showNoStationsAlert(context) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Oh no...'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: const <Widget>[
  //               Text('Looks like there are no available bike stations nearby.'),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Ok'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void updateClosestStations() async {
  //   // Find closest start station
  //   WayPoint start = wayPoints.first;
  //   // These are random coords in East that don't have any bike stations nearby.
  //   //Future<Map> futureOfStartStation = bikeStationService.getStationWithBikes(51.54735235426037, 0.08849463623212586, groupSize.getGroupSize());
  //   Future<Map> futureOfStartStation = bikeStationService.getStationWithBikes(start.latitude, start.longitude, groupSize.getGroupSize());
  //   Map startStation = await futureOfStartStation;

  //   // Find closest end station
  //   WayPoint end = wayPoints[wayPoints.length - 2];
  //   Future<Map> futureOfEndStation = BikeStationService().getStationWithSpaces(
  //       end.latitude, end.longitude, groupSize.getGroupSize());
  //   Map endStation = await futureOfEndStation;

  //   // check if there are available bike stations nearby. If not the user is alerted.
  //   if (startStation.isEmpty || endStation.isEmpty) {
  //     // if there are no close available bike stations I was gonna exit the navigation and display an alert,
  //     // but a station might free up in the next time interval so not sure what to do here...
  //   }
  //   else {
  //     // check if stations have changed.
  //     if ((startStation['lat'] != wayPoints[1].latitude && startStation['lon'] != wayPoints[1].longitude) || (endStation['lat'] != wayPoints[wayPoints.length - 1].latitude && endStation['lon'] != wayPoints[wayPoints.length - 1].longitude)) {
  //       // update stations to new stations.
  //       WayPoint startStationWayPoint = WayPoint(
  //           name: "startStation",
  //           latitude: startStation['lat'],
  //           longitude: startStation['lon']
  //       );
  //       wayPoints[1] = startStationWayPoint;

  //       WayPoint endStationWayPoint = WayPoint(
  //           name: "endStation",
  //           latitude: endStation['lat'],
  //           longitude: endStation['lon']
  //       );
  //       wayPoints[wayPoints.length - 1] = endStationWayPoint;

  //       // exit turn by turn navigation and then start again with new waypoints.
  //       _directions.finishNavigation();
  //       _directions.startNavigation(wayPoints: wayPoints, options: _options);
  //     }
  //   }
  // }