import 'package:flutter/material.dart';
import 'package:flutter_maps/data/models/place_suggestion_model.dart';

class PLaceItem extends StatelessWidget {
  final PlaceSuggestionModel placeSuggestionModel;

  const PLaceItem({super.key, required this.placeSuggestionModel});

  @override
  Widget build(BuildContext context) {
    var subTitle = placeSuggestionModel.description
        .replaceAll(placeSuggestionModel.description.split(',')[0], '');
    return Container(
      width: double.infinity,
      margin: const EdgeInsetsDirectional.all(8),
      padding: const EdgeInsetsDirectional.all(4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.blue),
              child: const Icon(
                Icons.place,
                color: Colors.blue,
              ),
            ),
            title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${placeSuggestionModel.description.split(','[0] )}' ,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    TextSpan(
                      text: subTitle.substring(2) ,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
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
