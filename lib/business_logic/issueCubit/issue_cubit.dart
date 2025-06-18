import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/issueCubit/issue_states.dart';
import 'package:flutter_maps/data/models/issue_model.dart';
import 'package:flutter_maps/data/models/user_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../presentation/widgets/app_markers.dart';
import '../mapCubit/map_cubit.dart';

class IssueCubit extends Cubit<IssueStates> {


  IssueCubit() : super(IssueInitialState());

  static IssueCubit get(context) => BlocProvider.of(context);

  File? imageFile;
  ImagePicker imagePicker = ImagePicker();
  String? selectedCategory;
  Position? currentPosition;
  Set<Marker> markers = {};

  final List<String> categories = [
    'Trash',
    'Broken Street Area',
    'Water Leak',
    'Parking Issue',
    'Other',
  ];

  // --- Image Picker ---
  Future<void> imagePickerPhoto(ImageSource imageSource) async {
    emit(ImagePickerLoadingState());
    try {
      var pickedFile = await imagePicker.pickImage(source: imageSource);
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        debugPrint('Image selected: ${pickedFile.path}');
        emit(ImagePickerSuccessState());
      } else {
        debugPrint('Picked file is empty');
        emit(ImagePickerErrorState());
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      emit(ImagePickerErrorState());
    }
  }

  // --- Crop Image ---
  Future<void> cropImage(BuildContext context, File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      this.imageFile = File(croppedFile.path);
      emit(ImagePickerSuccessState());
    } else {
      emit(ImagePickerErrorState());
    }
  }

  // --- Fetch Current Location ---
  Future<void> fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        emit(LocationErrorState('Location services are disabled.'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          emit(LocationErrorState('Location permissions are denied'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        emit(LocationErrorState('Location permissions are permanently denied'));
        return;
      }

      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      debugPrint(
          'Current position fetched: Lat=${currentPosition!.latitude}, Lng=${currentPosition!.longitude}');
      emit(LocationLoadedState());
    } catch (e) {
      debugPrint('Error fetching location: $e');
      emit(LocationErrorState(e.toString()));
    }
  }


  Future<void> submitIssue({
    required BuildContext context,
    required String description,
    required UserModel currentUser,
  }) async {
    if (selectedCategory == null) {
      emit(IssueSubmitFailureState('Please select a category'));
      return;
    }

    if (imageFile == null) {
      emit(IssueSubmitFailureState('Please pick an image'));
      return;
    }

    if (currentPosition == null) {
      emit(IssueSubmitFailureState('Location not available. Please enable location services.'));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Confirm Submission'),
        content: const Text('Are you sure you want to submit this issue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
                'Yes',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
                'No',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    emit(IssueSubmittingState());

    final locationLat = currentPosition!.latitude;
    final locationLng = currentPosition!.longitude;

    try {
      final currentLocation = '$locationLat,$locationLng';

      final issue = IssueModel(
        userName: currentUser.name,
        uId: currentUser.uid,
        category: selectedCategory!,
        description: description,
        location: currentLocation,
        image: imageFile!.path,
      );

      await FirebaseFirestore.instance.collection('issues').add(issue.toJson());

      final marker = AppMarkers.buildIssueMarker(
        latitude: locationLat,
        longitude: locationLng,
        category: selectedCategory!,
        description: description,
      );


      // ✅ ADD TO MAP CUBIT
      MapCubit.get(context).addSearchMarker(marker);

      // ✅ Reset state
      imageFile = null;
      selectedCategory = null;
      currentPosition = null;

      emit(IssueSubmitSuccessState());
    } catch (e) {
      debugPrint('Issue submission failed: $e');
      emit(IssueSubmitFailureState('Failed to submit issue. Please try again.'));
    }
  }



}



