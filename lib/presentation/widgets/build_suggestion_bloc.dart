
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../business_logic/map_cubit.dart';
import '../../business_logic/map_states.dart';
import 'build_suggestions_list.dart';

class BuildSuggestionsBloc extends StatelessWidget {
  const BuildSuggestionsBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapStates>(
      builder: (context, state) {
        if (state is MapPlacesLoadedState && state.placeSuggestionModel.isNotEmpty) {
          return BuildSuggestionsList(placeSuggestions: state.placeSuggestionModel);
        }
        return Container();
      },
    );
  }
}