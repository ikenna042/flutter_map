import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_map_flutter/directions_model.dart';
// import 'package:google_map_flutter/directions_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _initialCameraPosition =
      CameraPosition(target: LatLng(6.4584, 7.5464), zoom: 11.5);

  Completer<GoogleMapController> _googleMapController = Completer();
  Marker _origin;
  Marker _destination;
  Directions _info;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Maps'),
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: _goToOrigin,
              child: const Text('ORIGIN'),
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          if (_destination != null)
            TextButton(
              onPressed: _goToDestination,
              child: const Text('DEST'),
              style: TextButton.styleFrom(
                  primary: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Stack(alignment: Alignment.center, children: [
        GoogleMap(
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (GoogleMapController controller) =>
              _googleMapController.complete(controller),
          markers: {
            if (_origin != null) _origin,
            if (_destination != null) _destination
          },
          polylines: {
            if (_info != null)
              Polyline(
                polylineId: const PolylineId('overview_polyline'),
                color: Colors.red,
                width: 5,
                points: _info.polylinePoints
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList(),
              ),
          },
          onLongPress: _addMarker,
        ),
        if (_info != null)
          Positioned(
              top: 20.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ]),
                child: Text(
                  '${_info.totalDistance}, ${_info.totalDuration}',
                  style: const TextStyle(
                      fontSize: 18.0, fontWeight: FontWeight.w600),
                ),
              ))
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: _goToCenter,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  Future<void> _goToCenter() async {
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(_info != null
        ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
        : CameraUpdate.newCameraPosition(_initialCameraPosition));
  }

  Future<void> _goToOrigin() async {
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _origin.position, zoom: 14.5, tilt: 50.0)));
  }

  Future<void> _goToDestination() async {
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _destination.position, zoom: 14.5, tilt: 50.0)));
  }

  void _addMarker(LatLng pos) {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
        _destination = null;
        _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos);
      });

      // final directions = await DirectionsRepository()
      //     .getDirections(origin: _origin.position, destination: pos);
      // setState(() => _info = directions);
    }
  }
}
