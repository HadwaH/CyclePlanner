import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widget_tests/fake_maps_controllers.dart';

Widget _mapWithPolygons(Set<Polygon> polygons) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      polygons: polygons,
    ),
  );
}

List<LatLng> _rectPoints({
  required double size,
  LatLng center = const LatLng(0, 0),
}) {
  final double halfSize = size / 2;

  return <LatLng>[
    LatLng(center.latitude + halfSize, center.longitude + halfSize),
    LatLng(center.latitude - halfSize, center.longitude + halfSize),
    LatLng(center.latitude - halfSize, center.longitude - halfSize),
    LatLng(center.latitude + halfSize, center.longitude - halfSize),
  ];
}

Polygon _polygonWithPointsAndHole(PolygonId polygonId) {
  _rectPoints(size: 1);
  return Polygon(
    polygonId: polygonId,
    points: _rectPoints(size: 1),
    holes: <List<LatLng>>[_rectPoints(size: 0.5)],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FakePlatformViewsController fakePlatformViewsController =
  FakePlatformViewsController();

  setUpAll(() {
    SystemChannels.platform_views.setMockMethodCallHandler(
        fakePlatformViewsController.fakePlatformViewsMethodHandler);
  });

  setUp(() {
    fakePlatformViewsController.reset();
  });
// initializing a polygon
  testWidgets('Initializing a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon initializedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(initializedPolygon, equals(p1));
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });
// adding a polygon
  testWidgets('Adding a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p2}));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToAdd.length, 1);

    final Polygon addedPolygon = platformGoogleMap.polygonsToAdd.first;
    expect(addedPolygon, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
  });
// removing a polygon
  testWidgets('Removing a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{}));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonIdsToRemove.length, 1);
    expect(platformGoogleMap.polygonIdsToRemove.first, equals(p1.polygonId));

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
// updating a polygon
  testWidgets('Updating a polygon', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 =
    Polygon(polygonId: PolygonId('polygon_1'), geodesic: true);

    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p2}));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p2));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
// mutate a polygon
  testWidgets('Mutate a polygon', (WidgetTester tester) async {
    final List<LatLng> _points = <LatLng>[const LatLng(0.0, 0.0)];
    final Polygon p1 = Polygon(
      polygonId: const PolygonId('polygon_1'),
      points: _points,
    );
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    p1.points.add(const LatLng(1.0, 1.0));
    await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;
    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToChange.first, equals(p1));

    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
//updating a polygon
  testWidgets('Multi Update', (WidgetTester tester) async {
    Polygon p1 = const Polygon(polygonId: PolygonId('polygon_1'));
    Polygon p2 = const Polygon(polygonId: PolygonId('polygon_2'));
    final Set<Polygon> prev = <Polygon>{p1, p2};
    p1 = const Polygon(polygonId: PolygonId('polygon_1'), visible: false);
    p2 = const Polygon(polygonId: PolygonId('polygon_2'), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange, cur);
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
// updating the polygon
  testWidgets('Multi Update', (WidgetTester tester) async {
    Polygon p2 = const Polygon(polygonId: PolygonId('polygon_2'));
    const Polygon p3 = Polygon(polygonId: PolygonId('polygon_3'));
    final Set<Polygon> prev = <Polygon>{p2, p3};

    // p1 is added, p2 is updated, p3 is removed.
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    p2 = const Polygon(polygonId: PolygonId('polygon_2'), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange.length, 1);
    expect(platformGoogleMap.polygonsToAdd.length, 1);
    expect(platformGoogleMap.polygonIdsToRemove.length, 1);

    expect(platformGoogleMap.polygonsToChange.first, equals(p2));
    expect(platformGoogleMap.polygonsToAdd.first, equals(p1));
    expect(platformGoogleMap.polygonIdsToRemove.first, equals(p3.polygonId));
  });
// partially opdating the polygon
  testWidgets('Partial Update', (WidgetTester tester) async {
    const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
    const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));
    Polygon p3 = const Polygon(polygonId: PolygonId('polygon_3'));
    final Set<Polygon> prev = <Polygon>{p1, p2, p3};
    p3 = const Polygon(polygonId: PolygonId('polygon_3'), geodesic: true);
    final Set<Polygon> cur = <Polygon>{p1, p2, p3};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange, <Polygon>{p3});
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
// updating non platform related attributes
  testWidgets('Update non platform related attr', (WidgetTester tester) async {
    Polygon p1 = const Polygon(polygonId: PolygonId('polygon_1'));
    final Set<Polygon> prev = <Polygon>{p1};
    p1 = Polygon(
        polygonId: const PolygonId('polygon_1'), onTap: () => print(2 + 2));
    final Set<Polygon> cur = <Polygon>{p1};

    await tester.pumpWidget(_mapWithPolygons(prev));
    await tester.pumpWidget(_mapWithPolygons(cur));

    final FakePlatformGoogleMap platformGoogleMap =
    fakePlatformViewsController.lastCreatedView!;

    expect(platformGoogleMap.polygonsToChange.isEmpty, true);
    expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
    expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
  });
// initializing a polygon with point hole
  testWidgets('Initializing a polygon with points and hole',
          (WidgetTester tester) async {
        final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));
        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
        expect(platformGoogleMap.polygonsToAdd.length, 1);

        final Polygon initializedPolygon = platformGoogleMap.polygonsToAdd.first;
        expect(initializedPolygon, equals(p1));
        expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
        expect(platformGoogleMap.polygonsToChange.isEmpty, true);
      });
