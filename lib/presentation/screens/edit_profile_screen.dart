import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';

import '../../helpers/color_manager.dart';
import '../../helpers/components.dart';
import '../widgets/app_text_form_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  bool _imageChanged = false;

  File? _imageFile;
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  Future<void> _loadUserData() async {
    try {
      final doc = await firestore.collection("users").doc(user!.uid).get();
      final data = doc.data();

      final name = data?['name'] ?? user?.displayName ?? '';
      final phone = data?['phone'] ?? '';
      final base64String = data?['profileImageBase64'];

      File? imageFile;
      String? base64Image;

      if (base64String != null && base64String.isNotEmpty) {
        final bytes = base64Decode(base64String);
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/temp_image.jpg');
        await file.writeAsBytes(bytes, flush: true);
        imageFile = file;
        base64Image = base64String;
      }


      setState(() {
        _nameController.text = name;
        _phoneController.text = phone;
        _imageFile = imageFile;
        _base64Image = base64Image;
        _imageChanged = false; // reset on refresh
      });

    } catch (e) {
      debugPrint("Error loading user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to refresh profile")),
      );
    }
  }


  Future<void> _showImageSourceSheet() async {
    await showAdaptiveActionSheet(
      context: context,
      title: Text('Avoid uploading sensitive images', style: TextStyle(fontSize: 12.sp)),
      actions: [
        BottomSheetAction(
          title: Text('Take a photo', style: TextStyle(color: Colors.blue, fontSize: 18.sp)),
          onPressed: (_) async {
            Navigator.pop(context);
            await _pickImage(ImageSource.camera);
          },
        ),
        BottomSheetAction(
          title: Text('Choose from gallery', style: TextStyle(color: Colors.blue, fontSize: 18.sp)),
          onPressed: (_) async {
            Navigator.pop(context);
            await _pickImage(ImageSource.gallery);
          },
        ),
      ],
      cancelAction: CancelAction(
        title: Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 18.sp)),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 85);

      if (pickedFile == null) return;

      final String compressedPath = '${pickedFile.path}_compressed.jpg';

      final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        pickedFile.path,
        compressedPath,
        quality: 60,
        minWidth: 600,
        minHeight: 600,
      );

      if (compressedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image compression failed")),
        );
        return;
      }

      final Uint8List imageBytes = await compressedFile.readAsBytes();
      final double imageSizeKb = imageBytes.lengthInBytes / 1024;

      if (imageSizeKb > 900) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image too large, choose a smaller one")),
        );
        return;
      }

      setState(() {
        _imageFile = File(compressedFile.path);
        _base64Image = base64Encode(imageBytes);
        _imageChanged = true; // ✅ image was changed
      });

    } catch (e) {
      debugPrint("Image compression failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong while selecting image")),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _base64Image = null;
      _imageChanged = true; // ✅ image was removed
    });

  }

  Future<void> _saveChanges() async {
    showAppLoadingDialog(context);

    final Map<String, dynamic> updatedData = {
      'name': _nameController.text.trim(),
      'email': user?.email,
    };

    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      updatedData['phone'] = phone;
    }

    if (_imageChanged) {
      if (_base64Image != null) {
        updatedData['profileImageBase64'] = _base64Image!;
      } else {
        updatedData['profileImageBase64'] = FieldValue.delete();
      }
    }

    try {
      await user?.updateDisplayName(_nameController.text.trim());
      await user?.reload();

      final ref = firestore.collection("users").doc(user!.uid);
      final doc = await ref.get();

      if (doc.exists) {
        await ref.update(updatedData);
      } else {
        await ref.set(updatedData);
      }

      // ✅ Force UI update by calling setState after reloading data
      final newDoc = await firestore.collection("users").doc(user!.uid).get();
      final newData = newDoc.data();

      setState(() {
        _nameController.text = newData?['name'] ?? '';
        _phoneController.text = newData?['phone'] ?? '';

        final base64String = newData?['profileImageBase64'];
        if (base64String != null && base64String is String && base64String.isNotEmpty) {
          final bytes = base64Decode(base64String);
          final tempDir = Directory.systemTemp;
          final file = File('${tempDir.path}/temp_image.jpg');
          file.writeAsBytesSync(bytes);
          _imageFile = file;
          _base64Image = base64String;
        } else {
          _imageFile = null;
          _base64Image = null;
        }

        _imageChanged = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
    } catch (e) {
      debugPrint("Save failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      Navigator.pop(context);
    }


  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ColorManager.gradientStart, ColorManager.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.blue,
        backgroundColor: Colors.white,
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          key: ValueKey(_base64Image ?? 'no-image'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _imageFile != null
                         ? FileImage(_imageFile!)
                          : null,
                      child: (_imageFile == null)
                          ? Icon(Icons.person, size: 40.sp, color: Colors.grey)
                          : null,
                    ),
                  ),
                  if (_imageFile != null)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: IconButton(
                        icon: Icon(Icons.delete_forever_outlined, color: Colors.red, size: 22.sp),
                        onPressed: _removeImage,
                        splashRadius: 20.r,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24.h),
              AppTextFormField(
                controller: _nameController,
                hintText: 'Display Name',
                prefixIcon: const Icon(Icons.person),
                validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              SizedBox(height: 20.h),
              AppTextFormField(
                controller: TextEditingController(text: user?.email ?? ''),
                hintText: 'Email',
                readOnly: true,
                prefixIcon: const Icon(Icons.email),
                validator: (_) => null,
              ),
              SizedBox(height: 20.h),
              AppTextFormField(
                controller: _phoneController,
                hintText: 'Phone Number (Optional)',
                prefixIcon: const Icon(Icons.phone),
                validator: (_) => null,
              ),
              SizedBox(height: 50.h), // Extra space to allow pull-down gesture
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveChanges,
        icon: const Icon(Icons.save, size: 24, color: Colors.white),
        label: const Text('Save', style: TextStyle(fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }
}
