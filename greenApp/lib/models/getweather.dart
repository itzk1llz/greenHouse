import 'package:http/http.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

WeatherFactory wf = new WeatherFactory("47ff493c1faaa503487e53191c610522");

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if(!serviceEnabled) {
    return Future.error("Location services are disabled.");
  }
  permission = await Geolocator.checkPermission();

  if(permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if(permission == LocationPermission.denied) {
      return Future.error("Location permissions are denied.");
    }
  }

  if(permission == LocationPermission.deniedForever) {
    return Future.error (
      "Location permissions are permanently denied."
    );

  }
  return await Geolocator.getCurrentPosition();

}