// Adding a polygon with points and hole
  testWidgets('Adding a polygon with points and hole',
          (WidgetTester tester) async {
        const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
        final Polygon p2 = _polygonWithPointsAndHole(const PolygonId('polygon_2'));

        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1, p2}));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
        expect(platformGoogleMap.polygonsToAdd.length, 1);

        final Polygon addedPolygon = platformGoogleMap.polygonsToAdd.first;
        expect(addedPolygon, equals(p2));

        expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);

        expect(platformGoogleMap.polygonsToChange.isEmpty, true);
      });
// Removing a polygon with points and hole
  testWidgets('Removing a polygon with points and hole',
          (WidgetTester tester) async {
        final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));

        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
        await tester.pumpWidget(_mapWithPolygons(<Polygon>{}));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
        expect(platformGoogleMap.polygonIdsToRemove.length, 1);
        expect(platformGoogleMap.polygonIdsToRemove.first, equals(p1.polygonId));

        expect(platformGoogleMap.polygonsToChange.isEmpty, true);
        expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
      });
// Updating a polygon by adding points and hole
  testWidgets('Updating a polygon by adding points and hole',
          (WidgetTester tester) async {
        const Polygon p1 = Polygon(polygonId: PolygonId('polygon_1'));
        final Polygon p2 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));

        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));
        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p2}));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
        expect(platformGoogleMap.polygonsToChange.length, 1);
        expect(platformGoogleMap.polygonsToChange.first, equals(p2));

        expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
        expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
      });
 // Mutate a polygon with points and holes
  testWidgets('Mutate a polygon with points and holes',
          (WidgetTester tester) async {
        final Polygon p1 = Polygon(
          polygonId: const PolygonId('polygon_1'),
          points: _rectPoints(size: 1),
          holes: <List<LatLng>>[_rectPoints(size: 0.5)],
        );
        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

        p1.points
          ..clear()
          ..addAll(_rectPoints(size: 2));
        p1.holes
          ..clear()
          ..addAll(<List<LatLng>>[_rectPoints(size: 1)]);
        await tester.pumpWidget(_mapWithPolygons(<Polygon>{p1}));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;
        expect(platformGoogleMap.polygonsToChange.length, 1);
        expect(platformGoogleMap.polygonsToChange.first, equals(p1));

        expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
        expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
      });
