import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/presentation/widgets/adminIssueBottomSheet/widgets/change_status_slider.dart';
import 'package:flutter_maps/presentation/widgets/adminIssueBottomSheet/widgets/image_before_after.dart';
import 'package:flutter_maps/presentation/widgets/adminIssueBottomSheet/widgets/issue_category_and_description.dart';
import 'package:flutter_maps/presentation/widgets/adminIssueBottomSheet/widgets/issue_quick_actions.dart';
import 'package:flutter_maps/presentation/widgets/adminIssueBottomSheet/widgets/user_header_with_close.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../business_logic/issueCubit/issue_cubit.dart';
import '../../../business_logic/issueCubit/issue_states.dart';
import '../../../business_logic/mapCubit/map_cubit.dart';
import '../../../helpers/components.dart';

class AdminIssueBottomSheet extends StatefulWidget {
  final String category;
  final String description;
  final String imagePath;
  final String name;
  final String email;
  final String status;
  final String docId;
  final String location;
  final String? adminResolvedImage;
  final DateTime createdAt;

  const AdminIssueBottomSheet({
    super.key,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.name,
    required this.email,
    required this.status,
    required this.docId,
    required this.location,
    this.adminResolvedImage,
    required this.createdAt,
  });

  @override
  State<AdminIssueBottomSheet> createState() => _AdminIssueBottomSheetState();
}

class _AdminIssueBottomSheetState extends State<AdminIssueBottomSheet>
    with SingleTickerProviderStateMixin {
  late String _selectedStatus;
  late AnimationController _animationController;

  bool _isSaving = false;
  bool isImageSaved = false;

  static const List<String> _statusOptions = [
    'pending',
    'inProgress',
    'resolved',
    'rejected',
  ];

  IssueCubit get cubit => IssueCubit.get(context);

  bool get hasResolvedImage =>
      cubit.resolvedImageFile != null ||
          (widget.adminResolvedImage?.isNotEmpty ?? false);

  bool get isFinalized =>
      widget.status == 'resolved' && hasResolvedImage;

  Uint8List? get resolvedImageBytes {
    final image = widget.adminResolvedImage;
    if (image?.isEmpty ?? true) return null;
    try {
      return base64Decode(image!);
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
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IssueCubit, IssueStates>(
      listener: (context, state) {
        if (state is UpdateIssueSuccessState && context.mounted) {
          context.read<MapCubit>().refreshMarkers();
          setState(() => _isSaving = false);
          Navigator.pop(context);
        } else if (state is UpdateIssueErrorState && context.mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.errorMessage}')),
          );
        }
      },
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserHeaderWithClose(
                      name: widget.name,
                      createdAt: widget.createdAt,
                    ),
                    SizedBox(height: 8.h),
                    IssueCategoryAndDescription(
                      category: widget.category,
                      description: widget.description,
                    ),
                    SizedBox(height: 20.h),
                    ImageBeforeAfter(
                      imagePath: widget.imagePath,
                      hasResolvedImage: hasResolvedImage,
                      resolvedImageBytes: resolvedImageBytes,
                      selectedStatus: _selectedStatus,
                      isImageSaved: isImageSaved,
                      onImagePicked: () {
                        isImageSaved = false;
                        setState(() {});
                      },
                      onImageCleared: () {
                        cubit.clearResolvedImage();
                        isImageSaved = false;
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 20.h),
                    ChangeStatusSlider(
                      selectedStatus: _selectedStatus,
                      statusOptions: _statusOptions,
                      isFinalized: isFinalized,
                      getStatusColor: getStatusColor,
                      onStatusChanged: (value) {
                        setState(() => _selectedStatus = value);
                        _animationController.forward(from: 0);
                      },
                    ),
                    SizedBox(height: 20.h),
                    IssueQuickActions(
                      email: widget.email,
                      location: widget.location,
                      docId: widget.docId,
                      selectedStatus: _selectedStatus,
                      isFinalized: isFinalized,
                      isSaving: _isSaving,
                      hasResolvedImage: hasResolvedImage,
                      resolvedImageFile: cubit.resolvedImageFile,
                      isImageSaved: isImageSaved,
                      onSave: ({
                        required String docId,
                        required String status,
                        dynamic adminImage,
                      }) async {
                        setState(() => _isSaving = true);
                        await cubit.updateIssueStatus(
                          docId,
                          status,
                          adminImage: adminImage,
                        );
                        isImageSaved = true;
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
