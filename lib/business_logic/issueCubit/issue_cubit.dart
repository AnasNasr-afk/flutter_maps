import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/business_logic/issueCubit/issue_states.dart';
import 'package:flutter_maps/data/models/issue_model.dart';
import 'package:flutter_maps/data/models/user_model.dart';
import 'package:flutter_maps/helpers/notification_helper.dart';
import 'package:flutter_maps/presentation/widgets/app_markers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../mapCubit/map_cubit.dart';

class IssueCubit extends Cubit<IssueStates> {
  IssueCubit() : super(IssueInitialState());

  static IssueCubit get(context) => BlocProvider.of(context);

  File? imageFile;
  File? resolvedImageFile;
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

  // --- Select Category ---
  void selectCategory(String? category) {
    selectedCategory = category;
    emit(IssueInitialState()); // Trigger UI update
  }

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
    final cubit = MapCubit.get(context);

    if (selectedCategory == null) {
      emit(IssueSubmitFailureState('Please select a category'));
      return;
    }

    if (imageFile == null) {
      emit(IssueSubmitFailureState('Please pick an image'));
      return;
    }

    if (currentPosition == null) {
      emit(IssueSubmitFailureState(
          'Location not available. Please enable location services.'));
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
            child: const Text('Yes', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    emit(IssueSubmittingState());

    final locationLat = currentPosition!.latitude;
    final locationLng = currentPosition!.longitude;
    final locationString = '$locationLat,$locationLng';

    try {
      String imageValue;

      // Compress and encode image to Base64
      try {
        final tempDir = Directory.systemTemp;
        final compressedPath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          imageFile!.path,
          compressedPath,
          quality: 50,
          minWidth: 800,
          minHeight: 600,
        );

        if (compressedImage == null) {
          throw Exception('Image compression failed');
        }

        final imageBytes = await compressedImage.readAsBytes();
        final imageSizeKB = imageBytes.length / 1024;
        if (imageSizeKB > 750) {
          debugPrint(
              'Compressed image size: ${imageSizeKB}KB, may exceed Firestore limit');
          emit(IssueSubmitFailureState(
              'Image too large after compression. Try a smaller image.'));
          return;
        }

        imageValue = base64Encode(imageBytes);
        await File(compressedImage.path).delete();
      } catch (e) {
        debugPrint('Image compression/encoding failed: $e');
        emit(IssueSubmitFailureState(
            'Failed to process image. Please try a smaller image.'));
        return;
      }

      final issue = IssueModel(
        userName: currentUser.name,
        uId: currentUser.uid,
        category: selectedCategory!,
        description: description,
        location: locationString,
        image: imageValue,
        userEmail: currentUser.email,
        status: IssueStatus.pending,
      );

      await FirebaseFirestore.instance.collection('issues').add(issue.toJson());

      final marker = AppMarkers.buildIssueMarker(
        latitude: locationLat,
        longitude: locationLng,
        category: selectedCategory!,
        description: description,
        showInfoWindow: !cubit.isAdminChecked,
        status: issue.status.name, // ✅ Use consistent status color
      );
      cubit.addSearchMarker(marker);

      imageFile = null;
      selectedCategory = null;
      currentPosition = null;
      try {
        await NotificationHelper.notifyAdmins(
          "📢 New Issue Submitted",
          "${currentUser.name} just submitted an issue !",
        );

      } catch (e) {
        debugPrint('❌ Notification failed: $e'); // ⬅️ Likely failure here
      }
      final adminUsersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      for (final doc in adminUsersSnapshot.docs) {
        final adminId = doc.id;
        await NotificationHelper.addInAppNotification(
          userId: adminId,
          title: 'New Issue Submitted',
          message: '${currentUser.name} submitted a new issue.',
        );
      }
      emit(IssueSubmitSuccessState());
    } catch (e) {
      debugPrint('Issue submission failed: $e');
      emit(
          IssueSubmitFailureState('Failed to submit issue. Please try again.'));
    }
  }

  Future<void> updateIssueStatus(String docId, String newStatus, {File? adminImage}) async {
    emit(UpdateIssueLoadingState());

    try {
      String? imageBase64;

      if (adminImage != null) {
        final tempDir = Directory.systemTemp;
        final compressedPath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';

        final compressedImage = await FlutterImageCompress.compressAndGetFile(
          adminImage.path,
          compressedPath,
          quality: 20,
          minWidth: 640,
          minHeight: 480,
        );

        if (compressedImage == null) {
          debugPrint('❌ Admin image compression failed');
          emit(UpdateIssueErrorState('Failed to compress image.'));
          return;
        }

        final bytes = await compressedImage.readAsBytes();
        final imageSizeKB = bytes.length / 1024;

        if (imageSizeKB > 950) {
          emit(UpdateIssueErrorState('Image too large even after compression.'));
          return;
        }

        imageBase64 = base64Encode(bytes);
        await File(compressedImage.path).delete();
      }

      final dataToUpdate = {
        'status': newStatus,
        if (imageBase64 != null) 'adminResolvedImage': imageBase64,
      };

      await FirebaseFirestore.instance
          .collection('issues')
          .doc(docId)
          .update(dataToUpdate);

      // ✅ Notify the user who submitted the issue
      final issueSnapshot = await FirebaseFirestore.instance
          .collection('issues')
          .doc(docId)
          .get();

      if (issueSnapshot.exists) {
        final uId = issueSnapshot.data()?['uId'];
        if (uId != null) {
          final userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(uId)
              .get();

          if (userSnapshot.exists) {
            final token = userSnapshot.data()?['fcmToken'];
            final userName = userSnapshot.data()?['name'] ?? "User";

            if (token != null && token is String && token.isNotEmpty) {
              await NotificationHelper.sendNotification(
                'Issue Update',
                'Hi $userName, your issue status is now "$newStatus"',
                token,
              );
              await NotificationHelper.addInAppNotification(
                userId: uId,
                title: 'Issue Status Updated',
                message: 'Your issue status is now "$newStatus".',
              );

            } else {
              debugPrint('⚠️ No FCM token found for user $uId');
            }
          }
        }
      }

      emit(UpdateIssueSuccessState());
    } catch (e) {
      debugPrint('❌ Firestore update failed: $e');
      emit(UpdateIssueErrorState(e.toString()));
    }
  }


  Future<void> pickResolvedImage(ImageSource imageSource) async {
    emit(ResolvedImagePickerLoadingState());
    try {
      var pickedFile = await imagePicker.pickImage(source: imageSource);
      if (pickedFile != null) {
        resolvedImageFile = File(pickedFile.path);
        debugPrint('Resolved image selected: ${pickedFile.path}');
        emit(ResolvedImagePickerSuccessState());
      } else {
        debugPrint('Picked file is empty');
        emit(ResolvedImagePickerErrorState('No image selected'));
      }
    } catch (e) {
      debugPrint('Error picking resolved image: $e');
      emit(ResolvedImagePickerErrorState(e.toString()));
    }
  }

  void clearResolvedImage() {
    resolvedImageFile = null;
    emit(ResolvedImagePickerSuccessState());
  }
}