// Multi Update polygons with points and hole
  testWidgets('Multi Update polygons with points and hole',
          (WidgetTester tester) async {
        Polygon p1 = const Polygon(polygonId: PolygonId('polygon_1'));
        Polygon p2 = Polygon(
          polygonId: const PolygonId('polygon_2'),
          points: _rectPoints(size: 2),
          holes: <List<LatLng>>[_rectPoints(size: 1)],
        );
        final Set<Polygon> prev = <Polygon>{p1, p2};
        p1 = const Polygon(polygonId: PolygonId('polygon_1'), visible: false);
        p2 = p2.copyWith(
          pointsParam: _rectPoints(size: 5),
          holesParam: <List<LatLng>>[_rectPoints(size: 2)],
        );
        final Set<Polygon> cur = <Polygon>{p1, p2};

        await tester.pumpWidget(_mapWithPolygons(prev));
        await tester.pumpWidget(_mapWithPolygons(cur));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

        expect(platformGoogleMap.polygonsToChange, cur);
        expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
        expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
      });
// Multi Update polygons with points and hole
  testWidgets('Multi Update polygons with points and hole',
          (WidgetTester tester) async {
        Polygon p2 = Polygon(
          polygonId: const PolygonId('polygon_2'),
          points: _rectPoints(size: 2),
          holes: <List<LatLng>>[_rectPoints(size: 1)],
        );
        const Polygon p3 = Polygon(polygonId: PolygonId('polygon_3'));
        final Set<Polygon> prev = <Polygon>{p2, p3};

        // p1 is added, p2 is updated, p3 is removed.
        final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));
        p2 = p2.copyWith(
          pointsParam: _rectPoints(size: 5),
          holesParam: <List<LatLng>>[_rectPoints(size: 3)],
        );
        final Set<Polygon> cur = <Polygon>{p1, p2};

        await tester.pumpWidget(_mapWithPolygons(prev));
        await tester.pumpWidget(_mapWithPolygons(cur));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

        expect(platformGoogleMap.polygonsToChange.length, 1);
        expect(platformGoogleMap.polygonsToAdd.length, 1);
        expect(platformGoogleMap.polygonIdsToRemove.length, 1);

        expect(platformGoogleMap.polygonsToChange.first, equals(p2));
        expect(platformGoogleMap.polygonsToAdd.first, equals(p1));
        expect(platformGoogleMap.polygonIdsToRemove.first, equals(p3.polygonId));
      });
// Partial Update polygons with points and hole
  testWidgets('Partial Update polygons with points and hole',
          (WidgetTester tester) async {
        final Polygon p1 = _polygonWithPointsAndHole(const PolygonId('polygon_1'));
        const Polygon p2 = Polygon(polygonId: PolygonId('polygon_2'));
        Polygon p3 = Polygon(
          polygonId: const PolygonId('polygon_3'),
          points: _rectPoints(size: 2),
          holes: <List<LatLng>>[_rectPoints(size: 1)],
        );
        final Set<Polygon> prev = <Polygon>{p1, p2, p3};
        p3 = p3.copyWith(
          pointsParam: _rectPoints(size: 5),
          holesParam: <List<LatLng>>[_rectPoints(size: 3)],
        );
        final Set<Polygon> cur = <Polygon>{p1, p2, p3};

        await tester.pumpWidget(_mapWithPolygons(prev));
        await tester.pumpWidget(_mapWithPolygons(cur));

        final FakePlatformGoogleMap platformGoogleMap =
        fakePlatformViewsController.lastCreatedView!;

        expect(platformGoogleMap.polygonsToChange, <Polygon>{p3});
        expect(platformGoogleMap.polygonIdsToRemove.isEmpty, true);
        expect(platformGoogleMap.polygonsToAdd.isEmpty, true);
      });
}