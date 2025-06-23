import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:uuid/uuid.dart';
import '../../business_logic/mapCubit/map_cubit.dart';
import 'build_suggestion_bloc.dart';

class MapSearchBar extends StatefulWidget {
  final Function(Marker) onSuggestionSelected;

  const MapSearchBar({super.key, required this.onSuggestionSelected});

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  String? sessionToken;

  @override
  void initState() {
    super.initState();
    sessionToken = const Uuid().v4();
  }

  void getPlacesSuggestions(String query) {
    sessionToken ??= const Uuid().v4();
    MapCubit.get(context).emitPlacesSuggestion(query, sessionToken!);
  }

  @override
  Widget build(BuildContext context) {
    var cubit = MapCubit.get(context);
    return FloatingSearchBar(
      backgroundColor: Colors.white,
      automaticallyImplyDrawerHamburger: true,
      controller: cubit.searchBarController,
      hint: 'Search places or find buddies nearby...',
      transitionDuration: const Duration(milliseconds: 500),
      physics: const BouncingScrollPhysics(),
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      width: 600.w,
      debounceDelay: const Duration(milliseconds: 300),
      onQueryChanged: (query) {
        if (query.isNotEmpty) getPlacesSuggestions(query);
      },
      transitionCurve: Curves.easeInOut,
      actions: [FloatingSearchBarAction.searchToClear()],
      builder: (context, transition) {
        return  const BuildSuggestionsBloc();
      },
    );
  }
}
