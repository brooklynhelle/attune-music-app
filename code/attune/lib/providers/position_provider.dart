import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../providers/auth_provider.dart';


// This is the PositionProvider class from Food Finder. 
// Provides user's location, if permissions are given. 
class PositionProvider extends ChangeNotifier {
    // PositionProvider - the geolocator library (copied in) handles the talking to the GPS. 

    //  I just need the provider layer, which determinePosition bridges between my 
    //    state fields (_lat, _long, etc) and the geolocator library
    
    double _latitude = 0.0;
    double _longitude = 0.0;

    // reference to AuthProvider so we can write a user's location to 
    // firestore whenever we get an update from the GPS API
    AuthProvider? _authProvider;

    // whether positional data has been loaded or not
    bool posKnown = false;
    // if there's an error with loading data
    bool hasError = false;

    void notifyError() {
      hasError = true;
      notifyListeners();
  }

  // positionKnown getter 
  // good for edge case where nothing loads bc user denied permissions
  bool positionKnown() { 
    if (posKnown) {
      return true;
    }
    return false;
  }

  // this is here so we can call it from main to connect position provider to auth provider
  // bc we need to bc we have the location and also we need auth and then firestore to know abt it
  void setAuthProvider(AuthProvider auth) {
    _authProvider = auth;
  }

  // getter for latitude except I remember dart syntax now
  double get latitude => _latitude;

  // getter for longitude
  double get longitude => _longitude;

  // Creates a PositionProvider that loads in user's location data, which routinely updates 
  PositionProvider() {
    // initial call so you dont have to wait for timer 
    determinePosition().then((position) {
        // success! 
        _latitude = position.latitude;
        _longitude = position.longitude;
        posKnown = true;
        _authProvider?.updateLocation(_latitude, _longitude);
        notifyListeners();

      }).catchError((_) {
        // something went wrong
        posKnown = false;
        notifyListeners();
      });

    // ignore: unused_local_variable
    final positionCheckerTime = Timer.periodic(Duration(seconds: 60), (timer) {  
      determinePosition().then((position) {
        // success! 
        _latitude = position.latitude;
        _longitude = position.longitude;
        posKnown = true;
        _authProvider?.updateLocation(_latitude, _longitude);
        notifyListeners();

      }).catchError((_) {
        // something went wrong
        posKnown = false;
        notifyListeners();
      });
      
    });
  }

    // Determine the current position of the device.
    // 
    // When the location services are not enabled or permissions
    // are denied the `Future` will return an error.
    Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the 
        // App to enable the location services.
        return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale 
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
        }
    }
    
    if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately. 
        return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
    }

}