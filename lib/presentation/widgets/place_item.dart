import 'package:flutter/material.dart';
import 'package:flutter_maps/data/models/place_suggestion_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PLaceItem extends StatelessWidget {
  final PlaceSuggestionModel placeSuggestionModel;

  const PLaceItem({super.key, required this.placeSuggestionModel});

  @override
  Widget build(BuildContext context) {
    var subTitle = placeSuggestionModel.description
        .replaceAll(placeSuggestionModel.description.split(',')[0], '');
    return Container(
      width: double.infinity,
      margin: EdgeInsetsDirectional.all(8.w),
      padding: EdgeInsetsDirectional.all(4.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.r)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40.w,
              height: 40.h,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.blue),
              child: const Icon(
                Icons.place,
                color: Colors.white,
              ),
            ),
            title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${placeSuggestionModel.description.split(','[0] )}' ,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    TextSpan(
                      text: subTitle.substring(2) ,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                  ],

                ),
            ),
          ),
        ],
      ),
    );
  }
}
