import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_maps/business_logic/issueCubit/issue_cubit.dart';
import '../../business_logic/issueCubit/issue_states.dart';
import '../../business_logic/mapCubit/map_cubit.dart';
import '../../helpers/components.dart';

class AdminIssueBottomSheet extends StatefulWidget {
  final String category;
  final String description;
  final String imagePath;
  final String name;
  final String email;
  final String status;
  final String docId;
  final String? adminResolvedImage;
  final VoidCallback onGetDirections;

  const AdminIssueBottomSheet({
    super.key,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.name,
    required this.email,
    required this.status,
    required this.docId,
    this.adminResolvedImage,
    required this.onGetDirections,
  });

  @override
  State<AdminIssueBottomSheet> createState() => _AdminIssueBottomSheetState();
}

class _AdminIssueBottomSheetState extends State<AdminIssueBottomSheet>
    with SingleTickerProviderStateMixin {
  late String _selectedStatus;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isSaving = false;

  final List<String> _statusOptions = [
    'pending',
    'inProgress',
    'resolved',
    'rejected'
  ];

  bool get hasResolvedImage =>
      IssueCubit.get(context).resolvedImageFile != null ||
          (widget.adminResolvedImage != null &&
              widget.adminResolvedImage!.isNotEmpty);

  Uint8List? get resolvedImageBytes {
    if (widget.adminResolvedImage == null ||
        widget.adminResolvedImage!.isEmpty) {
      return null;
    }
    try {
      return base64Decode(widget.adminResolvedImage!);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = IssueCubit.get(context);
    final theme = Theme.of(context);

    return BlocConsumer<IssueCubit, IssueStates>(
      listener: (context, state) {
        if (state is UpdateIssueSuccessState) {
          if (context.mounted) {
            context.read<MapCubit>().refreshMarkers();
            setState(() => _isSaving = false);
            Navigator.pop(context);
          }
        } else if (state is UpdateIssueErrorState) {
          if (context.mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) => ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(220),
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24.r)),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:  EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHandle(),

                      buildSection(
                        context,
                        title: 'Category',
                        iconColor: theme.primaryColor,
                        animation: _fadeAnimation,
                        child: Text(
                          widget.category.isEmpty
                              ? 'Unknown'
                              : widget.category[0].toUpperCase() +
                              widget.category.substring(1),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6.h,
                            color: Colors.black87.withAlpha(230),
                          ),
                        ),
                      ),

                      // Description
                      buildSection(
                        context,
                        title: 'Description',
                        animation: _fadeAnimation,
                        child: Text(
                          widget.description.isEmpty
                              ? 'No description provided'
                              : widget.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6.h,
                            color: Colors.black87.withAlpha(230),
                          ),
                        ),
                      ),

                      // Image
                      buildSection(
                        context,
                        title: 'Attached Image',
                        animation: _fadeAnimation,
                        child: widget.imagePath.isNotEmpty
                            ? buildImage(context, widget.imagePath)
                            : buildErrorImage(),
                      ),

                      // User info
                      buildSection(
                        context,
                        title: 'Submitted By',
                        animation: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Name: ${widget.name.isEmpty ? 'Unknown' : widget.name}'),
                            SizedBox(height: 4.h),
                            Text('Email: ${widget.email.isEmpty ? 'Unknown' : widget.email}'),
                          ],
                        ),
                      ),

                      // Status display
                      buildSection(
                        context,
                        title: 'Current Status',
                        animation: _fadeAnimation,
                        child: buildStatusPill(_selectedStatus),
                      ),

                      // Status change
                      buildSection(
                        context,
                        title: 'Change Status',
                        animation: _fadeAnimation,
                        child: Wrap(
                          spacing: 8.h,
                          runSpacing: 8.h,
                          children: _statusOptions.map((status) {
                            final isSelected = status == _selectedStatus;
                            return ChoiceChip(
                              label: Text(
                                status[0].toUpperCase() + status.substring(1),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : getStatusColor(status),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: getStatusColor(status),
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                side: BorderSide(color: getStatusColor(status).withAlpha(80)),
                              ),
                              onSelected: _isSaving
                                  ? null
                                  : (selected) {
                                if (selected) {
                                  setState(() => _selectedStatus = status);
                                  _animationController.forward(from: 0);
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      // If resolved, show image section
                      if (_selectedStatus == 'resolved') ...[
                        SizedBox(height: 16.h),
                        buildSection(
                          context,
                          title: 'Resolution Image',
                          icon: Icons.image_outlined,
                          animation: _fadeAnimation,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: cubit.resolvedImageFile != null
                                ? Image.file(
                              cubit.resolvedImageFile!,
                              height: 220.h,
                              width: double.infinity.w,
                              fit: BoxFit.cover,
                            )
                                : hasResolvedImage
                                ? Image.memory(
                              resolvedImageBytes!,
                              height: 220.h,
                              width: double.infinity.w,
                              fit: BoxFit.cover,
                            )
                                : buildErrorImage(),
                          ),
                        ),
                        if (cubit.resolvedImageFile == null && !hasResolvedImage)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                cubit.pickResolvedImage(ImageSource.gallery);
                              },
                              icon: const Icon(Icons.upload, color: Colors.white),
                              label: Text(
                                'Upload Resolution Image',
                                style: TextStyle(fontSize: 16.sp, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                            ),
                          ),
                        if (cubit.resolvedImageFile != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                                onPressed: () => cubit.pickResolvedImage(ImageSource.gallery),
                                child: Text('Reselect Image', style: TextStyle(fontSize: 14.sp)),
                              ),
                              SizedBox(width: 12.w),
                              ElevatedButton(
                                onPressed: () => cubit.clearResolvedImage(),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: Text('Delete', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
                              ),
                            ],
                          ),
                      ],

                      SizedBox(height: 20.h),

                      // Save + Dismiss
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.cancel_outlined, size: 20.w),
                              label: const Text('Dismiss'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey.shade400),
                                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (_selectedStatus == 'resolved' &&
                                    !hasResolvedImage &&
                                    cubit.resolvedImageFile == null) {
                                  return;
                                }

                                setState(() => _isSaving = true);

                                await cubit.updateIssueStatus(
                                  widget.docId,
                                  _selectedStatus,
                                  adminImage: _selectedStatus == 'resolved'
                                      ? cubit.resolvedImageFile
                                      : null,
                                );
                              },
                              icon: _isSaving
                                  ? SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                                  : Icon(Icons.save_outlined, size: 20.w),
                              label: const Text('Save Status'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Get Directions
                      if (!_isSaving)
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: (){
                              debugPrint('📍 Get Directions Tapped');
                              widget.onGetDirections();
                            },
                            icon: Icon(Icons.directions_outlined, size: 20.w),
                            label: const Text('Get Directions'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity.w, 48.h),
                              foregroundColor: Colors.black87,
                              side: BorderSide(color: Colors.grey.shade400),
                              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
