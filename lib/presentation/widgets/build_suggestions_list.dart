import 'package:flutter/material.dart';
import 'package:flutter_maps/data/models/place_details_model.dart';
import 'package:flutter_maps/data/models/place_suggestion_model.dart';
import 'package:flutter_maps/presentation/widgets/place_item.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import '../../business_logic/mapCubit/map_cubit.dart';

class BuildSuggestionsList extends StatelessWidget {
  final List<PlaceSuggestionModel> placeSuggestions;
  final PlaceDetailsModel? placeDetailsModel;

  const BuildSuggestionsList({
    super.key,
    required this.placeSuggestions,
    this.placeDetailsModel,
  });

  void getSelectedPlaceLocation(BuildContext context, String placeId, PlaceSuggestionModel placeSuggestionModel) {
    final sessionToken = const Uuid().v4();
    MapCubit.get(context).emitPlaceDetails(placeId, sessionToken, placeSuggestionModel);
  }


  @override
  Widget build(BuildContext context) {
    MapCubit cubit = MapCubit.get(context);

    return SizedBox(
      height: 400.h,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: placeSuggestions.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              final sessionToken = const Uuid().v4();

              cubit.selectPlace(
                placeSuggestions[index].placeId,
                placeSuggestions[index].description,
                sessionToken,
              );

              cubit.searchBarController.close(); // Optional
            },

            child: PLaceItem(
              placeSuggestionModel: placeSuggestions[index],
            ),
          );
        },
      ),
    );
  }
}
