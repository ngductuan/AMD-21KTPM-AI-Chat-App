import 'package:flutter/material.dart';

Widget buildLoadingIndicator({bool hasMore = true, double? size = 32}) {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Center(
      // Show a loading indicator if more items are being loaded
      child: hasMore
          ? SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(),
            )
          : SizedBox.shrink(),
    ),
  );
}
