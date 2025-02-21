import 'package:flutter/material.dart';
import 'package:flutter_maps/data/models/place_suggestion_model.dart';
import 'package:flutter_maps/presentation/widgets/place_item.dart';
import '../../business_logic/map_cubit.dart';

class BuildSuggestionsList extends StatelessWidget {
  final List<PlaceSuggestionModel> placeSuggestions;

  const BuildSuggestionsList({super.key, required this.placeSuggestions});

  @override
  Widget build(BuildContext context) {
    MapCubit cubit = MapCubit.get(context);

    return SizedBox(
      height: 300, // ✅ Limit the height of ListView (adjust as needed)
      child: ListView.builder(
        shrinkWrap: true, // ✅ Important to limit height to content
        physics: const BouncingScrollPhysics(),
        itemCount: placeSuggestions.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              cubit.searchBarController.close();
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
