import 'package:flutter/material.dart';

Widget buildLoadingIndicator({bool hasMore = true}) {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Center(
      // Show a loading indicator if more items are being loaded
      child: hasMore ? CircularProgressIndicator() : SizedBox.shrink(),
    ),
  );
}
